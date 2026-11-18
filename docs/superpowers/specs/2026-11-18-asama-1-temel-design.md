# MissionFit Flutter · Aşama 1: Temel — Tasarım

Tarih: 2026-11-18 · Durum: onay bekliyor

## 1. Amaç ve neden

MissionFit (`~/projelerim/saglik-app`, Expo SDK 58 + Supabase), Flutter'da baştan yazılıyor. Yeniden yazmanın iki sebebi var:

1. **Daha profesyonel bir tasarım.** Değiştirilebilir temalar olacak: Nothing esintili **Mono** ve Spotify esintili **Canlı**. Bunlara antrenmanda gerçekten yardım eden, amaca duyarlı yeni özellikler eklenecek.
2. **Flutter tecrübesi kazanmak.** Kullanıcı ileride Windows ve Linux için masaüstü restoran/POS uygulamaları (AKINSOFT, Wolvox Restoran benzeri) yapacak. Bu projede kurulan mimari ve kazanılan alışkanlıklar oraya taşınacak.

MissionFit yalnızca **Android** için yapılıyor, masaüstü sürümü yok. Uygulama şimdilik yayınlanmayacak, kullanıcı kendisi kullanacak.

İş beş aşamaya bölündü: **1 Temel** → 2 Antrenman → 3 Kalori ve Görevler → 4 Akıllı içerik → 5 Rank. Her aşamanın kendi tasarım dokümanı ve planı var. Bu doküman yalnızca Aşama 1'i kapsıyor. Sonraki aşamaların kapsamı bu doküman için bağlam niteliğinde, ayrıntıları kendi dokümanlarında belirlenecek.

## 2. Hedefler

Aşama 1'in sonunda telefonda (Nothing Phone 2a) şunlar çalışıyor olacak:

- Kayıt, giriş, çıkış ve şifre sıfırlama. Mevcut Supabase projesi ve mevcut hesaplar kullanılacak.
- 6 adımlı onboarding. Akış RN'deki gibi olacak, araya bir **tema seçimi** adımı eklenecek.
- 5 sekmeli kabuk ve yüzen, hap şeklinde alt bar.
- Tema sistemi: Mono ve Canlı temaları, her birinin açık ve koyu sürümü, 10 vurgu rengi ve Telegram tarzı tema galerisi.
- **Profil sekmesinin tamamı**, RN'deki bütün özellikleriyle (bkz. §6.6).
- Telefon öncelikli veri katmanı: drift (SQLite) ve Supabase senkronu. Bütün kullanıcı tabloları ve kataloglar bu aşamada telefona iniyor, ekranları sonraki aşamalarda yazılacak olsa bile.
- RN'deki `src/domain` iş kuralları ve testleri saf Dart'a taşınmış ve tamamı geçiyor.
- Yeni uygulama ikonu.
- Herkese açık GitHub deposu `u1mx0d/missionfit-flutter`. Plan görevi başına bir commit atılıp pushlanacak.

## 3. Hedef olmayanlar (bu aşamada yok)

- Antrenman, Kalori ve Görevler ekranları. Bu sekmeler "yakında" boş durumu gösterecek.
- Bugün sekmesinin içeriği. Bu aşamada yalnızca selamlama ve tarih olacak. Asıl içerik ilgili modüller geldikçe eklenecek.
- Görev bildirimleri ve dinlenme sayacı bildirimleri. Bildirim kanalı ve izin altyapısı kurulacak, planlama Aşama 3'te yapılacak.
- Rank, akıllı içerik, grafikler ve yapay zekâ.
- iOS, masaüstü ve web.
- Uygulama mağazasında yayın.

## 4. Anti-hedefler (teknik olarak çalışsa bile başarısızlık sayılır)

- Ekranların Supabase'i ya da iş kurallarını doğrudan bilmesi. İş kuralı widget'a sızmamalı.
- Temaların renk değişikliğinden ibaret kalması. Ekranların temaya özel görünüm seçeneklerini (§6.2) desteklemeyen bir yapı kurulması.
- Hangi vurgu rengi seçilirse seçilsin yazının okunamaz hale gelmesi (WCAG AA altına düşmesi).
- İnternet yokken uygulamanın açılmaması ya da veri kaybetmesi.
- Geçiş süresince RN uygulamasının bozulması. İki uygulama aynı Supabase projesini kullanacak ve RN uygulaması Aşama 3 bitene kadar kullanılabilir kalmalı.
- Gizli anahtarların herkese açık depoya girmesi.

## 5. Kısıtlar

- Flutter 3.50.0 / Dart 3.14 (`~/development/flutter`). Android araç zinciri hazır. Test cihazı Nothing Phone 2a. Kullanıcı ilerlemeyi Android Studio'dan takip ediyor (Flutter eklentisi kurulu, hot reload ve Git sekmesi kullanılıyor).
- Mevcut Supabase projesi (Frankfurt, free plan). Migration'lar uygulandıktan sonra düzenlenmez, yalnızca yeni migration eklenir. Geri alma dosyaları `supabase/` altında. Supabase klasörü `saglik-app` deposunda duruyor (bkz. §6.4, kaynak tek yerde kalacak).
- **E-posta gönderimi Gmail SMTP'ye geçiyor (kullanıcının kararı):** Şu an kullanılan Resend, domain doğrulanmadığı için yalnızca hesap sahibinin adresine e-posta gönderiyor. Kullanıcının domaini yok. Bu yüzden Supabase'in özel SMTP ayarı Gmail'e çevrilecek: `smtp.gmail.com:587`, kullanıcının Gmail adresi ve bir uygulama şifresi (Google hesabında iki adımlı doğrulama açık olmalı). Bu yol ücretsiz, her adrese gönderebiliyor ve günde yaklaşık 500 e-posta sınırı var. Kurulumu kullanıcı panelden yapacak, plan bunu adım adım anlatan bir görev içermeli. Domain alınırsa yalnızca SMTP ayarı değişir, kod değişmez. Doğrulama ve sıfırlama **8 haneli kod** ile yapılmaya devam ediyor (uzak projede şema 6-10 haneyi kabul ediyor).
- Appwrite'a geçiş değerlendirildi ve reddedildi. Bütün arka ucu (şema, RLS, seed, Edge Function, testler) yeniden yazmayı gerektiriyor ve RN uygulamasını bozuyor.
- Para harcanmayacak: ücretli servis ya da LLM API kullanılmayacak.
- İstemcide yalnızca **publishable key** bulunacak.

## 6. Yaklaşımlar ve verilen kararlar

### 6.1 Veri katmanı yaklaşımı (kullanıcı seçti: B)

| | Yaklaşım | Artısı | Eksisi |
|---|---|---|---|
| A | RN'deki gibi: ekran doğrudan Supabase'den okur, son veri önbelleğe alınır, yazmalar kuyruğa girer | Bilinen ve kanıtlanmış bir yol, taşıması hızlı | Telefonda yalnızca son görülen veri var. Rank, grafik ve "geçen hafta / bu hafta" için geçmiş her seferinde sunucudan çekilmek zorunda, çevrimdışı çalışmaz |
| **B** | **Telefon öncelikli: drift (SQLite) tek doğruluk kaynağı, ekranlar yalnızca yerelden okur, Supabase arka planda senkron ve yedek** | Tamamen çevrimdışı çalışır, her dokunuş anında yansır, bütün geçmiş yerelde olduğu için rank ve karşılaştırmalar anında hesaplanır | Senkron motoru yazmak gerekiyor, Aşama 1 uzuyor |
| C | Hazır senkron servisi (PowerSync) | Senkron hazır geliyor | Dış servise bağımlılık ve ücret riski. Bu yüzden elendi |

Kullanıcı B'yi seçti. Gerekçe: Aşama 2-5'teki özelliklerin (akıllı öneri, kural tabanlı koç, rank, grafikler) hepsi yerelde duran geçmiş veriye dayanıyor.

### 6.2 Tema sistemi (kullanıcının kararları)

- **İki tema ailesi var:** **Mono** (Nothing esintili: siyah-beyaz, noktalı zemin, nokta-matris rakamlar için Doto, Space Grotesk, tek kırmızı vurgu #d71921) ve **Canlı** (Spotify esintili: koyu zemin, yeşil #1ed760, degrade kartlar, Inter). Her ailenin açık ve koyu sürümü var. Görsel referans: `.superpowers/brainstorm/` altındaki `tema-yonleri.html`.
- **Tema tanımı ekranlardan ayrı tutuluyor.** Tema; renkleri, yazı tiplerini, köşe yuvarlaklığını, kart stilini ve **görünüm seçeneklerini** tek bir `ThemeExtension` tanımında topluyor. Görünüm seçeneğine örnek: kalori Canlı'da halka, Mono'da büyük nokta-matris sayı ve çubukla gösterilir. Ekranlar yalnızca bu tanımı okuyor. Yeni bir tema eklemek = yeni bir tanım yazmak.
- **Vurgu rengi:** Kullanıcı yalnızca vurgu rengini değiştirebiliyor (seçenek A). Tema seçildikten sonra 10 hazır renkten biri seçiliyor. Butonlar, halkalar, grafikler ve alt bardaki hap bu renge geçiyor. Zemin ve yazı renkleri sabit kalıyor. Her renk her tema varyantı için bir ton çiftiyle tanımlanıyor (açık / koyu, vurgu üstündeki yazı rengi). Tüm paleti düzenleme seçeneği reddedildi.
- **Tema seçiminin yerleri:** Onboarding'de bir tema seçimi adımı var ve Canlı önceden seçili geliyor. Profil'de Telegram tarzı bir **Tema galerisi** var, temalar "Profesyonel" (Mono) ve "Eğlenceli" (Canlı) kategorilerine ayrılıyor. Seçim anında uygulanıyor, ekran yanıp sönmüyor.
- **Saklama:** Seçim yerelde hemen saklanıyor ve profil satırına senkronlanıyor (`profiles.theme` açık/koyu/sistem, yeni `theme_family` ve `accent_color` sütunları. Bkz. §6.4).

### 6.3 Gezinme (kullanıcının kararları)

- 5 sekme var: **Bugün** (Ana Sayfa), **Antrenman**, **Kalori**, **Görevler**, **Profil**.
- **Yüzen alt bar, aktif sekme hap şeklinde genişliyor:** Yalnızca aktif sekmenin adı yazıyor. Hap vurgu renginde. Sekme değiştirince hap kayarak genişliyor. Bar ekranın altında yüzüyor, içerik onun altından kaydırılabiliyor.
- Yönlendirme için go_router (`StatefulShellRoute`) kullanılacak. Her sekme kendi gezinme geçmişini koruyor. Oturum ve onboarding koruması yönlendirme seviyesinde yapılacak.

### 6.4 Senkron ve sunucu (Claude'un kararları)

- **Yerel veritabanı:** drift. RN'deki 8 kullanıcı tablosunun ve katalogların (kaslar, egzersizler, şablonlar, yemekler, görev önerileri) yerel aynası tutulacak. Yemek kataloğu (159 kayıt) tamamen indirilip yerelde aranacak. Arama, Türkçe karakter eşlemesi `normalize_search` ile aynı olacak şekilde yapılacak.
- **Gönderme (push):** RN'deki outbox mantığı (`outboxQueue.ts`) aynen taşınacak:
  - İşlemler anahtara göre birleştirilir: ekle sonra düzenle = tek upsert, ekle sonra sil = sil.
  - İstemcinin ürettiği uuid ile upsert yapılır, bu yüzden aynı işlemin tekrarı zararsızdır.
  - Geçici hatalarda 5/15/30/60 saniye arayla tekrar denenir. Kalıcı hata (SQLSTATE 22/23/42) olursa ya da 15 deneme dolarsa işlem bırakılır ve kullanıcıya bildirilir.
  - Yerel yazma ile outbox kaydı **aynı drift işleminde (transaction)** yapılır.
- **Çekme (pull):** Her tablo için `updated_at > imleç` sorgusu atılır, sayfa boyutu 1000. Çekme şu durumlarda tetiklenir: uygulama öne geldiğinde, gönderme bittikten sonra, çekip yenileme yapıldığında ve oturum açıldığında. Realtime kullanılmayacak (gerekçe RN'deki ile aynı).
- **Çakışma:** Son yazan kazanır, sunucunun `updated_at` değerine göre. Veri tek kullanıcıya ait olduğu için bu yeterli.
- **Yeni migration'lar (yalnızca ekleme, RN'yi bozmadan):**
  1. `updated_at` sütunu olmayan tablolara (`session_sets`, `favorite_foods`, `task_completions`) `updated_at` sütunu ve tetikleyicisi eklenecek.
  2. **Silme kayıtları:** `public.deletions(table_name, row_id, user_id, deleted_at)` tablosu ve her kullanıcı tablosunda `after delete` tetikleyicisi olacak. RLS ile her kullanıcı yalnızca kendi kayıtlarını okuyabilecek. Gerekçe: RN uygulaması kayıtları kalıcı olarak siliyor. Silme bilgisi tetikleyiciyle sunucuda tutulursa iki uygulama da değişmeden doğru senkronlanır. Silme kayıtları 90 günden eskiyse temizlenebilir. Telefon 90 günden uzun süre senkronsuz kalırsa tam yeniden indirme yapılır.
  3. **Tema için yeni sütunlar:** `profiles.theme_family` (`mono` | `canli`, varsayılan `canli`) ve `profiles.accent_color` (10 renkten biri, `check` kısıtıyla). Mevcut `theme` sütunu (`system` | `light` | `dark`) açık/koyu seçimi olarak aynı anlamda kullanılmaya devam edecek. Mevcut `accent` sütununa dokunulmayacak. Gerekçe: RN, `ACCENTS[accent]` ile okuyor ve bilmediği bir değer görürse çöker. Yeni sütunlar kullanılırsa RN etkilenmez. *(Claude'un kararı.)*
  4. `deletions.user_id` sütununa `auth.users`'a giden bir yabancı anahtar (FK) konmayacak. Hesap silinince zincirleme silme (cascade) sırasında oluşan silme kayıtları hata vermesin diye. Hesap silindiğinde bu kayıtlar ayrıca temizlenecek. *(Claude'un kararı.)*
- **Supabase kaynağı:** `supabase/` klasörü `saglik-app` deposunda kalacak ve yeni migration'lar oraya eklenecek. Tek kaynak orası olacak, iki depoda ayrı kopya tutulmayacak. Aşama 3 bitip RN emekliye ayrılınca klasör yeni depoya taşınabilir (bunu sonra konuşacağız).
- **Oturum:** supabase_flutter, oturum bilgisini flutter_secure_storage'da saklayacak. RN'de oturum Expo Go yüzünden şifresiz saklanıyordu, bu bir iyileştirme.
- **Ortam değişkenleri:** `--dart-define-from-file=env.json` kullanılacak. `env.json` git dışında tutulacak, depoya yalnızca `env.example.json` girecek.

### 6.5 Katmanlar (Claude'un kararı, kullanıcıya anlatıldı)

```
lib/
  domain/        saf Dart: iş kuralları (Flutter/drift/Supabase import YOK)
  data/          drift şeması + DAO'lar, senkron motoru (outbox + pull), Supabase istemcisi
  app/           Riverpod sağlayıcıları ve notifier'lar (React hook'larının karşılığı)
  ui/            tema, ortak bileşenler, ekranlar (yalnızca app/ katmanını kullanır)
```

- **Domain'in taşınması:** `saglik-app/src/domain` içindeki 10 algoritma (calories, workoutKcal, week/dates, muscleCoverage, feedback, food, nutrition, tasks, streak, home) ve yardımcıları (age, units, format, intensity) birebir taşınacak. Testleri de birebir taşınacak: aynı girdiler, aynı beklenen değerler. Algoritma tablosu: `saglik-app/src/domain/README.md`.
- **Özelliklere bağlı saf mantık:** `src/features/*` altında da saf mantık ve testler var (outboxQueue, activeSession, history, entries, notification planı gibi). Bunlar ilgili aşamada taşınacak. **Aşama 1'de outboxQueue** ve yerel saat dilimi ile gün mantığı (`useToday` karşılığı) taşınacak.
- Saat dilimi hesabı için `timezone` paketi kullanılacak (IANA). RN'deki Intl tabanlı yerel tarih mantığı aynı sonuçları vermeli, bunu taşınan testler doğrulayacak.

### 6.6 Aşama 1'deki ekranlar

- **Kimlik doğrulama:** Kayıt (e-posta, şifre, şifreyi göster/gizle), 8 haneli kodla e-posta doğrulama, giriş, şifremi unuttum (kod + yeni şifre). Kurallar RN ile aynı: en az 8 karakter, harf ve rakam içermeli.
- **Google ile giriş (kullanıcının kararı):** Giriş ve kayıt ekranlarında "Google ile devam et" düğmesi olacak. Telefondaki Google hesabıyla yerel (native) giriş yapılacak: `google_sign_in` paketi ve Supabase `signInWithIdToken`. Bu yol e-posta ve kod gerektirmiyor.
  - **Kurulum:** Google Cloud'da ücretsiz OAuth istemcileri açılacak: bir Web istemcisi (Supabase Google sağlayıcısına girilir) ve bir Android istemcisi (paket adı `com.alperen.missionfit` ve debug imza anahtarının SHA-1'i). Ardından Supabase panelinde Google sağlayıcısı açılacak. Bunları kullanıcı yapacak, plan adım adım anlatan bir görev içermeli.
  - **Aynı e-postayla iki giriş yolu:** E-postası doğrulanmış mevcut bir hesap aynı adresle Google'dan giriş yaparsa Supabase iki kimliği aynı kullanıcıda birleştirir. Planlayan kişi bunu yerelde doğrulamalı.
  - **Yeniden doğrulama:** Google ile giren kullanıcının şifresi yok. Şifre değiştirme ve hesap silme öncesindeki yeniden doğrulama, şifre yerine Google ile yeniden giriş yapılarak sağlanacak (taze token, ≤ 10 dk kuralı korunuyor). Şifre değiştirme seçeneği yalnızca e-posta kimliği olan kullanıcıya gösterilecek. *(Claude'un kararı.)*
- **Onboarding (RN'deki 6 adım ve tema adımı):** KVKK ve açık rıza (metin RN'den alınacak), 18+ kontrolü (tam doğum tarihi sorulur, yalnızca doğum yılı saklanır), vücut bilgileri ve hedef, kalori önizlemesi, bildirim izni ve tema seçimi. Onboarding bayrağı yerelde de tutulur, böylece çevrimdışı açılışta kullanıcı onboarding'e geri atılmaz.
- **Kabuk:** 5 sekme ve yüzen bar. Bugün sekmesinde selamlama ve tarih var. Diğer üç sekmede, temaya uygun bir "yakında" boş durumu var.
- **Profil (RN'deki her şey):** Vücut ve hedef düzenleme (otomatik ya da elle hedef, alt sınır engeli), Tema galerisi ve vurgu rengi, kg/lb, hafta başlangıcı, saat dilimi, bildirim ayarları ve izin durumu, şifre değiştirme (mevcut şifreyle yeniden doğrulama), JSON dışa aktarma (8 tablo, paylaşma menüsüyle), hesap silme (`delete-account` Edge Function, mevcut şifreyle yeniden doğrulama, token ≤ 10 dk) ve çıkış (yalnızca bu cihazdan, yerel veri ve outbox temizlenir).
- **Bildirim altyapısı:** flutter_local_notifications kurulacak. `tasks` kanalı (önem: yüksek) oluşturulacak ve izin istenecek. Tam zamanlı alarm izni (`SCHEDULE_EXACT_ALARM`) manifest'e eklenecek. Planlama Aşama 3'te yapılacak.
- **Uygulama ikonu:** Temaya uygun, özgün bir ikon tasarlanacak (adaptive icon, Mono için de uyumlu monokrom sürümüyle). Bildirim ikonu da yenilenecek.

### 6.7 Test ve doğrulama

- **Domain:** Taşınan bütün testler geçecek. Test sayısı, RN'deki karşılık gelen testlerle aynı olacak.
- **Kontrast:** Her tema × açık/koyu × 10 vurgu rengi kombinasyonu WCAG AA testinden geçecek (RN'deki `contrast.test.ts`'in karşılığı).
- **Senkron:** Outbox birleştirme testleri taşınacak. Gönderme ve çekme döngüsü, sahte bir uzak sunucuyla test edilecek. Yerelde (Docker Supabase) iki kullanıcıyla uçtan uca deneme yapılacak, RLS sızıntısı olmadığı doğrulanacak. Yeni migration'lar için pgTAP testleri yazılacak.
- **Widget testleri:** Tema değişimi, alt bardaki hap ve yönlendirme korumaları.
- **Cihaz testi:** Nothing Phone 2a'da kayıt ve giriş, onboarding, tema ve renk değişimi, çevrimdışı açılış, RN uygulamasında yapılan bir değişikliğin (ekleme ve silme) Flutter'a gelmesi, hesap silme.

### 6.8 Git

- `missionfit-flutter` klasörü git deposu olacak. Herkese açık GitHub deposu `u1mx0d/missionfit-flutter` açılacak, `gh` ile bağlı hesap kullanılacak.
- `.gitignore` şunları içerecek: `.superpowers/`, `env.json`, yerel derleme çıktıları ve `backups/`.
- İlk commit bu doküman olacak. Sonra plan görevi başına, testler geçtikten sonra bir commit atılıp pushlanacak.
- `saglik-app` deposundaki yeni migration'lar o deponun kendi akışıyla commit edilecek.

## 7. Planlayana bırakılanlar

- Paket sürümleri. Flutter 3.50 ile uyumlu, kararlı sürümler seçilmeli.
- `lib/` altındaki ayrıntılı klasör ve dosya yapısı.
- Tema belirteçlerinin kesin değerleri (`tema-yonleri.html` taslağından türetilecek) ve 10 vurgu renginin seçimi.
- Animasyonların süreleri ve eğrileri.
- Drift şemasının sütun düzeyindeki ayrıntıları. Şema, sunucu şemasını izlemeli.
- Senkron imlecinin ve outbox'ın tablo yapısı.

## 8. Sonraki aşamalar için notlar (bu aşamada yapılmayacak)

- **Aşama 2 (Antrenman):** Odak modu (yalnızca o anki egzersiz ve set, değerler önceden dolu, –/+ düğmeleri, tek tuşla tamamlama), tam ekran ve kilit ekranında akan dinlenme sayacı, akıllı ağırlık önerisi, rekor kutlaması, calisthenics desteği (ek ağırlıklı vücut ağırlığı, tutuş süresi, ilerleme basamakları).
- **Aşama 3:** Kalori ve Görevler RN'deki haliyle, yeni tasarımla taşınacak. Görev bildirimleri planlanacak.
- **Aşama 4 (Akıllı içerik):** Amaç seçimi (calisthenics, fonksiyonel, kas kütlesi, kilo verme vb.), egzersizin amaca faydasını anlatan metinler, dinlenme ekranında "geçen hafta / bu hafta" motivasyon mesajları, ilerleme grafikleri. Önce kurallarla (A), sonra yapay zekâ koçuyla (B). Mimari, B'nin sonradan eklenmesine izin verecek şekilde kurulacak.
- **Aşama 5 (Rank):** Genel rank ve 6 bölge rankı, kademeli ilerleme, yumuşak düşüş. Görünüşe değil, sağlıklı aralığa yaklaşmaya ve tutarlılığa bağlı olacak. Şimdilik kişisel, ileride sıralama tablosuna kapı açık. Fotoğraftan rank vermek yapay zekâ aşamasında.
