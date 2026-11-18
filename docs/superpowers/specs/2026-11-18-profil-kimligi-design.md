# MissionFit Flutter · Profil kimliği (görünen ad, kullanıcı adı, fotoğraf) — Tasarım

Tarih: 2026-11-18. Durum: onay bekliyor (gözden geçirici kontrolü yapıldı). Aşama 1'in (Temel) üstüne eklenen küçük bir iş paketi; Aşama 2'den önce yapılır.

## 1. Amaç ve neden

Profil ekranının üstünde şu an sabit bir "Profil" başlığı ve altında e-posta var. Kullanıcı bunun yerine
kendi **fotoğrafını, görünen adını ve `@kullaniciadi`'nı** görmek ve değiştirebilmek istiyor.

Neden (kullanıcının sözleri): kullanıcı deneyimini geliştirmek; ayrıca bu bilgiler **ileride başkalarına
görünecek** (Aşama 5 rank sıralaması / arkadaşlar). Bu yüzden kullanıcı adı benzersiz olmalı.

## 2. Hedefler

- Profil başlığı: fotoğraf (yoksa baş harfler), görünen ad, altında `@kullaniciadi`.
- Görünen ad, kullanıcı adı ve fotoğraf değiştirilebilir (profil düzenleme ekranı).
- Onboarding'e yeni bir **"Profilin"** adımı: görünen ad + kullanıcı adı zorunlu, fotoğraf isteğe bağlı.
- Google ile girende ad ve fotoğraf Google'dan önceden dolar; kullanıcı adı addan/e-postadan önerilir.
- Kullanıcı adı yazılırken anında "✓ uygun / ✗ alınmış / ✗ geçersiz" geri bildirimi.
- Veri modeli ileride başkalarının bu üç bilgiyi okuyabilmesine hazır.

## 3. Hedef olmayanlar

- Başkalarının profilini görme, sıralama ekranı, arkadaş ekleme.
- Kullanıcı adı değiştirme sıklığına sınır, eski adların korunması/yönlendirilmesi.
- Fotoğraf için çevrimdışı yükleme kuyruğu (bkz. 6.1).
- Fotoğraf moderasyonu.

## 4. Anti-hedefler

- İki hesabın aynı kullanıcı adını (büyük/küçük harf farkıyla bile) alabilmesi.
- Kullanıcı adı alanını yerel önbellekten / outbox'tan sunucuya yazmaya çalışıp senkronun bozulması.
- Profil fotoğrafının herkese açık olmasıyla birlikte diğer profil verilerinin (kilo, yaş vb.) de açılması.
- Eski RN uygulamasının (aynı Supabase projesi) bozulması.
- Hesap silindiğinde fotoğraf dosyasının Storage'da sahipsiz kalması.

## 5. Kısıtlar

- Supabase projesi ve migration'lar `~/projelerim/saglik-app/supabase` altında; şema değişikliği yalnızca
  **ekleme** olmalı (RN istemcisi de aynı tabloyu kullanıyor).
- `profiles` güncellemesi sütun bazlı `grant update (...)` ile kısıtlı; outbox profil yükü (`Profile.toPayload`)
  tam satır gönderiyor.
- Uygulama yerel öncelikli (drift). Yerel `profiles` tablosu sunucu şemasının aynası; drift şeması şu an
  `schemaVersion => 1`.
- Benzersizlik yalnızca sunucuda garanti edilebilir → kullanıcı adı işlemleri internet ister.

## 6. Yaklaşımlar ve kararlar

### 6.1 Fotoğrafın saklanması (kullanıcı seçti: 1)

1. **Kayıt internet ister (seçildi).** Kaydet'e basınca fotoğraf hemen Storage'a yüklenir; bağlantı yoksa
   "İnternet bağlantısı gerekiyor" denir ve hiçbir şey değişmez. Yüklenen fotoğraf telefonda önbelleğe alınır,
   çevrimdışı da görünür. Basit; kullanıcı adı zaten internet istediği için tutarlı.
2. Çevrimdışı kaydet, sonra yükle. Senkron motoruna dosya yükleme eklemeyi ve yarım yükleme / sürüm çakışması
   uç durumlarını gerektirir; seyrek yapılan bir işlem için fazla iş. Reddedildi.
3. Fotoğrafı veritabanına (base64) gömmek: tabloyu şişirir, her senkronda taşınır. Elendi.

### 6.2 Ad alanları (kullanıcı seçti: A)

Görünen ad (serbest) + kullanıcı adı (benzersiz), Instagram/Spotify tarzı. Yalnızca kullanıcı adı (B) reddedildi.

### 6.3 Kullanıcının onayladığı kurallar

- Onboarding'de görünen ad ve kullanıcı adı zorunlu, fotoğraf isteğe bağlı.
- Mevcut hesaplarda kullanıcı adı yoksa profil başlığında "Kullanıcı adı seç" düğmesi çıkar (onboarding
  tekrar açılmaz).
- Kullanıcı adı kuralları: 3–20 karakter; yalnızca `a-z`, `0-9`, `_`, `.`; küçük harfe çevrilir; Türkçe harfler
  çevrilir (ç→c, ğ→g, ı→i, ö→o, ş→s, ü→u, İ→i); büyük/küçük harf farkı yok sayılır.
- Fotoğraf: galeri veya kamera, kare kırpma, ~512 px'e küçültme (JPEG). Fotoğraf yoksa baş harfler vurgu
  renginde daire içinde. Fotoğraf kaldırılabilir.
- Fotoğraf bağlantısı herkese açık; diğer profil verileri yalnızca sahibinde.

### 6.4 Sunucu (Claude'un kararları)

Yeni migration (`saglik-app/supabase/migrations/<tarih>_profile_identity.sql`), yalnızca ekleme:

- `profiles.username text` — boş bırakılabilir; `check (username ~ '^[a-z0-9_.]{3,20}$')`;
  `create unique index profiles_username_key on profiles (username)` (küçük harf zorunlu olduğundan
  `lower()` gerekmez).
- `profiles.avatar_path text` — boş bırakılabilir; Storage nesne yolu; `check (avatar_path like user_id::text || '/%')`.
  Tam URL değil yol saklanır: istemci herkese açık URL'yi yoldan üretir; başkasının URL'si yazılamaz.
- **İkisi de `grant update (...)` listesine eklenmez.** Yalnızca güvenlikli (security definer, `search_path = ''`)
  RPC'lerle değişir:
  - `username_available(p text) returns boolean` — biçim geçersizse ya da alınmışsa (kendi adı hariç) false.
    RLS diğer profilleri gizlediği için RPC gerekir.
  - `set_username(p text) returns text` — biçimi ve ayrılmış adları doğrular, `auth.uid()` satırına yazar;
    alınmışsa ayırt edilebilir bir hata (`unique_violation` → istemcide "alınmış") döner; kaydedilen adı döner.
  - `set_avatar_path(p text) returns void` — `null` (kaldır) ya da `auth.uid()/...` ile başlayan yol.
- Ayrılmış adlar (Claude'un kararı): `admin`, `missionfit`, `support`, `destek`, `root`, `null`, `system`.
- Storage: herkese açık `avatars` bucket'ı. Politikalar: `authenticated` kullanıcı yalnızca
  `(storage.foldername(name))[1] = auth.uid()::text` olan nesneleri ekler/günceller/siler; okuma herkese açık.
  Dosya boyutu sınırı 2 MB, yalnızca `image/jpeg`. Bucket herkese açık olduğu için geniş bir SELECT politikası
  **eklenmez** (herkese açık URL'ler politika gerektirmez; böylece kimse tüm klasörleri listeleyemez).
- Dosya adı her yüklemede yeni: `<uid>/<unix-ms>.jpg` (önbellek kırma). Yeni yol kaydedildikten sonra eski dosya
  silinir (en iyi çaba; başarısızsa sorun değil).
- `delete-account` fonksiyonu: hesabı silmeden önce `avatars/<uid>/` altındaki tüm nesneleri siler, sonra
  yeniden deploy edilir. **Fotoğraf silme başarısız olursa hesap silinmez** (Claude'un kararı): fonksiyon hata
  döner, uygulama mevcut hata durumunu gösterir ("Hesap silinemedi, tekrar dene"). Sebep: herkese açık bir
  fotoğrafın sahipsiz kalması anti-hedef; Storage hataları geçicidir ve kullanıcı tekrar deneyebilir.
- `deletions` tablosu / tetikleyici değişmez (profil satırı silinmiyor).

### 6.5 İstemci (Claude'un kararları)

- **Yerel şema:** drift `Profiles` tablosuna `username` ve `avatarPath` (boş bırakılabilir) eklenir;
  `schemaVersion` 2'ye çıkar, `onUpgrade` iki sütunu ekler. Senkron çekme bu sütunları adla eşler.
- **Outbox'tan hariç:** `Profile.toPayload()` `username` ve `avatar_path`'i göndermez (yoksa sütun izni yüzünden
  her profil push'u reddedilir). `toRow`/`fromServer`/`toCompanion` içerir.
- **Görünen ad:** mevcut `display_name` alanı, mevcut outbox yoluyla (çevrimdışı da çalışır). 1–40 karakter,
  baş/son boşluk kırpılır.
- **Akışlar:** RPC başarılı olunca dönen değer yerel profil satırına hemen yazılır (sonraki çekmeyi beklemeden).
  Sıra: fotoğraf → yükle → `set_avatar_path` → yerel satır → eski dosyayı sil.
- **Hata dili:** çevrimdışı → "İnternet bağlantısı gerekiyor."; alınmış → "Bu kullanıcı adı alınmış.";
  geçersiz → kurala özel mesaj.
- **Uygunluk kontrolü:** yazarken ~400 ms bekleyip `username_available`; önce yerelde biçim kontrolü yapılır
  (biçim geçersizse sunucuya sorulmaz). Sonuç yarışında yalnızca son isteğin cevabı gösterilir.
- **Öneri:** Google'daki ad → çevrilmiş/temizlenmiş kullanıcı adı (ör. "Alperen Dağtekin" → `alperendagtekin`,
  20 karaktere kesilir); ad yoksa e-postanın `@` öncesi. Alınmışsa sonuna 2 haneli sayı eklenip birkaç kez
  denenir (sayı eklenince de 20 karakteri geçmeyecek şekilde kesilir). Google adı 40 karaktere kesilir. Öneri alanı doldurur, kullanıcı değiştirebilir.
- **Google ön doldurma:** Supabase kullanıcısının `user_metadata`'sındaki `full_name`/`name` ve
  `avatar_url`/`picture`. Fotoğraf seçili gelir; onboarding bitince indirilip aynı yoldan bizim bucket'a yüklenir
  (Google URL'sine bağımlı kalınmaz). Kullanıcı kaldırabilir.
- **Onboarding:** "Profilin" adımı onay (consent) adımından hemen sonra gelir; adım sayısı 7 → 8. Kullanıcı adı
  bu adımda (ileri'ye basınca) `set_username` ile alınır, böylece onboarding sonunda çakışma çıkmaz.
  Fotoğraf yüklemesi onboarding bitişinde yapılır; yükleme başarısız olursa onboarding yine tamamlanır,
  kullanıcıya fotoğrafı profilden ekleyebileceği söylenir.
- **Profil ekranı:** başlık = avatar (dokununca düzenleme), görünen ad, `@kullaniciadi`. Görünen ad ya da
  kullanıcı adı eksikse (Aşama 1'de onboarding'i bitirmiş hesaplar) tek bir **"Profilini tamamla"** düğmesi
  düzenleme ekranını açar (onaylanan "Kullanıcı adı seç" düğmesinin genişletilmiş hali; Claude'un kararı).
  Başlık satırı: görünen ad → yoksa `@kullaniciadi` → yoksa "Profil". Google hesabıysa düzenleme ekranı ad ve
  fotoğrafı Google'dan önceden doldurur. E-posta başlıktan kalkar, hesap bölümünde (ör. "E-posta" satırı) görünür.
- **Profil düzenleme ekranı:** avatar (değiştir / kaldır), görünen ad, kullanıcı adı (canlı kontrol), Kaydet.
  Kaydet kuralları (Claude'un kararı):
  - Önce tüm alanlar yerelde doğrulanır; biri geçersizse hiçbir şey kaydedilmez.
  - Kullanıcı adı ya da fotoğraf değiştiyse ve internet yoksa **hiçbir şey kaydedilmez** (görünen ad dahil);
    "İnternet bağlantısı gerekiyor." Yalnızca görünen ad değiştiyse çevrimdışı da kaydedilir (outbox).
  - Sıra: `set_username` → fotoğraf yükle + `set_avatar_path` → görünen ad (outbox). Her adım başarılıysa
    sonrakine geçilir.
  - Kullanıcı adı kaydedilip fotoğraf başarısız olursa kullanıcı adı kalır, görünen ad yine kaydedilir; ekranda
    "Fotoğraf yüklenemedi, tekrar dene." gösterilir ve ekran açık kalır (geri alma yok).
  - Kullanıcı adı alınmışsa (yarış) hiçbir şey kaydedilmez, alanın altında "Bu kullanıcı adı alınmış." çıkar.
- **Avatar bileşeni:** tek ortak widget (boyut parametreli): yol varsa herkese açık URL'den önbellekli görüntü,
  yoksa/yüklenemezse baş harfler (görünen addan; yoksa kullanıcı adından; yoksa "?").
- **Dışa aktarma:** JSON'a `username`, `display_name`, `avatar_path` eklenir.
- **Paket seçimi** (planlayanın kararı, öneri): `image_picker`, `image_cropper` (kırpma + boyut/sıkıştırma),
  `cached_network_image`. Kamera izni yalnızca kamera seçilince istenir.

### 6.6 Test ve doğrulama

- Saf Dart: kullanıcı adı normalleştirme/doğrulama/öneri üretimi, baş harf üretimi (birim testleri).
- `Profile.toPayload` iki alanı içermiyor; `fromServer` okuyor (birim testi).
- drift v1 → v2 göçü (veri kaybı yok).
- Widget testleri: onboarding "Profilin" adımı (zorunlu alanlar, alınmış ad), profil başlığı (fotoğraflı /
  fotoğrafsız / profil eksik → "Profilini tamamla"), düzenleme ekranı (çevrimdışı + kullanıcı adı değişikliği →
  hiçbir şey kaydedilmez; yalnızca görünen ad → çevrimdışı kaydedilir; fotoğraf hatası → kullanıcı adı kalır).
- `delete-account`: fotoğraf silme hatasında hesabın silinmediği.
- Sunucu: migration yerel Supabase'de uygulanır; RPC'ler (iki hesapla aynı ad, büyük harf, geçersiz biçim,
  ayrılmış ad), Storage politikaları (başkasının klasörüne yazamama) elle ya da SQL testiyle doğrulanır.
- Cihaz: Nothing Phone 2a'da galeri/kamera/kırpma, Google ön doldurma, hesap silince dosyanın gitmesi.

## 7. Planlayana bırakılanlar

- Widget yerleşimi, boşluklar ve animasyonlar (tema tanımını kullanarak).
- RPC'lerin istemci tarafı sarmalayıcısının yeri (ör. `ProfileIdentityRepository`).
- `image_cropper` Android yapılandırması (manifest'teki UCrop aktivitesi, tema renkleri).
- Görev sırası ve hangi görevlerin yardımcı ajanla yapılacağı (veri/sunucu görevleri: yazıcı + kontrolcü).

## 8. Sonrası için notlar

- Aşama 5 sıralaması için: başkalarının yalnızca `username`, `display_name`, `avatar_path` alanlarını
  okuyabileceği bir görünüm (view) ya da RPC eklenir; `profiles` RLS'i gevşetilmez.
- Kullanıcı adı değiştirme sınırı ve kötüye kullanım kontrolleri yayın öncesi düşünülmeli.
