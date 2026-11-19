// Maket boyayıcısı: ışıklı gri kare + bölge kimliği haritası → tema görünümü.
// uStyle 0: Mono nokta-matris (ekran ızgarası), 1: Canlı parlayan heykel.
// Koordinatlar, görüntünün sığdırıldığı dikdörtgene göredir (uSize = o dikdörtgen).
// uBase: Canlı'da heykel taşı rengi; Mono'da yalnızca alfa kullanılır (en düşük nokta
// opaklığı: açık zeminde soluk noktalar kaybolmasın diye > 0).
#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform vec4 uAccent;
uniform vec4 uBase;
uniform vec4 uOff;
uniform float uStyle;
uniform float uPitch;
uniform float uLevels[15];

uniform sampler2D uShade;
uniform sampler2D uIds;

out vec4 fragColor;

// Kimlik (0 cilt, 1–14 bölge, 15 boş) en yakın komşu örneklenir; karışmaz.
float regionId(vec2 uv) {
  return floor(texture(uIds, uv).r * 15.0 + 0.5);
}

// Sabit sınırlı döngü: dinamik dizi indeksi gerektirmez.
float levelOf(float id) {
  float lv = 0.0;
  for (int i = 1; i < 15; i++) {
    if (abs(float(i) - id) < 0.5) {
      lv = uLevels[i];
    }
  }
  return lv;
}

// Görüntü önceden çarpılmış alfa ile gelir; ışık değeri = r / a.
float lumOf(vec4 s) {
  return s.a > 0.004 ? clamp(s.r / s.a, 0.0, 1.0) : 0.0;
}

bool inside(vec2 uv) {
  return uv.x >= 0.0 && uv.y >= 0.0 && uv.x <= 1.0 && uv.y <= 1.0;
}

vec4 dots(vec2 p) {
  vec2 c = (floor(p / uPitch) + 0.5) * uPitch;
  vec2 uv = c / uSize;
  if (!inside(uv)) return vec4(0.0);
  vec4 s = texture(uShade, uv);
  if (s.a < 0.5) return vec4(0.0);
  float l = pow(lumOf(s), 1.3);
  float k = levelOf(regionId(uv)) / 3.0;
  float r;
  vec3 col;
  float a;
  if (k > 0.0) {
    r = uPitch * (0.10 + 0.34 * l * (0.55 + 0.45 * k));
    col = uAccent.rgb;
    a = (0.35 + 0.75 * l) * (0.7 + 0.3 * k);
  } else {
    r = uPitch * (0.06 + 0.26 * l);
    col = uOff.rgb;
    a = 0.12 + 0.78 * l;
  }
  a = mix(uBase.a, 1.0, clamp(a, 0.0, 1.0));
  float d = length(p - c);
  float cov = 1.0 - smoothstep(r - 0.5, r + 0.5, d);
  float alpha = a * cov;
  return vec4(col * alpha, alpha);
}

float emission(vec2 uv) {
  if (!inside(uv)) return 0.0;
  vec4 s = texture(uShade, uv);
  return levelOf(regionId(uv)) / 3.0 * lumOf(s) * s.a;
}

vec4 glow(vec2 p) {
  vec2 uv = p / uSize;
  vec4 s = texture(uShade, uv);
  float a = s.a;
  float lum = lumOf(s);
  float t = levelOf(regionId(uv)) / 3.0;

  vec3 stone = uBase.rgb * lum;
  vec3 lit = uAccent.rgb * (0.12 + 1.05 * pow(lum, 1.6)) * (0.8 + 0.25 * t);
  float m = min(1.0, t * 1.6);
  vec3 col = clamp(mix(stone, lit, m), 0.0, 1.0);

  // Yumuşak ışıma: üç halkada 8'er örnek (yaklaşık Gauss, sigma ≈ yüksekliğin %1'i).
  vec2 unit = vec2(uSize.y / uSize.x, 1.0) * 0.01;
  float sum = emission(uv);
  float wsum = 1.0;
  for (int ring = 1; ring <= 3; ring++) {
    float rr = float(ring) * 1.1;
    float w = exp(-0.5 * rr * rr) * float(ring);
    for (int j = 0; j < 8; j++) {
      float ang = (float(j) + 0.5 * float(ring)) * 0.785398;
      sum += emission(uv + vec2(cos(ang), sin(ang)) * rr * unit) * w;
      wsum += w;
    }
  }
  float h = sum / wsum * 0.35;

  float alpha = clamp(a + h * (1.0 - a), 0.0, 1.0);
  vec3 rgb = min(col * a + uAccent.rgb * h, vec3(alpha));
  return vec4(rgb, alpha);
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  fragColor = uStyle < 0.5 ? dots(p) : glow(p);
}
