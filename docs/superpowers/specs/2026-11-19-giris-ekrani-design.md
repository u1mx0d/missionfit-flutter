# Giriş ekranları ve sporcu kartı — Tasarım

Tarih: 2026-11-19. Durum: kullanıcı onayı bekliyor.
Taslaklar: `.superpowers/brainstorm/227680-1795075968/content/giris-yonleri.html` (A · Matris açılış ve C · Sporcu kartı birleştirildi).

## Neden

Mevcut giriş ekranı çalışıyor ama "herkes gibi" hissettiriyor; logo yok. Kullanıcı özgün bir giriş deneyimi istiyor. Nokta-matris M logosunu (uygulama ikonu) seviyor; ikon kalıyor, giriş ekranlarına taşınıyor.

## Hedefler

- Uygulamanın kimliği ilk ekranda belli olsun: nokta-matris M logosu, tek, ölçülü bir açılış animasyonu.
- Kayıt kişiye ait bir şey üretsin: **sporcu kartı**. Kayıtta boş başlar, yazdıkça dolar, kod doğrulanınca "AKTİF" damgası alır.
- Giriş ekranı, bu telefonda daha önce giriş yapmış kişiye kendi kartını gösterip "Tekrar hoş geldin" desin.
- Mevcut davranışlar korunur: e-posta + şifre, Google ile giriş, kod doğrulama, şifremi unuttum, bekleyen kayıt kartı ("Kaydını tamamla"), doğrulanmamış e-postada koda yönlendirme.

## Hedef dışı / yapılmayacaklar

- Sunucu değişikliği yok.
- **Giriş öncesi e-postadan kullanıcı adı/fotoğraf sorgulamak yok**: hesap var mı yok mu ve başkasının kullanıcı adı/fotoğrafı sızardı (hesap numaralandırma). Kart yalnızca bu telefonda daha önce giriş yapmış hesaplar için dolu görünür.
- Sporcu numarası/sayaç yok (kullanıcı sayısını ele verir, sunucu sayacı ister). Kartta üyelik tarihi yazar.
- Uygulama ikonu değişmez.

## Yaklaşımlar

Seçilen yön kullanıcıyla taslaklar üzerinden belirlendi: **A (Matris açılış) + C (Sporcu kartı)**. B (Görev brifingi: kayıt = "Görev 001", büyük "HAZIR MISIN?") tercih edilmedi.

Yapım için tek mantıklı yol var (Claude'un kararı): logo, kart ve animasyon Flutter'da çizilen kendi bileşenlerimiz (CustomPainter + implicit/explicit animasyon). Böylece her tema ve vurgu rengine kendiliğinden uyar; yeni paket ya da görsel dosyası gerekmez. Kayıtlı kartlar cihazda (SharedPreferences) tutulur, tema ve bekleyen kayıt gibi.

## Ekranlar ve akış

```
Oturum yok ──► (yarım kalmış kayıt var mı?) ─ evet ─► /dogrula?email=…  (kart "KOD BEKLENİYOR")
                 └─ hayır ─► (telefonda kayıtlı kart var mı?)
                                ├─ evet ─► /giris  (o kişinin kartı, e-posta dolu)
                                └─ hayır ─► /hosgeldin
/hosgeldin: logo animasyonu · "MISSIONFIT" · "Her gün bir görev. Her set bir adım."
            [Google ile devam et] [E-posta ile kayıt ol] "Hesabın var mı? Giriş yap"
/kayit:     boş kart (üstte) + e-posta, şifre, şifre tekrar → [Kartımı oluştur] + Google
/dogrula:   kart (e-posta yazılı, "KOD BEKLENİYOR" etiketi) + kod alanı → doğrulanınca "AKTİF" damgası
/giris:     kart (kayıtlı hesap ya da örnek kart) + e-posta, şifre → [Giriş yap] + Google + Şifremi unuttum
/sifremi-unuttum: kart yok; küçük logo + başlık + mevcut iki aşamalı form
```

- `/hosgeldin` yeni bir kimlik rotası (authRoutes'a eklenir). Oturum yokken varsayılan hedef: yarım kalmış kayıt (`pendingSignupEmailProvider`) varsa `/dogrula`, değilse telefonda kayıtlı kart varsa `/giris`, yoksa `/hosgeldin`. Yalnızca kimlik dışı bir yoldan (ör. açılışta `/bugun`) yönlendirilirken uygulanır; kullanıcı kimlik ekranları arasında kendisi gezinirken araya girmez. *(Claude'un kararı: 43b08e5'teki "Kaydını tamamla" düzeltmesi kayıtlı kartı olmayan telefonda da çalışsın diye.)*
- Tüm kimlik ekranlarından `/hosgeldin`'e geri dönülebilir (geri oku ya da sistem geri hareketi).
- "Kaydını tamamla" kartı (bekleyen kayıt) giriş ekranında sporcu kartının altında kalır.

## Logo (MfLogo)

- 5×5 nokta ızgarası; M'yi oluşturan 12 nokta metin rengiyle, orta nokta **vurgu rengiyle** (Canlı yeşil, Mono kırmızı, kullanıcının seçtiği vurgu). Diğer 12 nokta çok soluk (zemin dokusu). Oranlar `assets/icon/icon_fg.png` ile aynı.
- Boyutlar: açılışta ~128 dp, kartta ~32 dp, şifre sayfasında ~40 dp.

## Açılış animasyonu (`/hosgeldin`)

- Noktalar arka plandaki nokta ızgarasından rastgele konumlardan M'deki yerlerine akar (~900 ms, yavaşlayarak durur), en son orta nokta yanar (~150 ms), ardından yazı ve düğmeler belirir (~250 ms).
- Uygulama açılışı başına bir kez oynar; ekrana geri dönülünce tekrar oynamaz.
- Sistem "animasyonları kaldır" ayarı açıksa (`MediaQuery.disableAnimations`) animasyon yok, logo doğrudan son halinde.
- Ekranda başka animasyonlu öğe yok (ui-ux-pro-max: görünüm başına en çok 1–2 animasyon).

## Sporcu kartı (AthleteCard)

İçerik: logo (sol üst), durum damgası (sağ üst), "SPORCU KİMLİĞİ" etiketi, büyük ad (yoksa `@kullaniciadi`, o da yoksa e-posta), altında `@kullaniciadi`, en altta "Üye: Kasım 2026", fotoğraf varsa sağda yuvarlak avatar (mevcut MfAvatar).

Durumlar:
| Durum | Nerede | Görünüm |
|---|---|---|
| Boş | /kayit başında | Alanlar nokta yer tutucu (`····`), damga yok |
| Doluyor | /kayit yazarken | Geçerli e-posta yazıldıkça kartta belirir (kısa geçiş); şifre kurallara uyunca kartta küçük "✓ Şifre" işareti |
| Kod bekleniyor | /dogrula | E-posta yazılı, "KOD BEKLENİYOR" etiketi |
| Aktif | /dogrula başarı | "AKTİF" damgası basılır (ölçek + hafif dönüş, ~300 ms); yönlendirme sabit ~700 ms bekletilir (mevcut `authHold` mekanizmasıyla), sonra onboarding'e geçilir. Kullanıcıdan dokunma beklenmez. *(Claude'un kararı)* |
| Kayıtlı | /giris, kayıtlı hesap | Ad, @kullaniciadi, fotoğraf, üyelik tarihi; üstte "Tekrar hoş geldin" |
| Örnek | /giris, kayıtlı hesap yok | Logo + "MissionFit sporcusu", @ ve tarih yerinde nokta yer tutucu |

- Onboarding "Profilin" adımında mevcut avatar dairesinin yerine aynı kart gösterilir; ad, kullanıcı adı ve fotoğraf girildikçe kartta güncellenir (fotoğrafa dokunmak yine fotoğraf seçiciyi açar).
- Tema: Canlı'da kart zemini vurgu renginden türetilen degrade + soluk nokta dokusu (mevcut `gradientTop` mantığı); Mono'da düz yüzey + nokta dokusu + ince kenarlık. Açık ve koyu modda metin kontrastı ≥ 4.5:1, damga/ikon ≥ 3:1.

## Telefonda kayıtlı kartlar

- Anahtar `known_accounts`: en çok 5 kayıt, en son giriş yapılan en üstte. Her kayıt: `userId`, `email`, `displayName`, `username`, `avatarUrl` (herkese açık URL), `memberSince` (profil `createdAt`), `lastSignedInAt`.
- Kart **yalnızca onboarding'i bitmiş** hesap için yazılır: onboarding bitince ya da onboarding'i bitmiş bir hesapla giriş yapılınca. Onboarding yarıda bırakılıp çıkış yapılırsa kart yazılmaz (yalnızca e-postalı yarım kart oluşmasın). *(Claude'un kararı)*
- `memberSince` sunucudan çekilmiş profilin `createdAt` değeridir; yerel satır henüz çekilmemişse kart tarihsiz yazılır ve ilk çekmeden sonra güncellenir.
- Oturum açıkken profil (ad, kullanıcı adı, fotoğraf) değiştikçe kayıt güncellenir.
- Giriş ekranı: e-posta alanı en son hesapla dolu gelir; e-posta değiştikçe (büyük/küçük harf duyarsız, kırpılmış) eşleşen kayıtlı kart gösterilir, eşleşme yoksa örnek kart. Kart geçişi kısa bir çapraz geçişle (~200 ms).
- Kartta "Bu telefondan kaldır" (uzun basma menüsü ya da küçük ⋯ düğmesi) kaydı siler.
- Hesap silinince o kayıt silinir. Çıkış yapmak kaydı silmez (amaç bu).

## Korunan davranış ve kurallar

- Şifre alanlarında göster/gizle; e-posta ve şifre alanlarında otomatik doldurma (`AutofillHints.email`, `.password`, `.newPassword`), kayıt ve girişte `AutofillGroup`.
- Google düğmesi Google'ın marka kurallarına uyar (resmi G logosu, renk değiştirilmez).
- Dokunma alanları ≥ 48 dp; klavye açılınca form kaydırılabilir kalır, kart küçülebilir/kaybolabilir ama düğme görünür kalır.
- Tüm metinler Türkçe; mevcut hata metinleri ve doğrulama kuralları (`auth_rules.dart`) değişmez.

## Kurucuya kalanlar

- Animasyon eğrileri ve sürelerin ince ayarı, kartın tam ölçüleri ve tipografisi (temanın display/number fontları kullanılır: Canlı'da Inter, Mono'da Space Grotesk + Doto).
- "Bu telefondan kaldır" etkileşiminin biçimi (uzun basma mı ⋯ mi).
- Android açılış (splash) ekranının arka plan rengini uygulama zeminiyle eşlemek (ikon zaten aynı).
- Testler: yönlendirme (kayıtlı kart var/yok → /giris ya da /hosgeldin), kayıtlı kart eşleşmesi ve güncellenmesi, hesap silmede kaldırma, kartın durumları (widget testi), azaltılmış hareket, mevcut auth testlerinin yeni yerleşime uyarlanması.
