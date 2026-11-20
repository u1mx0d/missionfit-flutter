// Maket boyayıcısı: ışıklı gri kare + bölge kimliği haritası → tema görünümü.
// uStyle 0: Mono nokta-matris (ekran ızgarası), 1: Canlı parlayan heykel.
// Koordinatlar, görüntünün sığdırıldığı dikdörtgene göredir (uSize = o dikdörtgen).
// Doku (kare başına tek, opak): R = ışık × alfa, G = kimlik × 17, B = alfa
// (yüklemede 0,5 altı alfa sisi sıfırlanır).
// uShade ve uIds aynı dokuya bağlanır: uShade bilineer, uIds en yakın komşu.
// uBase: Canlı'da heykel taşı rengi. uOffFloor: Mono'da boş (seviye 0) noktaların en
// düşük opaklığı (açık zeminde soluk noktalar kaybolmasın diye > 0); dolu noktalar
// tabana tabi değildir.
// Seçim: uSelected[id] = 1 seçili bölge. uSelecting = 1 iken seçili bölgeler seviye 3 gibi
// tam vurguda, diğerleri ~%70 parlaklıkta; seçili bölgenin kenarına ince çizgi (Mono'da kenar
// noktaları büyür). uPulse 0–1: kenarın yavaş nabzı (azaltılmış harekette sabit 1).
#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform vec4 uAccent;
uniform vec4 uBase;
uniform vec4 uOff;
uniform float uStyle;
uniform float uPitch;
uniform float uOffFloor;
uniform float uLevels[15];
uniform float uSelected[15];
uniform float uSelecting;
uniform float uPulse;

uniform sampler2D uShade;
uniform sampler2D uIds;

out vec4 fragColor;

// Kimlik (0 cilt, 1–14 bölge, 15 boş) en yakın komşu örneklenir; karışmaz.
float regionId(vec2 uv) {
  return floor(texture(uIds, uv).g * 15.0 + 0.5);
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

// R önceden çarpılmış ışık; ışık değeri = r / alfa.
float lumOf(vec4 s) {
  return s.b > 0.004 ? clamp(s.r / s.b, 0.0, 1.0) : 0.0;
}

float selectedOf(float id) {
  float s = 0.0;
  for (int i = 1; i < 15; i++) {
    if (abs(float(i) - id) < 0.5) {
      s = uSelected[i];
    }
  }
  return s;
}

// Seçim varken etkin seviye (0–1): seçili 1, diğerleri kendi seviyesi.
float levelK(float id) {
  return selectedOf(id) > 0.5 ? 1.0 : levelOf(id) / 3.0;
}

// Seçim varken seçili olmayan bölgelerin sönükleşme çarpanı.
float dimOf(float id) {
  return (uSelecting > 0.5 && selectedOf(id) < 0.5) ? 0.7 : 1.0;
}

bool inside(vec2 uv) {
  return uv.x >= 0.0 && uv.y >= 0.0 && uv.x <= 1.0 && uv.y <= 1.0;
}

vec4 dots(vec2 p) {
  vec2 c = (floor(p / uPitch) + 0.5) * uPitch;
  vec2 uv = c / uSize;
  if (!inside(uv)) return vec4(0.0);
  vec4 s = texture(uShade, uv);
  if (s.b < 0.5) return vec4(0.0);
  float l = pow(lumOf(s), 1.3);
  float id = regionId(uv);
  float k = levelK(id);
  float sel = uSelecting > 0.5 ? selectedOf(id) : 0.0;
  // Kenar noktası: komşu nokta merkezlerinden biri seçili değilse.
  float edge = 0.0;
  if (sel > 0.5) {
    vec2 q = vec2(uPitch) / uSize;
    float n = selectedOf(regionId(uv + vec2(q.x, 0.0))) * selectedOf(regionId(uv - vec2(q.x, 0.0))) *
        selectedOf(regionId(uv + vec2(0.0, q.y))) * selectedOf(regionId(uv - vec2(0.0, q.y)));
    edge = 1.0 - n;
  }
  float r;
  vec3 col;
  float a;
  if (k > 0.0) {
    r = uPitch * (0.10 + 0.34 * l * (0.55 + 0.45 * k));
    col = uAccent.rgb;
    // Koyu zeminde parlaklık kabartmayı taşır; açık zeminde (uOffFloor > 0) saydamlık
    // vurguyu pembeye soldurur, bu yüzden tam vurgu ve kabartma yalnız boyutla.
    a = uOffFloor > 0.0 ? 1.0 : (0.35 + 0.75 * l) * (0.7 + 0.3 * k);
  } else {
    r = uPitch * (0.06 + 0.26 * l);
    col = uOff.rgb;
    a = mix(uOffFloor, 1.0, 0.12 + 0.78 * l);
  }
  if (sel > 0.5) {
    // Seçili: tam boy; kenar noktaları nabızla biraz daha büyük ve tam opak.
    r = uPitch * (0.34 + 0.10 * edge * (0.4 + 0.6 * uPulse));
    a = max(a, 0.75 + 0.25 * max(l, edge));
  }
  a = clamp(a * dimOf(id), 0.0, 1.0);
  float d = length(p - c);
  float cov = 1.0 - smoothstep(r - 0.5, r + 0.5, d);
  float alpha = a * cov;
  return vec4(col * alpha, alpha);
}

float emission(vec2 uv) {
  if (!inside(uv)) return 0.0;
  vec4 s = texture(uShade, uv);
  float id = regionId(uv);
  return levelK(id) * dimOf(id) * lumOf(s) * s.b;
}

vec4 glow(vec2 p) {
  vec2 uv = p / uSize;
  vec4 s = texture(uShade, uv);
  float a = s.b;
  float lum = lumOf(s);
  float id = regionId(uv);
  float t = levelK(id);

  vec3 stone = uBase.rgb * lum;
  vec3 lit = uAccent.rgb * (0.12 + 1.05 * pow(lum, 1.6)) * (0.8 + 0.25 * t);
  float m = min(1.0, t * 1.6);
  vec3 col = clamp(mix(stone, lit, m), 0.0, 1.0) * dimOf(id);

  // Seçili bölgenin kenarı: ~1,25 px uzaktaki dört komşudan biri seçili değilse çizgi.
  if (uSelecting > 0.5 && selectedOf(id) > 0.5 && a > 0.0) {
    vec2 q = vec2(1.25) / uSize;
    float n = selectedOf(regionId(uv + vec2(q.x, 0.0))) * selectedOf(regionId(uv - vec2(q.x, 0.0))) *
        selectedOf(regionId(uv + vec2(0.0, q.y))) * selectedOf(regionId(uv - vec2(0.0, q.y)));
    if (n < 0.5) {
      col = mix(col, uAccent.rgb, 0.6 + 0.4 * uPulse);
      a = 1.0;
    }
  }

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
