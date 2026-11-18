# MissionFit Flutter · Aşama 1: Temel — Uygulama Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Telefonda çalışan, tema sistemi, 5 sekmeli kabuğu, giriş/onboarding/Profil ekranları, çevrimdışı çalışan veri katmanı ve Dart'a taşınmış iş kuralları olan MissionFit Flutter iskeleti.

**Architecture:** Dört katman: `lib/domain` (saf Dart iş kuralları), `lib/data` (drift yerel DB, outbox ile gönderme, `updated_at` imleciyle çekme, Supabase istemcisi), `lib/app` (Riverpod sağlayıcıları), `lib/ui` (tema, bileşenler, ekranlar). Ekranlar yalnızca yerel DB'den okur. Supabase arka planda senkron ve yedek görevi görür. Sunucu tarafındaki değişiklikler (`saglik-app/supabase`) yalnızca ekleme yapar.

**Tech Stack:** Flutter 3.50 / Dart 3.14, flutter_riverpod, go_router, drift + sqlite3_flutter_libs, supabase_flutter, flutter_secure_storage, google_sign_in, flutter_local_notifications, timezone + flutter_timezone, share_plus, path_provider, flutter_launcher_icons, mocktail (test). Paket sürümleri: Flutter 3.50 ile uyumlu en güncel kararlı sürümler (`flutter pub add` ile).

**Spec:** `docs/superpowers/specs/2026-11-18-asama-1-temel-design.md`

## Global Constraints

- Yalnızca Android. Paket adı `com.alperen.missionfit`, Dart paket adı `missionfit`. Test cihazı Nothing Phone 2a.
- Bütün kullanıcıya görünen metinler Türkçe.
- `lib/domain` hiçbir Flutter, drift ya da Supabase dosyasını import etmez (Task 1'deki `tool/check.sh` bunu denetler).
- Ekranlar (`lib/ui`) `lib/data` ya da Supabase'i doğrudan import etmez, yalnızca `lib/app` sağlayıcılarını kullanır.
- İstemcide yalnızca publishable key bulunur. `env.json` git dışında kalır, depoya yalnızca `env.example.json` girer.
- Sunucu değişiklikleri yalnızca **yeni** migration ile yapılır (`saglik-app/supabase/migrations`). Mevcut tablo ve sütunlar değiştirilmez. RN uygulaması bozulmamalı.
- Doğrulama ve sıfırlama kodu 6-10 hane kabul eder (uzak projede 8).
- Şifre kuralı: en az 8 karakter, en az bir harf ve bir rakam.
- Yazı rengi ile zemin arasında WCAG AA kontrastı: normal yazıda ≥ 4.5:1, ≥ 44 px yazıda ≥ 3:1.
- Her görev bitince: `tool/check.sh` geçmeli, ardından commit atılıp `git push` yapılmalı. Commit mesajı Türkçe olmalı ve şu satırla bitmeli: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Ücretli servis ve LLM yok.

## Review Focus

1. **İnternetsiz açılış:** Daha önce giriş yapılmışken uygulama ağ olmadan açılınca sonsuz yükleme göstermemeli. Profil yerel DB'den gelmeli, onboarding'e geri atılmamalı (Task 8, Task 12).
2. **Aynı telefonda kullanıcı değişimi:** A kullanıcısı çıkış yapıp B girince A'nın yerel verisi, outbox'ı ve senkron imleçleri görünmemeli ve gönderilmemeli (Task 8, Task 10).
3. **RN'de silinen kaydın Flutter'dan da kalkması:** RN bir kaydı silince, Flutter bir sonraki çekmede kaydı yerel DB'den kaldırmalı (Task 6, Task 9).
4. **Gece yarısı ve hafta sınırı:** "Bugün" ve "bu hafta" profildeki saat dilimine (`Europe/Istanbul`) ve hafta başlangıcına (`sunday` dahil) göre hesaplanmalı, cihazın saat dilimine göre değil (Task 2, Task 12).
5. **Sunucudan bilinmeyen değer gelmesi:** `theme_family` ya da `accent_color` beklenmeyen bir değer olursa ya da boş gelirse uygulama çökmemeli, varsayılana dönmeli (Task 11).

---

## Dosya Yapısı

```
missionfit-flutter/
  env.example.json                 SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, GOOGLE_WEB_CLIENT_ID
  tool/check.sh                    analyze + test + domain import denetimi
  assets/fonts/                    Doto, SpaceGrotesk, Inter (OFL, .ttf + OFL.txt)
  assets/icon/                     icon.svg, icon_fg.png, icon_mono.png, notification.png
  lib/
    main.dart                      Env yükle, Supabase.initialize, ProviderScope, MissionFitApp
    env.dart                       Env sınıfı
    domain/                        TS → Dart birebir (dosya adları snake_case)
      dates.dart week.dart units.dart format.dart age.dart calories.dart food.dart
      nutrition.dart workout_kcal.dart workout_summary.dart muscle_coverage.dart
      feedback.dart tasks.dart streak.dart home.dart
      auth_rules.dart              (features/auth/schemas + authErrors)
      onboarding_rules.dart        (features/onboarding/validation)
      notification_settings.dart   (features/profile/notificationSettings)
      greeting.dart                (features/home/greeting)
    data/
      db/database.dart             drift AppDatabase (+ .g.dart)
      db/tables.dart               yerel tablolar
      sync/outbox_queue.dart       saf birleştirme mantığı (outboxQueue.ts karşılığı)
      sync/outbox.dart             OutboxRepository (drift tabanlı)
      sync/remote_gateway.dart     RemoteGateway arayüzü + SupabaseRemoteGateway
      sync/sync_engine.dart        push + pull
      auth/auth_repository.dart
      profile/profile_repository.dart
      export/export_service.dart
      notifications/notification_service.dart
    app/
      providers.dart               db, supabase, gateway, syncEngine, authState, today
      session_controller.dart      oturum + kullanıcı değişiminde temizlik
      theme_controller.dart
      profile_controller.dart
    ui/
      theme/tokens.dart accents.dart mf_theme.dart (ThemeExtension) app_theme.dart
      components/                  MfButton, MfCard, MfTextField, MfEmptyState, PillNavBar, DotGrid
      router.dart
      auth/  onboarding/  shell/  today/  profile/  placeholders/
  test/                            lib/ ile aynı yapı
```

---

### Task 1: Flutter iskeleti, ortam değişkenleri ve kontrol betiği

**Files:**
- Create: `pubspec.yaml`, `analysis_options.yaml`, `env.example.json`, `tool/check.sh`, `lib/main.dart`, `lib/env.dart`, `android/` (flutter create çıktısı)
- Test: `test/env_test.dart`

**Interfaces:**
- Produces: `class Env { final String supabaseUrl; final String supabasePublishableKey; final String googleWebClientId; static Env fromMap(Map<String, String> m); static Env fromEnvironment(); }`. Doğrulama hatasında `FormatException` fırlatır.

- [ ] **Step 1:** `flutter create --org com.alperen --project-name missionfit --platforms android .` komutunu `missionfit-flutter` içinde çalıştır (mevcut docs ve git korunur). `minSdk` değerini 24'e çek. `android/app/build.gradle.kts` içinde `applicationId = "com.alperen.missionfit"` olduğunu doğrula.
- [ ] **Step 2: Failing test** `test/env_test.dart`:
  - `fromMap: geçerli değerler okunur`
  - `fromMap: URL sonunda /rest/v1/ varsa FormatException` (RN kuralı: URL kök adres olmalı)
  - `fromMap: https olmayan URL FormatException`
  - `fromMap: boş anahtar FormatException`
  - `fromMap: GOOGLE_WEB_CLIENT_ID boş olabilir (Google girişi kapalı sayılır)`
- [ ] **Step 3:** `flutter test test/env_test.dart` → FAIL.
- [ ] **Step 4:** `Env` sınıfını yaz. `fromEnvironment()`, `String.fromEnvironment('SUPABASE_URL')` gibi değerleri okur. Çalıştırma komutu: `flutter run --dart-define-from-file=env.json`. `env.json` dosyasını, `saglik-app/.env` içindeki `EXPO_PUBLIC_SUPABASE_URL` ve `EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY` değerleriyle yerelde oluştur (git dışında). Android Studio için `.run/missionfit.run.xml` adlı bir çalıştırma yapılandırması ekle (`--dart-define-from-file=env.json` argümanıyla).
- [ ] **Step 5:** `analysis_options.yaml`: `flutter_lints` ile birlikte `strict-casts: true`, `strict-raw-types: true`, `prefer_single_quotes`, `always_declare_return_types` açık olsun.
- [ ] **Step 6:** `tool/check.sh` yaz. Sırasıyla: `dart format --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`, ardından `grep -rE "package:(flutter|drift|supabase)" lib/domain` bir şey bulursa hata versin.
- [ ] **Step 7:** `tool/check.sh` → hepsi geçmeli. `flutter build apk --debug --dart-define-from-file=env.json` başarılı olmalı.
- [ ] **Step 8:** Commit ve push: `chore: Flutter iskeleti ve ortam değişkenleri`.

---

### Task 2: Domain 1: tarih, hafta, birim, biçim, yaş

**Files:**
- Create: `lib/domain/{dates,week,units,format,age}.dart`
- Test: `test/domain/{dates,week,units,age}_test.dart`. `format` testleri TS'te başka dosyalarda geçiyorsa oradan taşınır.

**Interfaces:**
- Produces (TS adları korunur, camelCase):
  - `typedef LocalDate = String; typedef LocalTime = String;`
  - `bool isLocalDate(String)`, `LocalDate formatLocalDate(int y, int m, int d)`, `int toEpochDay(LocalDate)`, `LocalDate fromEpochDay(int)`, `LocalDate addDays(LocalDate, int)`, `int diffDays(LocalDate a, LocalDate b)`, `int isoWeekday(LocalDate)`, `List<LocalDate> daysBetween(LocalDate, LocalDate)`, `bool isValidTimeZone(String)`, `LocalDate localDateInZone(DateTime instant, String timeZone)`, `LocalTime localTimeInZone(DateTime, String)`, `int timeZoneOffsetMinutes(DateTime, String)`, `int? parseLocalTime(String?)`, `LocalTime formatMinutesAsTime(int)`, `DateTime zonedTimeToUtc(LocalDate, int minutesOfDay, String timeZone)`
  - `enum WeekStartsOn { monday, sunday }`, `class WeekWindow { LocalDate start; LocalDate end; LocalDate key; }`, `weekStartOf`, `weekKeyOf`, `weekWindowForDate`, `weekWindow(DateTime, WeekStartsOn, String tz)`, `isInWindow`, `previousWeeks`
  - `enum WeightUnit { kg, lb }`, `const kgPerLb = 0.45359237`, `kgToLb`, `lbToKg`, `toKg`, `fromKg`, `formatWeight`
  - `formatInt`, `joinTurkish`, `formatDuration`, `formatClock`
  - `const minAge = 18, maxAge = 100`, `class BirthDate {int year, month, day}`, `isValidDate`, `ageOn`, `ageFromBirthYear`, `sealed class BirthDateCheck` (TS'teki birleşimin karşılığı), `checkBirthDate`

- [ ] **Step 1: Failing tests.** `saglik-app/src/domain/{dates,week,units,age}.test.ts` içindeki **her** `it` için bir Dart `test` yaz: aynı açıklama metni, aynı girdiler, aynı beklenen değerler. Toplam 15 + 9 + 5 + 11 = **40** test. Saat dilimi testleri için `setUpAll` içinde `tz.initializeTimeZones()` çağır.
- [ ] **Step 2:** `flutter test test/domain` → FAIL.
- [ ] **Step 3:** TS dosyalarını davranışları korunarak Dart'a taşı. IANA hesabı için `package:timezone`'u (`TZDateTime.from`) kullan. Intl tabanlı `zonedParts` yerine bunu kullan, testler aynı sonucu doğrular.
- [ ] **Step 4: Review Focus #4 testi** `test/domain/dates_test.dart`:
  - `localDateInZone: 2026-11-18T21:30Z İstanbul'da 2026-11-19` (UTC+3)
  - `weekWindow sunday: 2026-11-22 Pazar haftanın ilk günü`
- [ ] **Step 5:** `tool/check.sh` → PASS.
- [ ] **Step 6:** Commit ve push: `feat(domain): tarih, hafta, birim, biçim ve yaş kuralları`.

---

### Task 3: Domain 2: kalori, yemek, beslenme, antrenman, kas kapsamı, geri bildirim

**Files:**
- Create: `lib/domain/{calories,food,nutrition,workout_kcal,workout_summary,muscle_coverage,feedback}.dart`
- Test: `test/domain/{calories,nutrition,workout,workout_summary,intensity}_test.dart`

**Interfaces:**
- Consumes: Task 2.
- Produces: TS'teki bütün dışa açık adlar camelCase olarak korunur. Birleşim tipleri enum olur: `Sex`, `ActivityLevel`, `Goal`, `AmountUnit (g, serving, piece)`, `Meal`, `BodyRegion (chest, back, shoulders, arms, core, legs)`, `MuscleRole`, `CoverageStatus`, `Level`. Ayrımlı birleşimler (`KcalResult`, `ManualTargetCheck`, `CalorieTargetResult`) sealed class olur. Sabitler aynı değerlerle korunur: `activityFactors {1.2, 1.375, 1.55, 1.725, 1.9}`, `calorieFloor {female: 1200, male: 1500}`, `maxSessionHours = 4`, `maxEntryGrams = 10000`, `maxManualKcal = 20000`, `manualTargetWarnAbove = 5000`, `manualTargetMax = 10000`, `weeklyIntensity {2, 4, 10}`, `sessionIntensity {1, 2, 4}`, `defaultThresholds {primaryWeight 1.0, secondaryWeight 0.5, adequateSets 4}`. Etiketler (`mealLabels`, `regionLabels`, `levelLabels`) aynı Türkçe metinleri kullanır.

- [ ] **Step 1: Failing tests.** `calories.test.ts` (14), `nutrition.test.ts` (15), `workout.test.ts` (20), `workoutSummary.test.ts` (4) ve `intensity.test.ts` (4) testlerini birebir taşı. Toplam **57**.
- [ ] **Step 2:** `flutter test test/domain` → yeni testler FAIL.
- [ ] **Step 3:** TS dosyalarını Dart'a taşı.
- [ ] **Step 4:** `tool/check.sh` → PASS.
- [ ] **Step 5:** Commit ve push: `feat(domain): kalori, beslenme, antrenman ve kas kapsamı kuralları`.

---

### Task 4: Domain 3: görevler, seri, ana sayfa ve özellik kuralları

**Files:**
- Create: `lib/domain/{tasks,streak,home,auth_rules,onboarding_rules,notification_settings,greeting}.dart`
- Test: `test/domain/{tasks,home,auth_rules,onboarding_rules,notification_settings,greeting}_test.dart`

**Interfaces:**
- Consumes: Task 2 ve Task 3.
- Produces:
  - `tasks.ts`, `streak.ts` ve `home.ts`'teki bütün adlar. `RepeatRule` sealed class olur: `Once`, `Daily`, `Weekly(List<int> days)`.
  - `auth_rules.dart`: RN `features/auth/schemas.ts` ve `authErrors.ts` karşılığı. `String? validateEmail(String)`, `String? validatePassword(String)`, `String? validateOtp(String)` (6-10 rakam), `String authErrorMessage(Object error)` (aynı Türkçe mesajlar).
  - `onboarding_rules.dart`: `features/onboarding/validation.ts` karşılığı.
  - `notification_settings.dart`: `features/profile/notificationSettings.ts` karşılığı (`{enabled: true, task_lead_minutes: 10}` varsayılanı ve çözümleme).
  - `greeting.dart`: `String greetingFor(int hour)`.
- [ ] **Step 1: Failing tests.** `tasks` (25), `home` (8), `authErrors` (13) ve `schemas` (9) birlikte `auth_rules_test` olarak, `onboarding validation` (12), `notificationSettings` (3) ve `greeting` (2) testlerini birebir taşı. Toplam **72**. `deepLink.test.ts` **taşınmaz** (kodla giriş, deep link kullanılmıyor).
- [ ] **Step 2:** FAIL. **Step 3:** Testleri geçecek şekilde uygula. **Step 4:** `tool/check.sh` → PASS (domain toplamı 169 test).
- [ ] **Step 5:** Commit ve push: `feat(domain): görev, seri, ana sayfa ve form kuralları`.

---

### Task 5: Sunucu migration'ları (saglik-app deposunda)

**Files (`~/projelerim/saglik-app` içinde):**
- Create: `supabase/migrations/20261118120000_sync_support.sql`, `supabase/rollbacks/20261118120000_sync_support.down.sql`, `supabase/tests/sync_support.test.sql`
- Modify: `src/lib/database.types.ts` (`npm run db:types` ile yeniden üret)

**Interfaces:**
- Produces (Flutter tarafı bunları kullanır):
  - `session_sets.updated_at`, `favorite_foods.updated_at` ve `task_completions.updated_at` sütunları: `timestamptz not null default now()`, mevcut `public.set_updated_at()` tetikleyicisiyle. Bu tablolara `(user_id, updated_at)` indeksi eklenir. Diğer 5 kullanıcı tablosuna da `(user_id, updated_at)` indeksi eklenir.
  - `public.deletions(id bigint generated always as identity primary key, table_name text not null, row_id uuid not null, user_id uuid not null, deleted_at timestamptz not null default now())`. İndeks: `(user_id, deleted_at)`. RLS açık. Politika: `select to authenticated using ((select auth.uid()) = user_id)`. INSERT/UPDATE/DELETE yetkisi verilmez. `auth.users`'a FK yok.
  - `public.record_deletion()`: `security definer`, `set search_path = ''`. 8 kullanıcı tablosunun her birinde `after delete for each row` tetikleyicisi olarak çalışır. `profiles` için `row_id = old.user_id` kullanılır.
  - `profiles.theme_family text not null default 'canli' check (theme_family in ('mono','canli'))`
  - `profiles.accent_color text not null default 'yesil' check (accent_color in ('kirmizi','yesil','mavi','indigo','mor','pembe','turuncu','sari','turkuaz','grafit'))`
  - Mevcut "profiles: kullanıcı korunan sütunları değiştiremesin" GRANT listesine bu iki sütun eklenir. Satır 402-407 civarındaki desen izlenir.
  - Hesap silme sonrası temizlik: `delete-account` fonksiyonu kullanıcıyı sildikten sonra `delete from public.deletions where user_id = <id>` çalıştırır (`supabase/functions/delete-account/index.ts`).
- [ ] **Step 1: Failing pgTAP** `sync_support.test.sql`:
  - 3 tabloda `updated_at` sütunu var
  - A kullanıcısının `food_entries` satırı silinince `deletions` tablosuna 1 kayıt düşer (`table_name='food_entries'`, doğru `row_id`)
  - B kullanıcısı A'nın silme kayıtlarını göremez (RLS)
  - authenticated rol `deletions` tablosuna insert yapamaz
  - geçersiz `accent_color` değeri check hatası verir
  - hesap silme cascade'i hata vermeden tamamlanır (`account_deletion_cascade` deseni)
- [ ] **Step 2:** `npm run db:start && npm run db:test` → yeni testler FAIL.
- [ ] **Step 3:** Migration'ı ve geri alma dosyasını yaz, `npm run db:reset` çalıştır.
- [ ] **Step 4:** `npm run db:test` → bütün pgTAP testleri PASS (29 eski + yeniler). `npm run db:advisors` temiz olmalı. RN tarafında `npm test` hâlâ 299/299 olmalı.
- [ ] **Step 5:** `npm run db:types`. Ardından saglik-app deposunda commit: `feat(db): Flutter senkronu için updated_at, silme kayıtları ve tema sütunları`.
- [ ] **Step 6: Uzak veritabanı.** Kullanıcıya ne uygulanacağını özetle ve onay al. Onay gelince `supabase db push --remote` çalıştır, `supabase migration list --remote` ile doğrula. Supabase klasörü burada olduğu için push saglik-app deposunun kendi dalına yapılır.

---

### Task 6: Yerel veritabanı (drift)

**Files:**
- Create: `lib/data/db/tables.dart`, `lib/data/db/database.dart`
- Test: `test/data/db/database_test.dart`

**Interfaces:**
- Produces:
  - `class AppDatabase extends _$AppDatabase`. `AppDatabase.forTesting(QueryExecutor e)` kurucusu var. `schemaVersion = 1`.
  - Kullanıcı tabloları sunucu şemasının aynası. Sütun adları sunucuyla aynı, drift'te `@JsonKey`/snake_case kullanılır: `profiles`, `workoutSessions`, `sessionSets`, `customFoods`, `foodEntries`, `favoriteFoods`, `tasks`, `taskCompletions`.
  - Katalog tabloları: `muscleGroups`, `exercises`, `exerciseMuscles`, `workoutTemplates`, `workoutTemplateExercises`, `foods`, `defaultTasks`.
  - Senkron tabloları:
    - `outboxOps(opId text pk, key text unique, type text, payload text /*json*/, attempts int, createdAt int, seq int autoincrement-benzeri sıra)`
    - `syncCursors(tableName text pk, cursor text /*ISO updated_at*/, lastPulledAt int)`
  - Yardımcı: `Future<void> clearAllUserData()`. Bütün kullanıcı tablolarını, `outboxOps` ve `syncCursors` tablolarını boşaltır, katalogları korur.
- [ ] **Step 1: Failing tests:**
  - `bellekte açılır ve 18 tablo oluşur`
  - `foodEntries upsert aynı id ile ikinci kayıt oluşturmaz`
  - `clearAllUserData kullanıcı tablolarını ve outbox'ı boşaltır, foods kataloğu kalır`
- [ ] **Step 2:** FAIL. **Step 3:** Tabloları yaz ve `dart run build_runner build` çalıştır. Üretilen `.g.dart` dosyaları commit'e dahil edilir. **Step 4:** PASS.
- [ ] **Step 5:** Commit ve push: `feat(data): drift yerel veritabanı şeması`.

---

### Task 7: Outbox

**Files:**
- Create: `lib/data/sync/outbox_queue.dart`, `lib/data/sync/outbox.dart`
- Test: `test/data/sync/outbox_queue_test.dart`, `test/data/sync/outbox_test.dart`

**Interfaces:**
- Produces:
  - `outbox_queue.dart` (saf, `outboxQueue.ts` karşılığı): `class OutboxOp {opId, key, type, payload (Map<String,Object?>), attempts, createdAt}`, `const maxAttempts = 15`, `List<OutboxOp> enqueue(List<OutboxOp>, OutboxOp)`, `removeOp`, `bumpAttempts`, `bool isPermanentError(Object?)` (SQLSTATE `^(22|23|42)[0-9A-Z]{3}$`; `PostgrestException.code` okunur), `Duration retryDelay(int failures)` (5 sn, 15 sn, 30 sn, sonra 60 sn).
  - `outbox.dart`: `class OutboxRepository { OutboxRepository(AppDatabase db); Future<void> enqueue(OutboxOp op); Future<List<OutboxOp>> pending(); Future<void> remove(String opId); Future<void> bump(String opId); Stream<int> pendingCount(); }`. Aynı key'e gelen yeni işlem eskisinin sırasını (`seq`) korur ve `attempts`'i sıfırlar.
  - İşlem tipi adları: `'<tablo>.upsert'` ve `'<tablo>.delete'`, key `'<tablo>:<id>'`. Payload upsert için tam satır JSON'u, delete için `{'id': ...}`.
- [ ] **Step 1: Failing tests:** `outboxQueue.test.ts`'in 8 testi birebir taşınır. Ek olarak drift testleri:
  - `aynı key'e ikinci işlem sırayı korur`
  - `uygulama yeniden açılınca bekleyen işlemler okunur` (aynı executor ile yeni bir `AppDatabase`)
- [ ] **Step 2-4:** FAIL → uygula → PASS.
- [ ] **Step 5:** Commit ve push: `feat(sync): drift tabanlı outbox`.

---

### Task 8: Senkron motoru

**Files:**
- Create: `lib/data/sync/remote_gateway.dart`, `lib/data/sync/sync_engine.dart`
- Test: `test/data/sync/sync_engine_test.dart` (`FakeRemoteGateway` ile)

**Interfaces:**
- Consumes: Task 6 ve Task 7.
- Produces:
  - `abstract interface class RemoteGateway { Future<void> upsert(String table, Map<String,Object?> row); Future<void> delete(String table, String id); Future<List<Map<String,Object?>>> fetchChanged(String table, {required String? since, required int limit}); Future<List<Map<String,Object?>>> fetchDeletions({required String? since, required int limit}); Future<List<Map<String,Object?>>> fetchCatalog(String table); }`
  - `SupabaseRemoteGateway implements RemoteGateway`. Sorgu biçimi: `updated_at > since order by updated_at asc limit 1000`. Upsert: `onConflict: 'id'`, `profiles` için `user_id`.
  - `class SyncEngine { SyncEngine(AppDatabase, OutboxRepository, RemoteGateway); Future<SyncResult> push(); Future<SyncResult> pull(); Future<void> syncNow(); Future<void> downloadCatalogs(); }`
  - `class SyncResult { int pushed; int dropped; int pulled; List<String> droppedReasons; }`
  - Tablo sırası (yabancı anahtar düzeni): `profiles`, `custom_foods`, `workout_sessions`, `session_sets`, `food_entries`, `favorite_foods`, `tasks`, `task_completions`.
- **Kurallar:**
  - push: Sırayla gönderir. Kalıcı hata ya da `attempts >= 15` olursa işlemi bırakır ve `droppedReasons`'a ekler. Geçici hatada `bump` yapar ve durur (sıra korunur).
  - pull: Her tablo için imleçten itibaren sayfa sayfa çeker. Yerelde aynı key'de bekleyen outbox işlemi olan satırın üzerine yazmaz (yerel değişiklik önce gönderilecek). Ardından `deletions` kayıtlarını uygular.
  - Bir tablonun imleci 90 günden eskiyse o tabloyu ve imlecini temizleyip baştan çeker.
  - Kataloglar `downloadCatalogs` ile yalnızca yerelde boşsa ya da 7 günden eskiyse indirilir.
- [ ] **Step 1: Failing tests:**
  - `push: başarıyla gönderilen işlem kuyruktan çıkar`
  - `push: 42501 hatası işlemi bırakır, dropped=1`
  - `push: ağ hatası attempts'i artırır ve sonraki işlemleri göndermez`
  - `pull: updated_at imleci ilerler ve ikinci pull aynı satırları tekrar istemez`
  - `pull: 1000'den fazla satır sayfalanır` (sahte sunucuda 2500 satır)
  - `pull: outbox'ta bekleyen satır sunucu sürümüyle ezilmez`
  - `pull: deletions kaydı yerel satırı siler` *(Review Focus #3)*
  - `pull: 90 günden eski imleç tam yeniden indirme yapar`
- [ ] **Step 2-4:** FAIL → uygula → PASS.
- [ ] **Step 5: Yerel uçtan uca test.** Docker Supabase (`saglik-app`'te `npm run db:start`) üzerinde iki test kullanıcısıyla bir entegrasyon betiği çalıştır: `test/integration/sync_e2e_test.dart`, `--dart-define=E2E=1` verilmezse atlanır. Kontroller: A'nın yazdığı veri B'ye gelmemeli, SQL ile silinen satır A'nın yerelinden kalkmalı.
- [ ] **Step 6:** Commit ve push: `feat(sync): gönderme/çekme senkron motoru`.

---

### Task 9: Tema sistemi

**Files:**
- Create: `lib/ui/theme/{tokens,accents,mf_theme,app_theme}.dart`, `assets/fonts/*`
- Test: `test/ui/theme/contrast_test.dart`, `test/ui/theme/mf_theme_test.dart`

**Interfaces:**
- Produces:
  - `enum ThemeFamily { mono, canli }`, `enum Brightness`'ı yeniden tanımlama. Açık/koyu seçimi için `enum ThemeModeChoice { system, light, dark }` (sunucudaki `theme` değerleri).
  - `enum AccentColor { kirmizi, yesil, mavi, indigo, mor, pembe, turuncu, sari, turkuaz, grafit }`. Her rengin `label` alanı (Türkçe ad: Kırmızı, Yeşil, Mavi, İndigo, Mor, Pembe, Turuncu, Sarı, Turkuaz, Grafit), `lightTone` ve `darkTone` alanları var. Başlangıç tonları:
    `kirmizi #C8161D/#FF4D4F`, `yesil #15803D/#1ED760`, `mavi #1D4ED8/#60A5FA`, `indigo #4F46E5/#818CF8`, `mor #7C3AED/#A78BFA`, `pembe #BE185D/#F472B6`, `turuncu #C2410C/#FB923C`, `sari #A16207/#FACC15`, `turkuaz #0F766E/#2DD4BF`, `grafit #3F3F46/#D4D4D8`.
    Kontrast testi geçmezse ton, aynı renk tonu (hue) korunarak koyulaştırılır ya da açılır.
  - `AccentColor accentFromString(String?)` ve `ThemeFamily familyFromString(String?)`. Bilinmeyen ya da boş değerde varsayılanı döner: `canli` ve `yesil`. *(Review Focus #5)* Aile varsayılan vurgusu: `mono → kirmizi`, `canli → yesil`.
  - `class MfTheme extends ThemeExtension<MfTheme>`. Alanlar:
    - renkler: `background`, `surface`, `surfaceMuted`, `text`, `textMuted`, `border`, `accent`, `onAccent`, `success`, `warning`, `danger`, `kcal`
    - `displayFont`, `bodyFont`, `numberFont`
    - `radius`
    - `cardStyle` (`enum CardStyle { flat, gradient }`)
    - `dotGridBackground` (bool)
    - görünüm seçenekleri: `calorieView` (`enum CalorieView { ring, bigNumberBar }`)
  - `MfTheme build(ThemeFamily, Brightness, AccentColor)` ve `ThemeData buildThemeData(MfTheme)`.
  - Aile değerleri (`.superpowers/brainstorm/*/content/tema-yonleri.html` taslağından alınır):
    - **Mono:** zemin açık `#F6F3EE` / koyu `#141414`, yazı `#1D1B19` / `#F6F3EE`, noktalı zemin, display font **Doto** (rakamlar), başlık ve gövde **Space Grotesk**, `radius 4`, `CardStyle.flat`, `CalorieView.bigNumberBar`.
    - **Canlı:** zemin koyu `#121212` / açık `#F7F7F7`, yüzey koyu `#1E1E1E`/`#2A2A2A`, ikincil yazı `#B3B3B3`, font **Inter**, `radius 16`, `CardStyle.gradient`, `CalorieView.ring`.
    - Tam belirteç tablosu `tokens.dart`'ta durur, değerler taslaktan alınır.
  - Fontlar `assets/fonts` altına konur (OFL lisans dosyalarıyla birlikte), `google_fonts` çalışma zamanında indirme yapmaz.
- [ ] **Step 1: Failing tests:**
  - `contrast_test.dart`: 2 aile × 2 parlaklık × 10 vurgu kombinasyonu için `text`, `textMuted`, `warning` ve `danger` renkleri `background`, `surface` ve `surfaceMuted` üzerinde ≥ 4.5 olmalı. `accent` (yazı olarak) `background` ve `surface` üzerinde ≥ 4.5, `onAccent` `accent` üzerinde ≥ 4.5 olmalı. `kcal` ≥ 3. RN `contrast.test.ts`'teki 5 testin kapsamı korunur, kombinasyonlar genişletilir.
  - `mf_theme_test.dart`:
    - `familyFromString('xyz') == canli`
    - `accentFromString(null) == yesil`
    - `mono açık temada calorieView bigNumberBar`
    - `lerp geçişte çökmez`
- [ ] **Step 2-4:** FAIL → uygula (testi geçmeyen tonları ayarla) → PASS.
- [ ] **Step 5:** Commit ve push: `feat(ui): Mono/Canlı tema sistemi ve 10 vurgu rengi`.

---

### Task 10: Supabase, oturum ve kimlik doğrulama deposu

**Files:**
- Create: `lib/data/auth/auth_repository.dart`, `lib/app/providers.dart`, `lib/app/session_controller.dart`
- Modify: `lib/main.dart`
- Test: `test/data/auth/auth_repository_test.dart`, `test/app/session_controller_test.dart`

**Interfaces:**
- Consumes: `Env` (Task 1), `AppDatabase.clearAllUserData` (Task 6), `SyncEngine` (Task 8), `authErrorMessage` (Task 4).
- Produces:
  - `main.dart`: `Supabase.initialize(url, publishableKey, authOptions: FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce, localStorage: SecureLocalStorage()))`. `SecureLocalStorage` sınıfı flutter_secure_storage üzerinden supabase'in `LocalStorage` arayüzünü uygular.
  - `class AuthRepository`:
    - `Future<void> signUp(email, password)`, `verifySignUpCode(email, code)` (OtpType.signup/email), `signIn(email, password)`, `sendResetCode(email)`, `verifyResetCode(email, code)` (OtpType.recovery), `updatePassword(newPassword)`, `reauthenticateWithPassword(email, password)`
    - `Future<void> signInWithGoogle()`: google_sign_in, `serverClientId: Env.googleWebClientId`, ardından `signInWithIdToken(provider: OAuthProvider.google, idToken, accessToken)`
    - `Future<void> reauthenticateWithGoogle()`
    - `bool get hasPasswordIdentity` (identities içinde `email` var mı)
    - `Future<void> signOut()` (`SignOutScope.local`)
    - Hatalar `AuthFailure(String message)` olarak fırlatılır, mesaj `authErrorMessage`'dan gelir.
  - Sağlayıcılar: `databaseProvider`, `supabaseProvider`, `remoteGatewayProvider`, `syncEngineProvider`, `authStateProvider` (`Stream<Session?>`), `currentUserIdProvider`.
  - `SessionController`:
    - Oturum açılınca son kullanıcı kimliğini (secure storage `last_user_id`) karşılaştırır. Farklı bir kullanıcıysa önce `clearAllUserData()` çağırır, sonra `downloadCatalogs()` ve `syncNow()`. *(Review Focus #2)*
    - Çıkışta `clearAllUserData()` çalışır ve bildirimler iptal edilir.
    - Uygulama öne gelince (`AppLifecycleState.resumed`) ve her 60 sn'de bir `syncNow()` çağrılır (outbox boş değilse).
- [ ] **Step 1: Failing tests** (mocktail ile `GoTrueClient` ve `GoogleSignIn`):
  - `signIn hatası Türkçe AuthFailure'a çevrilir`
  - `hasPasswordIdentity: yalnızca google kimliği varsa false`
  - `SessionController: farklı kullanıcı girince clearAllUserData çağrılır`
  - `SessionController: aynı kullanıcı tekrar girince veri silinmez`
  - `SessionController: çıkışta yerel veri temizlenir`
- [ ] **Step 2-4:** FAIL → uygula → PASS.
- [ ] **Step 5:** Commit ve push: `feat(auth): Supabase oturumu, Google girişi ve kullanıcı değişiminde temizlik`.

---

### Task 11: Profil deposu ve tema denetleyicisi

**Files:**
- Create: `lib/data/profile/profile_repository.dart`, `lib/app/profile_controller.dart`, `lib/app/theme_controller.dart`
- Test: `test/data/profile/profile_repository_test.dart`, `test/app/theme_controller_test.dart`

**Interfaces:**
- Consumes: Task 6, 7, 9 ve 10.
- Produces:
  - `class Profile`: sunucu sütunlarının tamamı, `themeFamily` ve `accentColor` dahil, `fromRow`/`toRow` ile.
  - `ProfileRepository { Stream<Profile?> watch(String userId); Future<void> update(String userId, Profile Function(Profile) change); }`. `update`, yerel yazmayı ve outbox `profiles.upsert` işlemini **aynı drift transaction'ında** yapar.
  - `profileProvider` (`StreamProvider<Profile?>`), `onboardedProvider` (yerel bayrak `onboarded.<userId>` ya da `profile.onboardingCompleted`).
  - `ThemeController` (`Notifier<ThemeSelection>`): `ThemeSelection {ThemeFamily family; ThemeModeChoice mode; AccentColor accent}`. Seçim yerelde (`shared_preferences`) anında saklanır ve profile yazılır. Açılışta önce yereldeki seçim kullanılır, ekran yanıp sönmez. Profil yüklenince sunucudaki değer farklıysa sunucu kazanır.
  - `ThemeController.setFamily(f)`: Vurgu rengi kullanıcı tarafından hiç değiştirilmediyse ailenin varsayılan vurgusuna geçer.
- [ ] **Step 1: Failing tests:**
  - `update yerel satırı ve outbox işlemini birlikte yazar`
  - `update sırasında hata olursa ikisi de yazılmaz`
  - `sunucudan accent_color='bilinmeyen' gelirse yesil kullanılır` *(Review Focus #5)*
  - `setFamily(mono) dokunulmamış vurguyu kirmizi yapar`
  - `ağ yokken profil yerelden okunur` *(Review Focus #1)*
- [ ] **Step 2-4:** FAIL → uygula → PASS.
- [ ] **Step 5:** Commit ve push: `feat(profile): profil deposu ve kalıcı tema seçimi`.

---

### Task 12: Yönlendirme, kabuk, hap şeklinde alt bar ve Bugün

**Files:**
- Create: `lib/ui/router.dart`, `lib/ui/components/pill_nav_bar.dart`, `lib/ui/shell/app_shell.dart`, `lib/ui/today/today_screen.dart`, `lib/ui/placeholders/coming_soon_screen.dart`, `lib/ui/components/{mf_button,mf_card,mf_text_field,mf_empty_state,dot_grid}.dart`
- Modify: `lib/main.dart` (`MaterialApp.router`, tema)
- Test: `test/ui/router_test.dart`, `test/ui/components/pill_nav_bar_test.dart`

**Interfaces:**
- Consumes: `authStateProvider`, `onboardedProvider`, `ThemeController`, `greetingFor`, `localDateInZone`.
- Produces:
  - Rotalar: `/giris`, `/kayit`, `/dogrula`, `/sifremi-unuttum`, `/onboarding`, `/bugun`, `/antrenman`, `/kalori`, `/gorevler`, `/profil` ve `/profil/*` alt rotaları (Task 16).
  - Yönlendirme koruması: oturum yoksa yalnızca `/giris`, `/kayit`, `/dogrula`, `/sifremi-unuttum` açılabilir. Oturum var ama onboarding bitmemişse `/onboarding`'e yönlendirilir. Onboarding bitmişse auth rotaları `/bugun`'e yönlendirilir.
  - Kabuk: `StatefulShellRoute.indexedStack` ile 5 dal. Sekme adları ve ikonları: Bugün (`home`), Antrenman (`fitness_center`), Kalori (`restaurant`), Görevler (`check_circle`), Profil (`person`).
  - `PillNavBar({required int index, required ValueChanged<int> onTap, required List<PillNavItem> items})`:
    - Ekranın altında, kenarlardan 16 px içeride yüzer.
    - Aktif öğe ikon ve etiketle, vurgu renginde bir hap içinde gösterilir. Diğerleri yalnızca ikon.
    - Hap, `AnimatedContainer` ya da benzeri ile ~250 ms'de kayarak genişler.
    - Etiketsiz öğelerin `Semantics(label:)` değeri sekme adıdır.
  - `TodayScreen`: `greetingFor(saat)` + bugünün tarihi (profildeki saat dilimine göre, Türkçe gün ve ay adıyla). Gün değişince kendiliğinden güncellenen bir `todayProvider` kullanılır.
  - `ComingSoonScreen(title, icon, message)`: Antrenman, Kalori ve Görevler için. Mesajlar: "Antrenman ekranı bir sonraki aşamada geliyor.", "Kalori ekranı yakında." ve "Görevler ekranı yakında."
- [ ] **Step 1: Failing tests:**
  - `oturum yokken /bugun → /giris`
  - `oturum var, onboarding yok → /onboarding`
  - `onboarding tamam → /giris açılınca /bugun`
  - `PillNavBar: yalnızca aktif sekmenin etiketi görünür`
  - `PillNavBar: dokununca onTap doğru index ile çağrılır`
  - `PillNavBar: etiketsiz sekmelerin semantics etiketi var`
  - `sekme değiştirip geri gelince alt sayfa korunur`
  - `tema değişince açık olan sekme ve alt sayfa korunur`
- [ ] **Step 2-4:** FAIL → uygula → PASS.
- [ ] **Step 5: Cihaz kontrolü:** `flutter run --dart-define-from-file=env.json` ile Nothing Phone 2a'da hap animasyonuna, Mono ve Canlı'da barın görünüşüne bak.
- [ ] **Step 6:** Commit ve push: `feat(ui): 5 sekmeli kabuk, hap şeklinde alt bar ve Bugün`.

---

### Task 13: Giriş ve kayıt ekranları

**Files:**
- Create: `lib/ui/auth/{login_screen,register_screen,verify_code_screen,forgot_password_screen,google_button}.dart`
- Test: `test/ui/auth/auth_screens_test.dart`

**Interfaces:**
- Consumes: `AuthRepository` (Task 10), `validateEmail`, `validatePassword`, `validateOtp` (Task 4).
- Produces: Ekranlar.
  - **Giriş:** e-posta, şifre (göster/gizle), "Giriş yap", "Google ile devam et", "Şifremi unuttum", "Hesabın yok mu? Kayıt ol".
  - **Kayıt:** e-posta, şifre, şifre tekrar, "Kayıt ol" → `/dogrula?email=`.
  - **Doğrula:** 8 haneli kod alanı (6-10 kabul edilir), "Doğrula", "Kodu tekrar gönder" (60 sn bekleme süresiyle, RN `useResendCooldown` karşılığı).
  - **Şifremi unuttum:** önce e-posta → kod gönder, sonra kod + yeni şifre + tekrar.
  - `Env.googleWebClientId` boşsa Google düğmesi gizlenir.
- [ ] **Step 1: Failing widget tests:**
  - `geçersiz e-postada hata metni görünür ve repository çağrılmaz`
  - `şifreler eşleşmezse kayıt gönderilmez`
  - `başarılı kayıt /dogrula'ya e-postayla gider`
  - `kodu tekrar gönder 60 sn pasif kalır`
  - `googleWebClientId boşken Google düğmesi yok`
  - `AuthFailure mesajı ekranda gösterilir`
- [ ] **Step 2-4:** FAIL → uygula → PASS.
- [ ] **Step 5:** Commit ve push: `feat(auth): giriş, kayıt, kod doğrulama ve şifre sıfırlama ekranları`.

---

### Task 14: Bildirim altyapısı, uygulama ikonu

**Files:**
- Create: `lib/data/notifications/notification_service.dart`, `assets/icon/icon.svg`, `assets/icon/*.png`, `flutter_launcher_icons.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`, `PLACEHOLDER
- Test: `test/data/notifications/notification_service_test.dart`

**Interfaces:**
- Produces:
  - `abstract interface class NotificationService { Future<void> init(); Future<PermissionState> permission(); Future<PermissionState> requestPermission(); Future<void> showTest(); Future<void> cancelAll(); }`
  - `enum PermissionState { granted, denied, unknown }`
  - `LocalNotificationService implements NotificationService`. Kanal: id `tasks`, ad "Görev hatırlatmaları", önem `high`. Deneme bildirimi 5 sn sonra gelir, metni "MissionFit bildirimleri çalışıyor".
  - Manifest: `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED` izinleri ve flutter_local_notifications alıcıları. `android:allowBackup="false"` (RN kararı).
  - **İkon:** Özgün bir işaret tasarlanır, telifli görsel kullanılmaz. Öneri: Mono estetiğinde nokta-matristen bir "M" ve tek bir kırmızı nokta vurgusu. `icon.svg` → `rsvg-convert` ile PNG üretilir. Adaptive icon (ön plan ve düz arka plan) ve Android 13 monokrom sürümü hazırlanır. Bildirim ikonu 96 px, beyaz ve şeffaf olur.
- [ ] **Step 1: Failing tests** (mocktail ile eklenti sarmalayıcısı):
  - `init tasks kanalını high önemle oluşturur`
  - `izin reddedilince PermissionState.denied`
  - `cancelAll eklentide cancelAll çağırır`
- [ ] **Step 2-4:** FAIL → uygula → PASS. Ardından `dart run flutter_launcher_icons` çalıştır.
- [ ] **Step 5: Cihaz kontrolü:** İkon ana ekranda ve Nothing'in monokrom ikon modunda düzgün görünmeli. Profil'deki deneme bildirimi 5 sn içinde gelmeli.
- [ ] **Step 6:** Commit ve push: `feat: bildirim altyapısı ve uygulama ikonu`.

---

### Task 15: Onboarding

**Files:**
- Create: `lib/ui/onboarding/onboarding_flow.dart` ve adım widget'ları (`consent_step`, `birth_date_step`, `body_step`, `goal_step`, `calorie_preview_step`, `notification_step`, `theme_step`), `lib/ui/onboarding/kvkk_text.dart`
- Test: `test/ui/onboarding/onboarding_flow_test.dart`

**Interfaces:**
- Consumes: `onboarding_rules`, `checkBirthDate`, `calorieTargetForProfile` (Task 3-4), `ProfileRepository.update`, `ThemeController` (Task 11), `NotificationService.requestPermission` (Task 14).
- Produces: RN `src/app/onboarding.tsx` akışının karşılığı ve araya eklenen tema adımı. Sıra:
  1. KVKK ve açık rıza (metin RN'den aynen alınır, onay kutuları zorunlu, `consented_at` yazılır)
  2. Doğum tarihi (18+, yalnızca `birth_year` saklanır)
  3. Vücut bilgileri (cinsiyet, boy, kilo, kg/lb)
  4. Aktivite ve hedef
  5. Kalori önizlemesi
  6. Bildirim izni
  7. **Tema seçimi:** Mono ve Canlı kartları canlı önizlemeyle gösterilir, Canlı önceden seçilidir. Açık/koyu/sistem seçimi de burada yapılır.
  - Bitişte `onboarding_completed = true` yazılır ve yerel `onboarded.<userId>` bayrağı tutulur.
- [ ] **Step 1: Failing widget tests:**
  - `KVKK onaylanmadan ileri gidilemez`
  - `17 yaş reddedilir`
  - `tema adımında Canlı seçili gelir`
  - `bitirince profil güncellenir ve /bugun açılır`
  - `geri tuşu bir önceki adıma döner, girilen değerler korunur`
- [ ] **Step 2-4:** FAIL → uygula → PASS.
- [ ] **Step 5:** Commit ve push: `feat(onboarding): 7 adımlı onboarding ve tema seçimi`.

---

### Task 16: Profil sekmesi ve ayarlar

**Files:**
- Create: `lib/ui/profile/{profile_screen,body_goal_screen,theme_gallery_screen,password_screen,delete_account_screen}.dart`, `lib/data/export/export_service.dart`
- Test: `test/ui/profile/profile_screens_test.dart`, `test/data/export/export_service_test.dart`

**Interfaces:**
- Consumes: `ProfileRepository`, `ThemeController`, `AuthRepository`, `validateManualCalorieTarget`, `calorieTargetForProfile`, `notification_settings`, `RemoteGateway`, `NotificationService.showTest` (Task 14, Profil'de "Deneme bildirimi" düğmesi).
- Produces: RN `src/app/(tabs)/profile.tsx` ve `src/app/settings/*` karşılıkları.
  - **Vücut ve hedef:** otomatik ya da elle kalori hedefi. Alt sınırın altındaki değer engellenir, 5000 üstünde uyarı gösterilir.
  - **Tema galerisi:** "Profesyonel" (Mono) ve "Eğlenceli" (Canlı) bölümleri, her biri açık ve koyu önizleme kartıyla. Altında 10 renklik vurgu seçici ve açık/koyu/sistem seçimi. Seçim anında uygulanır.
  - **Diğer ayarlar:** kg/lb, hafta başlangıcı, saat dilimi (`isValidTimeZone` ile doğrulanan liste), bildirim ayarları (açık/kapalı, görev öncesi dakika) ve izin durumu.
  - **Şifre değiştir:** yalnızca `hasPasswordIdentity` ise görünür. Mevcut şifreyle yeniden doğrulama gerekir.
  - **Dışa aktar:** `ExportService.exportJson()`. 8 kullanıcı tablosu sunucudan id'ye göre 1000'lik sayfalarla çekilir, `missionfit-export-<tarih>.json` dosyası paylaşma menüsüyle açılır. İnternet yoksa yerel DB'den aktarılır ve kullanıcıya bildirilir.
  - **Hesabı sil:** onay metni yazdırılır. Ardından şifreyle ya da Google ile yeniden doğrulama yapılır, `functions.invoke('delete-account')` çağrılır, `clearAllUserData` çalışır ve `/giris` açılır.
  - **Çıkış:** onay penceresi gösterilir, ardından `signOut`.
- [ ] **Step 1: Failing tests:**
  - `elle hedef alt sınırın altındaysa kaydet pasif`
  - `galeride Mono'ya dokununca tema anında değişir`
  - `şifre değiştir yalnızca e-posta kimliğinde görünür`
  - `export 8 tabloyu içerir ve 2500 satırı sayfalar`
  - `hesap silmede yeniden doğrulama başarısızsa fonksiyon çağrılmaz`
- [ ] **Step 2-4:** FAIL → uygula → PASS.
- [ ] **Step 5:** Commit ve push: `feat(profile): profil, tema galerisi, dışa aktarma ve hesap silme`.

---

### Task 17: Kullanıcının yapacağı kurulumlar ve cihaz testi

Bu görev kodlama değil. Kullanıcıyla birlikte, adım adım yapılır. Her adımda ne yapılacağı kullanıcıya Türkçe anlatılır ve sonucu doğrulanır.

- [ ] **Step 1: Gmail SMTP.**
  1. Google hesabında iki adımlı doğrulama açılır.
  2. myaccount.google.com → Güvenlik → Uygulama şifreleri → "MissionFit Supabase" adıyla 16 haneli şifre oluşturulur.
  3. Supabase paneli → Authentication → Emails → SMTP Settings: host `smtp.gmail.com`, port `587`, kullanıcı adı Gmail adresi, şifre uygulama şifresi, gönderen adı "MissionFit".
  4. Rate limit sayfasında e-posta limiti makul bir değere (ör. saatte 30) çekilir.
  - **Doğrulama:** Başka bir e-posta adresiyle kayıt olunur, 8 haneli kod gelir.
- [ ] **Step 2: Google ile giriş.**
  1. Google Cloud Console'da proje açılır, OAuth onay ekranı yapılandırılır (External, test kullanıcısı olarak kendi adresi).
  2. **Web istemcisi** oluşturulur. Client ID ve secret, Supabase → Authentication → Providers → Google'a girilir.
  3. **Android istemcisi** oluşturulur: paket `com.alperen.missionfit` ve SHA-1. SHA-1 şu komutla alınır: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`.
  4. Web Client ID `env.json` içindeki `GOOGLE_WEB_CLIENT_ID` alanına yazılır.
  - **Doğrulama:** Telefonda "Google ile devam et" ile giriş yapılır. E-postayla kayıtlı aynı adres kullanılırsa aynı hesaba girildiği (verilerin göründüğü) kontrol edilir.
- [ ] **Step 3: Cihazda uçtan uca kontrol listesi** (Nothing Phone 2a, `flutter run --release --dart-define-from-file=env.json`):
  - [ ] Kayıt → kod → onboarding (7 adım) → Bugün
  - [ ] Çıkış → başka hesapla giriş → önceki hesabın verisi görünmüyor
  - [ ] Mono ↔ Canlı, açık ↔ koyu, 10 vurgu rengi: yazılar okunuyor, hap vurgu renginde
  - [ ] Uçak modunda uygulamayı kapatıp aç: açılıyor, profil görünüyor. Profilde değişiklik yap, uçak modunu kapat: sunucuya gidiyor.
  - [ ] RN uygulamasında bir yemek kaydı ekle ve sil. Flutter'da çekip yenile, silme kaydı geldi mi kontrol et (veritabanında `deletions` sorgusuyla).
  - [ ] Dışa aktarma dosyası paylaşma menüsünde açılıyor.
  - [ ] Deneme bildirimi geliyor.
  - [ ] Hesap silme (ayrı bir test hesabıyla).
- [ ] **Step 4:** `DEVAM.md` dosyasını güncelle ("Aşama 1 tamam, sıradaki: Aşama 2 tasarımı"). Ardından commit ve push: `docs: Aşama 1 tamamlandı`.
