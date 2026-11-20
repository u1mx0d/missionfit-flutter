# Maket varlıkları (3B kaslı atlet heykeli)

`assets/body_map/` altındaki 72 karelik dönüşü üreten Blender hattı.

## Kaynaklar ve lisanslar

| Ne | Sürüm | Kaynak | Lisans |
|---|---|---|---|
| Blender | 5.2.4 LTS (portable, `~/.local/opt/blender/blender`) | https://download.blender.org/release/Blender5.2/blender-5.2.4-linux-x64.tar.xz | GPL (yalnızca araç) |
| MPFB eklentisi | 2.0.18 (build 20261010) | https://extensions.blender.org/add-ons/mpfb/ (depo: `https://extensions.blender.org/api/v1/extensions/`, Blender'daki `blender_org`) | Kod GPL-3.0; çıktı kullanıcıya ait |
| Temel insan ağı `base.obj` (hm08) | MPFB 2.0.18 içinde | MakeHuman | CC0 ("explicitly released as CC0 in september 2020") |
| Hedefler (macrodetails, torso, arms, legs, stomach) | MPFB 2.0.18 içinde | MakeHuman | CC0 |
| `default` iskelet ve ağırlıkları | MPFB 2.0.18 içinde | MakeHuman | CC0 |

Ayrı asset paketi (cilt, saç, giysi) **gerekmez**: model nötr gri heykel malzemesiyle
çizilir, göz, kaş ve saç eklenmez. Uygulamadaki atıf: "MakeHuman / MPFB (CC0)".

## Kurulum

Blender 5.2.4 Linux x64 arşivi:

```
https://download.blender.org/release/Blender5.2/blender-5.2.4-linux-x64.tar.xz
sha256  2fd14c50987426897ba60237ee996edf2b4151f4b1a72a460ca20be58c1d2d86
```

(Özet, resmî `https://download.blender.org/release/Blender5.2/blender-5.2.4.sha256`
dosyasından alınmıştır.) Arşiv `~/.local/opt/blender` altına açılır; sudo gerekmez.

```sh
B=~/.local/opt/blender/blender
$B --online-mode --command extension sync
$B --online-mode --command extension install --enable mpfb
```

## Üretim

```sh
~/.local/opt/blender/blender -b -P tools/body_map/build_body_map.py -- --out assets/body_map
python3 tools/body_map/verify.py assets/body_map
```

`verify.py` manifesti (anahtarlar, atıf, 14 bölge sırası), boyutu, kimlik değerlerini,
tekil pikselleri (4 komşusu da farklı olan piksel; kenar yumuşatması sızıntısını
yakalar), boşluk ⇔ alfa eşleşmesini (alfa < 0,5, 1 px kenar payı) ve boş
piksellerdeki soluk alfayı denetler.

Not: `--factory-startup` kullanmayın; eklentiler o kipte yüklenmez.

### Yeniden üretilebilirlik

- **Kimlik haritaları birebir aynı çıkar.** Geometri ve bölge kuralları belirlenimcidir;
  Workbench AA'sız çizer ve değerler 17'nin katına yuvarlanır.
- **Işıklı kareler yalnızca yaklaşık olarak aynı çıkar.** Cycles tohumu sabittir
  (`seed = 0`, `use_animated_seed = False`), ama sonuç aygıta (CPU / OptiX / CUDA),
  sürücüye ve OpenImageDenoise sürümüne göre gürültü düzeyinde değişebilir.
  `--device auto|cpu|optix|cuda` aygıtı sabitler; seçilen aygıt
  `BODY_MAP_CYCLES_DEVICE` satırıyla yazdırılır. Depodaki kareler OPTIX ile, NVIDIA
  GeForce RTX 4050 Laptop GPU üzerinde üretildi.
Deneme için `--only 0,18,36` (manifest yazılmaz), `--debug DIR` (yüz verisi ve .blend).

Önizleme (Pillow + numpy):

```sh
python3 tools/body_map/preview.py --assets assets/body_map --mode overlay|mono|glow --out x.png
```

## Hat

1. **İnsan (MPFB):** erkek, kas 1.0, kilo 0.0, oran 1.0; ek hedefler (göğüs, sırt,
   V-gövde, karın tonu, omuz/kol/bacak kası). `default` iskeletle duruş: kollar ~28°
   açık, hafif geride; bacaklar 3° içe. Duruş uygulanır, iskelet silinir. Yalnızca gövde ağı ve
   göz küreleri (heykel gözü) kalır; kirpik, diş, dil vb. yardımcılar silinir.
2. **Alt bölme:** Catmull-Clark 2 kez uygulanır (~216 bin yüz); kabartma bu ağda hesaplanır.
3. **Bölgeler (`regions.json`):** Her yüz önce kemik ağırlıklarına göre bir segmente
   (gövde, üst kol, ön kol, uyluk, baldır, el, ayak, baş) atanır. Kurallar sırayla
   uygulanır, ilk eşleşen kazanır. Kural koşulları:
   - `chart: torso`: gövde açılımı, açı (0 ön orta, 90 yan, 180 sırt orta) × yükseklik z (m).
   - `chart: upperarm|forearm|thigh|shin`: uzuv ekseni etrafında açı (0 ön, +90 dış,
     ±180 arka, −90 iç) × eksen boyunca t (0 = üst eklem, 1 = alt eklem).
   - `ellipsoid` (uzuv eksenine hizalı olabilir), `torso_ang`, `normal_min`.
   - `clip`: ek bir çokgen; bir bölgenin parçaları (ör. quadriceps başları) aynı
     düzgün dış çizgiyi paylaşır. Eğri sınırlar kosinüs ara değerli sık noktalarla
     yazılmıştır.
   - `part`: aynı bölgeyi kabartma için alt kaslara böler (karın paketleri, quadriceps
     başları, baldır başları). Kimlik haritasını etkilemez.
   Çokgenler gövdenin işaretli noktalarına (meme ucu ≈ 38°/1.40 m, göbek 0°/1.145 m,
   omuz eklemi 1.50 m) göre elle ayarlanmıştır. Kurallar bu gövdeye göredir; vücut
   ayarları değişirse sınırlar yeniden kontrol edilmelidir.
4. **Kas kabartması:** Bölge/parça sınırlarına yumuşak oluk açılır (sınırdan
   `width_m` uzaklığa kadar smoothstep, derinlik `depth_m` × bölge katsayısı, kas–cilt
   sınırında × `skin_edge`). Aynı kurallardan çıktığı için görünen kas çizgileri kimlik haritasıyla
   örtüşür.
5. **İnce ağda kimlik:** Kabartmadan sonra ağ bir kez daha alt bölünür (~860 bin yüz,
   yüz ≈ 2–3 mm ≈ 1 px) ve aynı kurallar yeniden uygulanır. Sınırlar merdivensiz,
   düzgün eğriler olur; kimlik haritası yine kenar yumuşatmasız ve kesin değerlidir.
6. **Işıklı kareler:** Cycles (GPU OptiX varsa), 48 örnek + OpenImageDenoise, AgX
   Medium High Contrast, pozlama −0.3. Gri malzeme + AO düğümü (albedo 0.42, oyuklarda
   0.06). Disk alan ışıkları: sol üst anahtar, zayıf dolgu, iki kenar ışığı. Kamera ve
   ışıklar sabit, model döner. Çıktı WebP (kalite 82), şeffaf arka plan.
7. **Kimlik haritası:** Workbench, düz ışık, malzeme rengi, AA kapalı, dither 0,
   Standard görünüm. Renkler sayısal olarak 17'nin katına yuvarlanır, alfa < 0.5 = 255.
   **8 bit gri tonlu PNG** (renk tipi 0) olarak yazılır: çözülünce R = G = B = kimlik × 17,
   yani kırmızı kanal = kimlik × 17 (0 cilt, 17…238 bölgeler, 255 boş).

## Kare düzeni

- 72 kare, 5° adım, 360 × 720 px.
- Kare 000 ön görünüm. Açı yukarıdan bakınca saat yönünde artar: kare 018'de
  vücut izleyicinin soluna bakar (sol yanı görünür), 036 arka görünüm.
