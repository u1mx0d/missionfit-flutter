# Profil kimliği (görünen ad, kullanıcı adı, fotoğraf) — Uygulama planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Profil başlığında fotoğraf + görünen ad + benzersiz `@kullaniciadi`; düzenleme ekranı ve onboarding "Profilin" adımı.

**Architecture:** Sunucuda `profiles.username` / `profiles.avatar_path` yalnızca güvenlikli RPC'lerle değişir, fotoğraflar herkese açık `avatars` bucket'ında. İstemcide iki sütun yerel drift aynasına eklenir ama outbox yüküne girmez; çevrimiçi işlemler `ProfileIdentityRepository` üzerinden yapılır ve sonucu yerel satıra hemen yazılır. Görünen ad mevcut outbox yolunu kullanır.

**Tech Stack:** Flutter 3.50 / Dart 3.14, Riverpod 3, go_router, drift, supabase_flutter; yeni paketler `image_picker`, `image_cropper`, `cached_network_image`, `http`. Sunucu: Supabase (Postgres + Storage + Deno Edge Function), pgTAP.

**Spec:** `docs/superpowers/specs/2026-11-18-profil-kimligi-design.md`

## Global Constraints

- Sunucu değişiklikleri `~/projelerim/saglik-app/supabase` altında, yalnızca **ekleme**; RN istemcisi bozulmaz (`npm test` saglik-app'te geçmeye devam eder).
- Kullanıcı adı: 3–20 karakter, `^[a-z0-9_.]{3,20}$`; Türkçe çeviri ç→c, ğ→g, ı→i, ö→o, ş→s, ü→u, İ→i; küçük harf.
- Ayrılmış adlar: `admin`, `missionfit`, `support`, `destek`, `root`, `null`, `system`.
- Görünen ad: kırpılmış 1–40 karakter. Google adı 40 karaktere kesilir.
- Fotoğraf: kare, 512 px, JPEG; bucket sınırı 2 MB, yalnızca `image/jpeg`; yol `<uid>/<unix-ms>.jpg`.
- Hata metinleri (aynen): "İnternet bağlantısı gerekiyor.", "Bu kullanıcı adı alınmış.", "Fotoğraf yüklenemedi, tekrar dene."
- `username` ve `avatar_path` `grant update` listesine eklenmez; `Profile.toPayload()` bu iki alanı göndermez.
- Kod biçimi: `dart format` (sayfa genişliği 100, `analysis_options.yaml`'da). `flutter analyze` temiz, tüm testler geçer.
- Her görev sonunda commit + push (`main`).
- Uzak veritabanına push ve fonksiyon deploy'u **kullanıcı onayıyla** (Görev 7).

## Review Focus

1. Türkçe büyük harfle yazılan ad ("Şükrü.K") alanda anında `sukru.k` olur → Görev 3 (`normalizeUsername`) ve Görev 5 (`UsernameField`) testleri.
2. Hızlı yazarken eski bir uygunluk cevabı yenisinin üstüne yazılmaz → Görev 5 `UsernameField` testi.
3. Seçici/kırpıcı iptal edilirse hiçbir şey değişmez ve hata gösterilmez → Görev 5 düzenleme ekranı testi.
4. Kullanıcı adı alındıktan sonra yapılan normal bir profil güncellemesi (ör. kilo) kullanıcı adını yerelde silmez → Görev 4 testi.
5. Google adı yalnızca Latin dışı karakter/emoji ise ("李 🙂") öneri boş kalmaz (`sporcu`) → Görev 3 testi.

---

## Dosya haritası

| Dosya | Sorumluluk |
|---|---|
| `saglik-app/supabase/migrations/20261119120000_profile_identity.sql` (yeni) | sütunlar, indeks, RPC'ler, bucket + politikalar |
| `saglik-app/supabase/tests/profile_identity.test.sql` (yeni) | pgTAP |
| `saglik-app/supabase/functions/delete-account/index.ts` | silmeden önce avatar temizliği |
| `lib/data/db/tables.dart`, `database.dart` (+ `.g.dart`) | v2 şeması, göç |
| `lib/data/profile/profile_repository.dart` | `Profile.username/avatarPath`, yük hariç tutma |
| `lib/domain/username.dart` (yeni) | saf kurallar: normalleştirme, doğrulama, öneri, baş harfler |
| `lib/data/profile/profile_identity_repository.dart` (yeni) | RPC + Storage + yerel yazım |
| `lib/data/profile/avatar_picker.dart` (yeni) | galeri/kamera + kırpma + 512 px JPEG |
| `lib/app/providers.dart`, `lib/app/profile_controller.dart` | yeni sağlayıcılar |
| `lib/ui/components/mf_avatar.dart` (yeni) | ortak avatar |
| `lib/ui/profile/username_field.dart` (yeni) | canlı kontrollü kullanıcı adı alanı |
| `lib/ui/profile/avatar_source_sheet.dart` (yeni) | Galeri / Kamera / Kaldır |
| `lib/ui/profile/profile_header.dart` (yeni), `profile_screen.dart` | başlık |
| `lib/ui/profile/edit_profile_screen.dart` (yeni), `profile_routes.dart` | düzenleme (`/profil/duzenle`) |
| `lib/ui/onboarding/identity_step.dart` (yeni), `onboarding_flow.dart`, `onboarding_draft.dart`, `lib/app/onboarding_controller.dart` | "Profilin" adımı |

---

### Task 1: Sunucu — şema, RPC'ler, Storage, hesap silme (yardımcı ajan + kontrolcü)

**Files:**
- Create: `~/projelerim/saglik-app/supabase/migrations/20261119120000_profile_identity.sql`
- Create: `~/projelerim/saglik-app/supabase/tests/profile_identity.test.sql`
- Modify: `~/projelerim/saglik-app/supabase/functions/delete-account/index.ts`

**Interfaces:**
- Produces (Görev 4 kullanır):
  - `public.username_available(p_username text) returns boolean`
  - `public.set_username(p_username text) returns text` — geçersiz/ayrılmış: `errcode = '22023'`; alınmış: `unique_violation` (`23505`).
  - `public.set_avatar_path(p_path text) returns void` — `null` ya da `auth.uid()::text || '/'` ile başlayan; aksi `22023`.
  - Bucket `avatars` (public, `file_size_limit = 2097152`, `allowed_mime_types = '{image/jpeg}'`).

- [ ] **Step 1: pgTAP testini yaz** (`profile_identity.test.sql`, `sync_support.test.sql` kalıbıyla; A, B kullanıcıları):
  - `has_column` `profiles.username`, `profiles.avatar_path`.
  - A olarak `set_username('alperen')` → `'alperen'` döner; `username_available('alperen')` A için true, B için false.
  - B olarak `set_username('alperen')` → `throws_ok(..., '23505')`.
  - `set_username('Alperen')`, `('ab')`, `('a b')`, `('admin')` → `throws_ok(..., '22023')`.
  - `username_available('ab')` → false.
  - B olarak `update profiles set username='x' where user_id=B` → `throws_ok(..., '42501')`.
  - `set_avatar_path(A||'/1.jpg')` başarılı; `set_avatar_path(B||'/1.jpg')` A olarak → `22023`; `set_avatar_path(null)` başarılı.
  - A olarak `insert into storage.objects (bucket_id, name, owner) values ('avatars', B||'/x.jpg', A)` → `42501`; kendi klasörüne → başarılı.
  - B olarak `select count(*) from storage.objects where bucket_id='avatars'` → 0 (listeleme yok).
- [ ] **Step 2:** `cd ~/projelerim/saglik-app && npm run db:start && npm run db:test` → yeni test FAIL (sütun yok).
- [ ] **Step 3: Migration'ı yaz.** Sütunlar + check'ler (spec 6.4), `create unique index profiles_username_key on public.profiles (username)`; üç RPC `language plpgsql security definer set search_path = ''`, `revoke all ... from public, anon` + `grant execute ... to authenticated`; bucket `insert ... on conflict do nothing`; `storage.objects` için `authenticated` INSERT/UPDATE/DELETE politikaları `bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text`. **SELECT politikası yok.**
- [ ] **Step 4:** `npm run db:reset && npm run db:test` → tüm pgTAP PASS; `npm run db:advisors` yeni uyarı yok; `npm test` (RN) 299/299.
- [ ] **Step 5: `delete-account`:** `getUser` + iat kontrolünden sonra, `deleteUser`'dan önce `admin.storage.from('avatars').list(uid)` ve varsa `remove([...])`; herhangi bir hata → `console.error('delete-account: avatar cleanup failed')` + `json({ error: 'avatar_cleanup_failed' }, 500)` ve **kullanıcı silinmez**. İstemci 500'ü zaten `DeleteAccountFailure.failed` olarak gösteriyor; istemci değişikliği yok.
- [ ] **Step 6:** `npx supabase functions serve delete-account` ile yerelde bir kullanıcı + avatar dosyasıyla çağır → dosya ve kullanıcı gider (elle; sonucu commit mesajına yaz).
- [ ] **Step 7: Commit** (saglik-app deposunda, yerel; push ve uzak işlemler Görev 7'de):
  `git add supabase && git commit -m "feat(db): profil kimliği — kullanıcı adı, avatar, storage"`

### Task 2: Yerel şema v2 ve `Profile` alanları (yardımcı ajan + kontrolcü)

**Files:**
- Modify: `lib/data/db/tables.dart`, `lib/data/db/database.dart` (+ `build_runner` ile `database.g.dart`)
- Modify: `lib/data/profile/profile_repository.dart`
- Test: `test/data/db/database_test.dart`, `test/data/profile/profile_repository_test.dart`, `test/data/export/export_service_test.dart`

**Interfaces:**
- Produces: `Profiles.username` (`TextColumn`, nullable), `Profiles.avatarPath` (nullable, sütun `avatar_path`); `Profile.username`, `Profile.avatarPath` (`String?`); `AppDatabase.schemaVersion == 2`.

- [ ] **Step 1: Testler:**
  - `test('v1 veritabanı v2ye göçer, profil satırı korunur')`: geçici dosyada v1 `profiles` tablosunu ham SQL ile kur + `PRAGMA user_version = 1` + bir satır; `AppDatabase.forTesting(NativeDatabase(file))` ile aç → satır var, `username` ve `avatar_path` null.
  - `test('toPayload kullanıcı adı ve avatarı göndermez')`: `expect(p.toPayload().containsKey('username'), isFalse)`, aynısı `avatar_path`.
  - `test('fromServer kullanıcı adı ve avatar yolunu okur')`: `{'user_id':'u1','username':'alp','avatar_path':'u1/1.jpg'}` → alanlar dolu; `toRow()` ikisini içerir.
  - Dışa aktarma (yerel yedek yolu): satırda `username` olan profil → JSON'da `username` var.
- [ ] **Step 2:** `flutter test test/data` → yeni testler FAIL.
- [ ] **Step 3:** Sütunları ekle, `schemaVersion => 2`, `MigrationStrategy(onCreate: (m) => m.createAll(), onUpgrade: (m, from, to) async { if (from < 2) { addColumn ×2 } })`; `Profile` alanları `fromRow/fromServer/toRow/toCompanion`'a eklenir, `toPayload()` ikisini çıkarır. `copyWith`'e **eklenmez** (outbox yolundan değişmesin). `dart run build_runner build -d`.
- [ ] **Step 4:** `flutter analyze && flutter test` → hepsi PASS.
- [ ] **Step 5: Commit** `feat(db): yerel profil şeması v2 (kullanıcı adı, avatar yolu)`

### Task 3: Kullanıcı adı kuralları (saf Dart)

**Files:** Create `lib/domain/username.dart`; Test `test/domain/username_test.dart`

**Interfaces — Produces:**
- `const Set<String> reservedUsernames`
- `String normalizeUsername(String input)` — trim, Türkçe çeviri, küçük harf (geçersiz karakterleri **silmez**).
- `String? validateUsername(String normalized)` — `null` ya da: "En az 3 karakter.", "En fazla 20 karakter.", "Yalnızca harf, rakam, _ ve . kullanılabilir.", "Bu kullanıcı adı kullanılamaz."
- `String usernameBase({String? fullName, String? email})` — addan (yoksa e-posta `@` öncesinden) çeviri + küçük harf + geçersizleri sil, 20'ye kes; 3'ten kısaysa `'sporcu'`.
- `String usernameWithSuffix(String base, int n)` — `base` 18'e kesilir + `n` iki haneli (`05`).
- `String? validateDisplayName(String input)` — kırpılmış boşsa "Adını yaz.", 40'tan uzunsa "En fazla 40 karakter."
- `String initialsFor({String? displayName, String? username})` — addan en çok 2 baş harf (büyük), yoksa kullanıcı adının ilk harfi, yoksa `'?'`.
- `String googlePhotoAt512(String url)` — sondaki `=s<n>-c` → `=s512-c`; yoksa olduğu gibi.

- [ ] **Step 1: Testler:** `normalizeUsername('Şükrü.K ') == 'sukru.k'`, `normalizeUsername('İLKER') == 'ilker'`; `validateUsername('ab')` kısa; 21 karakter uzun; `'a b'` geçersiz karakter; `'admin'` ayrılmış; `'alp_34.x'` null; `usernameBase(fullName: 'Alperen Dağtekin') == 'alperendagtekin'`; `usernameBase(fullName: '李 🙂') == 'sporcu'`; `usernameBase(email: 'ali.k@x.com') == 'ali.k'`; `usernameWithSuffix('a' * 20, 7) == 'a' * 18 + '07'`; `initialsFor(displayName: 'alperen dağtekin') == 'AD'`; `initialsFor(username: 'zed') == 'Z'`; `initialsFor() == '?'`; `googlePhotoAt512('https://x/a=s96-c') == 'https://x/a=s512-c'`; `validateDisplayName('  ')` → "Adını yaz.".
- [ ] **Step 2:** `flutter test test/domain/username_test.dart` → FAIL.
- [ ] **Step 3:** Uygula.
- [ ] **Step 4:** PASS + `flutter analyze`.
- [ ] **Step 5: Commit** `feat(domain): kullanıcı adı kuralları`

### Task 4: Kimlik deposu, fotoğraf seçici, sağlayıcılar (yardımcı ajan + kontrolcü)

**Files:**
- Create: `lib/data/profile/profile_identity_repository.dart`, `lib/data/profile/avatar_picker.dart`
- Modify: `lib/app/providers.dart`, `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml` (UCrop aktivitesi)
- Test: `test/data/profile/profile_identity_repository_test.dart`

**Interfaces:**
- Consumes: Görev 1 RPC adları/hata kodları, Görev 2 sütunları, `isNetworkFailure` (`lib/data/export/export_service.dart`).
- Produces:
  ```dart
  enum IdentityFailure { offline, usernameTaken, usernameInvalid, uploadFailed }
  class IdentityError implements Exception { const IdentityError(this.failure); final IdentityFailure failure; String get message; }
  // offline → "İnternet bağlantısı gerekiyor.", usernameTaken → "Bu kullanıcı adı alınmış.",
  // usernameInvalid → "Bu kullanıcı adı kullanılamaz.", uploadFailed → "Fotoğraf yüklenemedi, tekrar dene."

  abstract interface class ProfileIdentityRepository {
    Future<bool> isUsernameAvailable(String username);
    Future<String> setUsername(String userId, String username);   // RPC + yerel satır
    Future<String> uploadAvatar(String userId, Uint8List jpeg);     // yükle → set_avatar_path → yerel → eskiyi sil (hata yutulur)
    Future<String> uploadAvatarFromUrl(String userId, String url);  // indir (http) → uploadAvatar
    Future<void> removeAvatar(String userId);                       // set_avatar_path(null) → yerel → dosyayı sil (hata yutulur)
    String publicUrl(String avatarPath);
  }
  /// Sunucuya ince erişim; testte sahtesi kullanılır.
  abstract interface class IdentityRemote {
    Future<Object?> rpc(String fn, Map<String, Object?> params);
    Future<void> upload(String path, Uint8List bytes);  // bucket 'avatars', contentType image/jpeg
    Future<void> remove(List<String> paths);
    String publicUrl(String path);
  }
  class SupabaseIdentityRemote implements IdentityRemote { SupabaseIdentityRemote(SupabaseClient client); }
  class DefaultProfileIdentityRepository implements ProfileIdentityRepository {
    DefaultProfileIdentityRepository(IdentityRemote remote, AppDatabase db, {DateTime Function()? clock, http.Client? httpClient});
  }

  enum AvatarSource { gallery, camera }
  abstract interface class AvatarPicker { Future<Uint8List?> pick(AvatarSource source); } // iptal → null
  class DeviceAvatarPicker implements AvatarPicker {} // image_picker → image_cropper (1:1, 512×512, JPEG, kalite 85)

  // lib/app/providers.dart
  final profileIdentityRepositoryProvider = Provider<ProfileIdentityRepository>(...);
  final avatarPickerProvider = Provider<AvatarPicker>((ref) => DeviceAvatarPicker());
  class GoogleProfile { const GoogleProfile({this.name, this.photoUrl}); final String? name; final String? photoUrl; }
  final googleProfileProvider = Provider<GoogleProfile?>(...); // user_metadata: full_name ?? name, avatar_url ?? picture; Google kimliği yoksa null
  ```
  `providers.dart` UI için `IdentityError, IdentityFailure, ProfileIdentityRepository, AvatarPicker, AvatarSource` dışa açar (mevcut `export ... show` kalıbı).

- [ ] **Step 1: Testler** (sahte `IdentityRemote` ve bellek içi `AppDatabase` ile):
  - `setUsername` başarılı → yerel `profiles.username` güncel, outbox'a işlem **eklenmez**.
  - RPC `PostgrestException(code: '23505')` → `IdentityError(usernameTaken)`; `'22023'` → `usernameInvalid`; ağ hatası (`SocketException`) → `offline`; yerel satır değişmez.
  - `uploadAvatar` → yol `u1/<clock ms>.jpg` ile yüklenir, `set_avatar_path` çağrılır, yerel yol güncel, eski yol silinir; eski dosya silme hatası yutulur.
  - Yükleme hatası → `uploadFailed` (ağ ise `offline`), `set_avatar_path` çağrılmaz, yerel değişmez.
  - **Review Focus 4:** `setUsername` sonrası `ProfileRepository.update(u1, (p) => p.copyWith(weightKg: 80))` → `username` yerelde hâlâ var.
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** `flutter pub add image_picker image_cropper cached_network_image http`; uygula; manifest'e `com.yalantis.ucrop.UCropActivity`.
- [ ] **Step 4:** `flutter analyze && flutter test` PASS; `flutter build apk --debug --dart-define-from-file=env.json` derlenir.
- [ ] **Step 5: Commit** `feat(profile): kimlik deposu ve fotoğraf seçici`

### Task 5: Avatar, profil başlığı, düzenleme ekranı

**Files:**
- Create: `lib/ui/components/mf_avatar.dart`, `lib/ui/profile/username_field.dart`, `lib/ui/profile/avatar_source_sheet.dart`, `lib/ui/profile/profile_header.dart`, `lib/ui/profile/edit_profile_screen.dart`
- Modify: `lib/ui/profile/profile_screen.dart` (başlık + e-posta hesap bölümüne `SettingsRow` "E-posta"), `lib/ui/profile/profile_routes.dart` (`duzenle`)
- Test: `test/ui/profile/profile_identity_test.dart` (mevcut `_pump` kalıbı + sahte depo/seçici)

**Interfaces:**
- Consumes: Görev 3 fonksiyonları, Görev 4 sağlayıcıları.
- Produces:
  - `MfAvatar({Uint8List? bytes, String? url, required String initials, double size = 72})` — öncelik bytes > url (`CachedNetworkImage`, hata/yüklenirken baş harfler) > baş harfler (vurgu renginde daire, `onAccent` yazı).
  - `UsernameField({required TextEditingController controller, String? ownUsername, ValueChanged<UsernameStatus>? onStatus, String? errorText})`; `enum UsernameStatus { empty, invalid, checking, available, taken, offline }`. Her değişimde `normalizeUsername` uygulanır (imleç sonda), yerel geçersizse sunucuya sorulmaz, 400 ms debounce, `ownUsername`'e eşitse `available`, yalnızca son isteğin cevabı işlenir.
  - `enum AvatarAction { gallery, camera, remove }`; `Future<AvatarAction?> showAvatarSourceSheet(BuildContext, {required bool canRemove})`.
  - Rota `/profil/duzenle` → `EditProfileScreen`.

- [ ] **Step 1: Testler:**
  - Başlık: kullanıcı adı + ad varsa ad ve `@alp` görünür, "Profilini tamamla" yok; ikisinden biri eksikse "Profilini tamamla" görünür ve dokununca düzenleme açılır; ad yok kullanıcı adı varsa başlık `@alp`; ikisi de yoksa "Profil".
  - `UsernameField`: `'Şükrü'` yazılınca alan `sukru`; hızlı `'alp'`→`'alpe'` yazımında `'alp'` cevabı geç gelse de durum `'alpe'` cevabına göre (Review Focus 2); `'ab'` için depo çağrılmaz.
  - Düzenleme: yalnızca ad değişti + depo `offline` atar → ad yine kaydedilir (yerel `display_name` güncel) ve ekran kapanır.
  - Kullanıcı adı değişti + `setUsername` `offline` → ad **kaydedilmez**, "İnternet bağlantısı gerekiyor." görünür.
  - Kullanıcı adı başarılı + `uploadAvatar` `uploadFailed` → kullanıcı adı ve ad kaydedilmiş, "Fotoğraf yüklenemedi, tekrar dene." görünür, ekran açık.
  - `setUsername` `usernameTaken` → alanın altında "Bu kullanıcı adı alınmış.", hiçbir şey kaydedilmez.
  - Seçici `null` döner → hata yok, önizleme değişmez (Review Focus 3).
  - Google hesabı + profil eksik → ad ve fotoğraf (`googlePhotoAt512`) önceden dolu.
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** Uygula. Kaydet sırası spec 6.5: yerel doğrulama → `setUsername` (değiştiyse) → foto (`uploadAvatar` / `uploadAvatarFromUrl` / `removeAvatar`, değiştiyse) → ad (`profileRepository.update`, değiştiyse). Kaydet sırasında düğme `loading`.
- [ ] **Step 4:** `flutter analyze && flutter test` PASS.
- [ ] **Step 5: Commit** `feat(profile): avatar, profil başlığı ve düzenleme ekranı`

### Task 6: Onboarding "Profilin" adımı

**Files:**
- Create: `lib/ui/onboarding/identity_step.dart`
- Modify: `lib/ui/onboarding/onboarding_flow.dart` (adım 1 = Profilin; `_stepCount = 8`; sonraki sabitler +1), `lib/ui/onboarding/onboarding_draft.dart` (`displayName`, `username` controller'ları, `Uint8List? avatarBytes`, `String? avatarUrl`), `lib/app/onboarding_controller.dart` (`OnboardingData.displayName` → aynı tek profil güncellemesinde `displayName`)
- Test: `test/ui/onboarding/onboarding_flow_test.dart`

**Interfaces:** Consumes Görev 3–5 (`UsernameField`, `MfAvatar`, `showAvatarSourceSheet`, `googleProfileProvider`, `profileIdentityRepositoryProvider`).

- [ ] **Step 1: Testler:**
  - Adım 2/8 "Profilin": ad ya da kullanıcı adı boşken İleri hata gösterir, ilerlemez.
  - İleri → `setUsername` çağrılır; `usernameTaken` → alan hatası, adım değişmez; `offline` → "İnternet bağlantısı gerekiyor.", adım değişmez; başarılı → adım 3.
  - Geri dönüp aynı adla İleri → `setUsername` tekrar çağrılmaz.
  - Google profili → ad ve öneri (`usernameBase`, alınmışsa `usernameWithSuffix` ile en çok 5 deneme) dolu, fotoğraf `googlePhotoAt512(url)`.
  - Bitiş: kaydediciye `displayName` gider; fotoğraf varsa yükleme yapılır; yükleme hatasında onboarding yine tamamlanır ve "Fotoğrafını profilden ekleyebilirsin." SnackBar'ı görünür.
  - Mevcut onboarding testleri yeni adım sayısına göre güncellenir.
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** Uygula.
- [ ] **Step 4:** `flutter analyze && flutter test` PASS.
- [ ] **Step 5: Commit** `feat(onboarding): Profilin adımı`

### Task 7: Uzak sunucu ve cihaz doğrulaması (kullanıcıyla)

- [ ] **Step 1:** Bağımsız tek bir whole-branch incelemesi (en yetenekli model) iki depodaki değişiklikler üzerinde; bulgular düzeltilir.
- [ ] **Step 2:** Kullanıcıya migration özetini göster, onay al → `cd ~/projelerim/saglik-app && npx supabase db push` ; `npx supabase migration list` ile doğrula; saglik-app commit'ini push et.
- [ ] **Step 3:** Onayla `npx supabase functions deploy delete-account`.
- [ ] **Step 4:** Release APK'yı Nothing Phone 2a'ya kur. Kontrol: yeni hesapla onboarding (Profilin), Google hesabıyla ön doldurma, eski hesapta "Profilini tamamla", galeri + kamera + kırpma, çevrimdışı hata, aynı kullanıcı adını ikinci hesapla deneme, fotoğraflı hesabı silince Storage'da klasörün gitmesi (Dashboard).
- [ ] **Step 5:** `DEVAM.md` güncelle, commit + push.
