# Aşama 2a: Antrenmanın kalbi (Uygulama planı)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Antrenman sekmesinde 3B kaslı atlet maketi (Mono: nokta-matris, Canlı: parlayan heykel), liste kurarak başlama, klavyesiz odak modu, kilit ekranında akan dinlenme sayacı, kaydetme ve özet.

**Architecture:**
- **Kurallar (saf Dart, `lib/domain`):** yoğunluk, ağırlık adımı, aktif antrenman durumu.
- **Veri:** drift + outbox. Mevcut `workout_sessions` ve `session_sets` kullanılır. Antrenman planı ve dinlenme hafızası yalnızca telefonda tutulur (şema v4).
- **Maket:** Blender'da çizilen 72 karelik dönüş (ışıklı görüntü + bölge kimliği), telefonda tek bir `FragmentProgram` shader'ı ile boyanır. Tema alanı `bodyMapStyle` stili seçer.
- **Dinlenme:** geri sayan kronometreli bildirim + bitiş için tam zamanlı alarm.

**Tech Stack:**
- Flutter 3.50 / Dart 3.14, Riverpod 3, go_router, drift, flutter_local_notifications 23.
- Yeni paketler: `uuid`, `wakelock_plus`.
- Blender 4.x + MPFB eklentisi (yalnızca varlık üretimi, `tools/body_map/`).

**Spec:** `docs/superpowers/specs/2026-11-19-asama-2a-antrenman-design.md`

## Global Constraints

- Sunucu şeması değişmez. Antrenman yazımı outbox ile: `workout_sessions.upsert/delete`, `session_sets.upsert/delete`; key `<tablo>:<id>`.
- Sunucu kuralları (aynen geçerli):
  - Kullanıcı başına tek `status='active'` oturum.
  - `status != 'active'` ise `ended_at` dolu.
  - `set_index` 1–50.
  - `(session_id, exercise_order, set_index)` benzersiz.
  - `reps` 1–500, `duration_seconds` 1–86400, `weight_kg` 0–1000 (0,1 hassasiyet).
  - `reps` ya da `duration_seconds`'tan en az biri dolu.
- `exercise_order` = hareketin ilk setinin yapıldığı sıra (0'dan). Sıra değişince var olan setler yeniden yazılmaz.
- 14 bölge kimliği (sıra sabit, kimlik = sıra + 1; 0 = cilt, 255 = boş): `chest, shoulders, biceps, triceps, forearms, abs, obliques, traps, lats, lower_back, glutes, quads, hamstrings, calves`.
- Yoğunluk: birincil kas 1, ikincil 0,5 ağırlıklı set. Kademeler **0 / >0 ve <4 / 4–<10 / ≥10** (seviye 0–3). Hafta profilin `weekStartsOn` ve saat dilimine göre.
- Ağırlık adımı (kg): barbell 2,5 · dumbbell 2 · machine 5 · cable 5 · kettlebell 4 · diğer 2,5. lb birimde: 5 · 5 · 10 · 10 · 5 · 5. `bodyweight` ve `cardio`'da ağırlık alanı yok.
- Takip tipleri: `weight_reps` (ağırlık + tekrar), `reps` (tekrar), `duration` (süre, –/+ 5 sn).
- Hedef set: şablonun `sets` değeri; yoksa o hareketin son antrenmandaki set sayısı; yoksa 3. Hedef bir sınır değildir ("+ Set").
- Dinlenme: varsayılan 90 sn; şablondan başlanınca `rest_seconds`; hareket başına son kullanılan süre telefonda hatırlanır. ±15 sn, en az 15 sn.
- Metinler (aynen):
  - "Antrenmana başla", "Seti tamamla", "Dinlen", "Atla", "+15 sn", "–15 sn", "Son seti düzenle", "Geri al", "Seti sil", "+ Set", "+ Ekle", "Bitir", "Devam et", "Tekrarla", "Hazır programlar", "Boş başla", "Bu hafta".
  - Dinlenme bildirim kanalının adı "Dinlenme".
- Boyutlar ve titreşim:
  - –/+ ve ana düğme 60 dp; diğer dokunma alanları ≥ 48 dp.
  - Titreşim yalnızca iki yerde: set tamamlanınca `HapticFeedback.lightImpact`, dinlenme bitince bildirim titreşimi (ve uygulama öndeyse `heavyImpact`).
- Erişilebilirlik:
  - Metin kontrastı ≥ 4,5:1, ikon ve sınırlar ≥ 3:1 (Mono/Canlı × açık/koyu).
  - Bilgi yalnızca renkle verilmez.
  - `MediaQuery.disableAnimations` açıkken maket dönmez, halka akmaz (saniyede bir adım).
  - Sayaç ekran okuyucuda "kalan 1 dakika 12 saniye" diye okunur.
- Maket varlıkları: `assets/body_map/` altında toplam ≤ 4 MB. Blender betiği `tools/body_map/` altında depoya girer.
- Model MakeHuman/MPFB (CC0), kaslı ve düşük yağlı erkek. "Kaba" görünüm kabul edilmez. Görsel onay kullanıcıdan alınır (Görev 5).
- Commit: Türkçe mesaj + boş satır + `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, ardından `git push -q`. `dart format lib test`, `flutter analyze` ("No issues found!"), `flutter test` her commit öncesi.

## Review Focus

1. **Uygulama dinlenme sırasında kapatılır:** Açılınca sayaç kalan süreden devam eder; süre geçtiyse dinlenme bitmiş sayılır. Bitiş bildirimi uygulama kapalıyken de gelir. (Görev 9 testi)
2. **Son set silinip yeni set tamamlanır:** Aynı `set_index` yeniden kullanılır. Outbox'ta silme işlemi yazma işleminden önce durur, sunucudaki benzersizlik çakışmaz. (Görev 3 testi)
3. **Hareketler arasında gidip gelinir:** Seti tamamlanmamış bir harekette –/+ ile değiştirilen değerler başka harekete geçip dönünce korunur. (Görev 7 testi)
4. **Hiç set yapılmadan "Bitir":** Antrenman kaydedilmez, oturum silinir. Kullanıcıya "Hiç set yok, antrenman kaydedilmedi." gösterilir. (Görev 10 testi)
5. **Başka telefonda yarım kalmış aktif oturum senkronla gelmiş:** Yeni antrenman başlatılınca eski oturum önce `abandoned` yapılır (`ended_at` = şimdi), sonra yenisi yazılır. Sunucudaki "tek aktif" kuralı yeni oturumu reddetmez. (Görev 3 testi)

---

## Dosya haritası

- **Kurallar:** `lib/domain/body_map.dart`, `lib/domain/weight_step.dart`, `lib/domain/active_workout.dart`
- **Veri:**
  - Yeni: `lib/data/workout/workout_repository.dart`, `lib/data/workout/workout_queries.dart`
  - Değişen: `lib/data/db/tables.dart` (+`ActiveWorkoutPlans`, `RestMemory`), `lib/data/db/database.dart` (v4)
- **Uygulama durumu:** `lib/app/active_workout_controller.dart`, `lib/app/rest_timer.dart`, `lib/app/workout_providers.dart`
- **Maket:**
  - Betik: `tools/body_map/build_body_map.py`, `tools/body_map/regions.json`, `tools/body_map/README.md`
  - Varlıklar: `assets/body_map/{manifest.json, shade_000..071.webp, id_000..071.png}`
  - Shader: `shaders/body_map.frag`
  - Bileşen: `lib/ui/components/body_map/{body_map.dart, body_map_frames.dart}`
- **Ekranlar (`lib/ui/training/`):** `training_screen.dart`, `start_workout_screen.dart`, `focus_screen.dart`, `focus_widgets.dart` (stepper, set noktaları, şerit), `rest_screen.dart`, `workout_summary_screen.dart`, `training_routes.dart`
- **Değişenler:**
  - `lib/ui/theme/mf_theme.dart` (+`bodyMapStyle`)
  - `lib/ui/router.dart` (yakında ekranı yerine eğitim rotaları)
  - `lib/data/notifications/notification_service.dart` (+dinlenme)
  - `android/app/src/main/AndroidManifest.xml` (+`USE_EXACT_ALARM`)
  - `pubspec.yaml` (paketler, `assets/body_map/`, `shaders/`)
  - `lib/ui/profile/` bilgi ekranı (atıf satırı)

---

### Task 1: Yoğunluk ve ağırlık adımı kuralları

**Files:** Create `lib/domain/body_map.dart`, `lib/domain/weight_step.dart`; Test `test/domain/body_map_test.dart`, `test/domain/weight_step_test.dart`

**Interfaces:**
- Produces:
  - `const List<String> bodyMapMuscles` (Global Constraints'teki 14 slug, sırayla)
  - `int bodyMapRegionId(String muscleSlug)`: bilinmeyen slug için 0
  - `int bodyMapLevel(double weightedSets)`: 0–3
  - `int frameForAngle(double degrees, {int frames = 72})`: negatif ve 360 üstü açıları sarar
- Produces:
  - `double weightStep(String equipment, WeightUnit unit)`
  - `bool tracksWeight(String tracking, String equipment)`: `weight_reps` ve ekipman `bodyweight`/`cardio` değilse true
  - `double stepWeight(double kg, int direction, String equipment, WeightUnit unit)`: kullanıcının biriminde adımlar, kg döndürür, 0,1'e yuvarlar, alt sınır 0

- [ ] **Step 1: Testler**
  - `bodyMapRegionId('chest') == 1`, `('calves') == 14`, `('foo') == 0`.
  - `bodyMapLevel(0) == 0`, `(0.5) == 1`, `(3.5) == 1`, `(4) == 2`, `(9.5) == 2`, `(10) == 3`, `(double.nan) == 0`.
  - `frameForAngle(0) == 0`, `(5) == 1`, `(357.6) == 0`, `(-5) == 71`, `(362.5) == 1` (en yakın kareye yuvarlama, 2,5 yukarı).
  - `weightStep('barbell', kg) == 2.5`, `('dumbbell', kg) == 2`, `('machine', lb) == 10`, `('band', kg) == 2.5`.
  - `tracksWeight('weight_reps','barbell')` true, `('weight_reps','bodyweight')` false, `('reps','dumbbell')` false.
  - `stepWeight(60, 1, 'barbell', kg) == 62.5`.
  - `stepWeight(1, -1, 'barbell', kg) == 0`.
  - lb'de 100 kg'dan bir adım yukarı → `toKg(fromKg(100, lb) + 5, lb)`.
- [ ] **Step 2:** `flutter test test/domain/body_map_test.dart test/domain/weight_step_test.dart` → FAIL
- [ ] **Step 3:** Uygula (saf Dart, `units.dart`'taki `toKg/fromKg` kullanılır).
- [ ] **Step 4:** PASS + `flutter analyze`
- [ ] **Step 5: Commit** `feat(domain): maket yoğunluğu ve ağırlık adımı`

### Task 2: Aktif antrenman kuralları

**Files:** Create `lib/domain/active_workout.dart`; Test `test/domain/active_workout_test.dart`

**Interfaces:**
- Produces:
  - `class PlannedExercise {String exerciseId; String tracking; String equipment; int targetSets; int restSeconds}`
  - `class LoggedSet {String id; String exerciseId; int exerciseOrder; int setIndex; int? reps; int? durationSeconds; double? weightKg; DateTime completedAt}`
  - `class SetValues {double? weightKg; int? reps; int? durationSeconds}`
  - `class ActiveWorkout {String sessionId; DateTime startedAt; List<PlannedExercise> plan; List<LoggedSet> sets; String? currentExerciseId}`. Değişmez; tüm yöntemler yeni nesne döndürür. `==`/`hashCode` vardır.
- `ActiveWorkout` yöntemleri:
  - `int orderFor(String exerciseId)`: o hareketin seti varsa onun sırası; yoksa `max(exerciseOrder) + 1`, hiç set yoksa 0.
  - `int nextSetIndex(String exerciseId)`: `max(setIndex) + 1`; set yoksa 1; 50'yi geçerse `StateError`.
  - `int doneSets(String exerciseId)`
  - `ActiveWorkout addExercise(PlannedExercise e)`: aynı hareket varsa değişmez; yeni hareket planın sonuna eklenir ve current olur.
  - `ActiveWorkout select(String exerciseId)`
  - `ActiveWorkout logSet(LoggedSet s)`, `ActiveWorkout replaceSet(LoggedSet s)`, `ActiveWorkout removeSet(String setId)`
  - `({String exerciseId, int setIndex})? nextUp()`:
    - Current'ın yapılan seti hedefinin altındaysa → current'ın sıradaki seti.
    - Değilse plan sırasında, current'tan sonra (sonra başa dönerek) yapılan seti hedefin altında kalan ilk hareket.
    - Hiçbiri yoksa null.
- `SetValues prefill(String exerciseId, ActiveWorkout w, List<LoggedSet> lastSessionSets)`:
  - Bu antrenmanda bu hareketin son seti varsa → onun değerleri.
  - Yoksa son antrenmandaki aynı `setIndex`'li set; o yoksa son antrenmandaki son set.
  - Hiçbiri yoksa boş.
- `int targetSetsFor({int? templateSets, int? lastSessionSetCount})` → `templateSets ?? lastSessionSetCount ?? 3`

- [ ] **Step 1: Testler**
  - **Sıra:** Bench (order 0) 2 set → Dips'e geç, 1 set → Dips order 1. Bench'e dön, 3. set → order 0, setIndex 3.
  - **Silme:** Bench'in 3. setini sil → `nextSetIndex('bench') == 3` (Review Focus 2'nin kural kısmı).
  - **nextUp, current eksik:** hedef 3, yapılan 2 → `(bench, 3)`.
  - **nextUp, current tamam:** sıradaki eksik hareket döner. Hepsi tamamsa null.
  - **nextUp, başa dönme:** current son hareketse ve ilk hareket eksikse ilk hareket döner.
  - **addExercise:** aynı hareketi iki kez eklemek değiştirmez.
  - **prefill:** üç durum. 2. set için geçen antrenmanın 2. seti `60×7` ise → `60×7`. Bu antrenmanda 1. set `62.5×8` yapıldıysa 2. set → `62.5×8`.
  - **targetSetsFor:** `(templateSets: 4)` → 4, `(lastSessionSetCount: 5)` → 5, `()` → 3.
  - **Sınır:** `nextSetIndex` 50 sette `StateError`.
- [ ] **Step 2:** FAIL. **Step 3:** Uygula. **Step 4:** PASS + analyze.
- [ ] **Step 5: Commit** `feat(domain): aktif antrenman kuralları`

### Task 3: Yerel şema v4 ve antrenman deposu (yazma)

**Files:**
- Modify `lib/data/db/tables.dart`, `lib/data/db/database.dart`, `pubspec.yaml` (`uuid`)
- Create `lib/data/workout/workout_repository.dart`
- Test `test/data/workout/workout_repository_test.dart`, `test/data/db/database_test.dart` (göç)

**Interfaces:**
- Consumes: Görev 2 tipleri; `OutboxRepository.enqueue`; `weekKeyOf`, `localDateInZone`; `estimateWorkoutKcal`.
- Produces: tablo `ActiveWorkoutPlans` (yalnızca yerel)
  - Sütunlar: `sessionId` (pk), `userId`, `planJson` (PlannedExercise listesi), `currentExerciseId`, `restEndsAt` (ISO, nullable), `updatedAt`.
- Produces: tablo `RestMemory` (yalnızca yerel)
  - Sütunlar: `userId`, `exerciseId`, `seconds`; pk (userId, exerciseId).
- Produces: `class WorkoutRepository(AppDatabase db, OutboxRepository outbox, {DateTime Function()? clock, String Function()? newId})`
  - `Future<ActiveWorkout> start({required String userId, required List<PlannedExercise> plan, String? templateId, String name = 'Antrenman', required String timeZone, required WeekStartsOn weekStartsOn})`
    - Önce yereldeki diğer `active` oturumları `abandoned` + `ended_at = şimdi` yapar ve outbox'a yazar (Review Focus 5).
  - `Future<ActiveWorkout?> loadActive(String userId)`
  - `Future<void> savePlan(ActiveWorkout w)`
  - `Future<LoggedSet> completeSet(ActiveWorkout w, String exerciseId, SetValues v)`: sırayı ve indeksi Görev 2'den alır.
  - `Future<void> updateSet(LoggedSet s)`
  - `Future<void> deleteSet(LoggedSet s)`
  - `Future<WorkoutFinish> finish(ActiveWorkout w, {required double? bodyWeightKg})`
    - `sealed WorkoutFinish`: `Saved(int kcal)` | `DiscardedEmpty`. Set yoksa oturum silinir (Review Focus 4).
  - `Future<void> discard(String sessionId)`: oturumu ve setleri siler (sunucuda cascade; outbox'a tek `workout_sessions.delete`).
  - `Future<void> setRestEnd(String sessionId, DateTime? endsAt)`
  - `Future<int?> restSecondsFor(String userId, String exerciseId)`, `Future<void> rememberRest(String userId, String exerciseId, int seconds)`

- [ ] **Step 1: Testler** (bellek içi drift)
  - **v3 → v4 göçü:** mevcut satırlar korunur, iki yeni tablo vardır.
  - **start:**
    - Oturum `active` yazılır, `week_key` profilin hafta başlangıcına göre.
    - Outbox'ta `workout_sessions.upsert`.
    - Yerelde eski bir `active` oturum varsa önce o `abandoned` olur (`ended_at` dolu) ve outbox'ta yeni oturumdan önce durur.
  - **completeSet:** `session_sets.upsert` yazar; payload'da `exercise_order` ve `set_index` doğru, `weight_kg` 0,1'e yuvarlı.
  - **Silip yeniden ekleme:** 3. set silinir, yeni set tamamlanır → yeni set `set_index` 3 alır. Outbox sırası `session_sets.delete` (eski id) → `session_sets.upsert` (yeni id) (Review Focus 2).
  - **updateSet:** aynı id ile upsert; key aynı olduğu için outbox'ta tek işlem kalır.
  - **finish:**
    - Setliyken `status='completed'`, `ended_at`, `estimated_kcal` yazılır ve `Saved` döner.
    - Setsizken oturum silinir ve `DiscardedEmpty` döner.
  - **loadActive:** plan ve setlerle birlikte geri gelir; `restEndsAt` korunur.
  - **rememberRest/restSecondsFor:** gidiş-dönüş.
- [ ] **Step 2:** FAIL. **Step 3:** `schemaVersion => 4`, `if (from < 4)` ile iki tablo oluşturulur; `dart run build_runner build -d`. Uygula.
- [ ] **Step 4:** `flutter analyze && flutter test` PASS
- [ ] **Step 5: Commit** `feat(data): antrenman deposu ve yerel plan tablosu`

### Task 4: Antrenman sorguları (okuma)

**Files:** Create `lib/data/workout/workout_queries.dart`, `lib/app/workout_providers.dart`; Test `test/data/workout/workout_queries_test.dart`

**Interfaces:**
- Consumes: `muscleCoverage`, `MuscleInfo`, `ExerciseMuscle`, `CoverageSet`, `weekWindow`, `bodyMapLevel`.
- Produces: `class WorkoutQueries(AppDatabase db)`
  - `Stream<WeeklyBodyMap> watchWeek(String userId, WeekWindow window)`
    - `WeeklyBodyMap {Map<String, double> muscleSets; Map<String, int> levels; Map<String, LocalDate?> lastWorked; int regionsWorked; int totalSets}`
    - Yalnızca `completed` ve `active` oturumların setleri sayılır.
  - `Future<List<LoggedSet>> lastSessionSets(String userId, String exerciseId, {String? excludingSessionId})`
  - `Future<List<RecentWorkout>> recent(String userId, {int limit = 3})`
    - `RecentWorkout {String sessionId; String name; DateTime startedAt; List<String> exerciseIds; int setCount}`
  - `Future<List<ExerciseOption>> exercisesForRegion(String userId, BodyRegion region)`
    - `ExerciseOption {String id; String nameTr; String tracking; String equipment; DateTime? lastDoneAt}`
    - Sıralama: önce kullanıcının yaptıkları (son yapılana göre), sonra katalogdakiler (ada göre).
  - `Future<List<ExerciseOption>> searchExercises(String query)`: Türkçe büyük/küçük harf duyarsız.
  - `Future<List<PlannedExercise>> templatePlan(String templateId)`
- Produces (Riverpod):
  - `weeklyBodyMapProvider` (StreamProvider; aktif kullanıcı, profilin hafta ayarı ve `todayProvider`)
  - `recentWorkoutsProvider`
  - `workoutQueriesProvider`, `workoutRepositoryProvider`

- [ ] **Step 1: Testler**
  - Pazartesi bench 4 set (göğüs birincil, triceps ve omuz ikincil) → `muscleSets.chest == 4`, `triceps == 2`, `levels.chest == 2`, `lastWorked.chest` = o gün.
  - Önceki haftanın setleri sayılmaz. `abandoned` oturum sayılmaz.
  - **lastSessionSets:** en son tamamlanan oturumdaki setler, `setIndex` sırasıyla; aktif oturum hariç tutulabilir.
  - **exercisesForRegion(chest):** kullanıcının yaptığı dips ve bench başta (son yapılan önce), ardından katalog.
  - **searchExercises('şınav')** ve **('ŞINAV')** aynı sonucu verir.
  - **templatePlan:** `targetSets` ve `restSeconds` şablondan gelir.
- [ ] **Step 2:** FAIL. **Step 3:** Uygula. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(data): haftalık maket ve antrenman sorguları`

### Task 5: Maket varlıkları (Blender hattı) — kullanıcı onayıyla

**Files:**
- Create `tools/body_map/build_body_map.py`, `tools/body_map/regions.json`, `tools/body_map/README.md`
- Create `assets/body_map/manifest.json`, `assets/body_map/shade_NNN.webp`, `assets/body_map/id_NNN.png`

**Interfaces:**
- Produces: `manifest.json`
  - `{ "frames": 72, "stepDegrees": 5, "width": W, "height": H, "regions": [14 slug, sırayla], "attribution": "MakeHuman / MPFB (CC0)" }`
- Produces: `shade_NNN.webp`
  - Gri tonlu ışıklı görüntü, arka plan şeffaf. 000 = ön görünüm; açı saat yönünde artar (yukarıdan bakınca).
- Produces: `id_NNN.png`
  - Kayıpsız; kırmızı kanal = bölge kimliği × 17 (0 = cilt, 1–14 bölge, 15 × 17 = 255 boş). Kenar yumuşatması yok.

- [ ] **Step 1:** `sudo pacman -S --needed blender` (kullanıcı onay verdi). MPFB eklentisini kur (`blender --command extension install` ya da extensions.blender.org'dan zip). README'ye sürümleri yaz.
- [ ] **Step 2:** Betik (`blender -b -P tools/body_map/build_body_map.py -- --out assets/body_map`):
  1. MPFB ile erkek insan oluştur: kas yüksek, yağ düşük, atletik oranlar. Göz, kaş ve saç yok; nötr ayakta duruş, kollar hafif açık.
  2. `regions.json`'daki yüz seçimleriyle 14 vertex group oluştur. Seçimler kas sınırlarına göre bir kez elle ayarlanır ve JSON'a kaydedilir; betik bunları uygular.
  3. Işıklı görüntü: Cycles, nötr gri malzeme, yumuşak üç nokta + kenar ışığı, AO; 72 açı.
  4. Kimlik haritası: aynı açılar, emission malzeme bölge rengi, filtre yok (Workbench ya da Eevee flat, AA kapalı).
  5. WebP/PNG'ye çevir ve `manifest.json` yaz.
- [ ] **Step 3: Doğrulama**
  - **Boyut:** `du -sh assets/body_map` ≤ 4 MB. Aşarsa çözünürlüğü düşür (önce 720 → 600 px yükseklik).
  - **Kimlik değerleri:** Bir Python kontrolü `id_000.png`'deki benzersiz kırmızı değerlerin yalnızca {0,17,…,238,255} olduğunu doğrular.
  - **Ön ve arka:** Ön karede (000) chest/abs/quads, arka karede (036) lats/glutes/hamstrings görünür.
- [ ] **Step 4: Kullanıcı onayı (zorunlu kapı).**
  - Kontrolcü, 000/018/036 karelerinin örnek boyalı hâllerini tarayıcıda kullanıcıya gösterir: bu haftanın örnek yoğunluğu, Mono noktalı + Canlı parıltılı (basit önizleme).
  - Ölçüt: "kaba durmamalı". Onay gelmeden Görev 6'ya geçilmez. Düzeltme gerekirse bu görevde yinelenir.
- [ ] **Step 5: Commit** `feat(assets): 3B kaslı atlet maketi kareleri`

### Task 6: Maket bileşeni (shader)

**Files:**
- Create `shaders/body_map.frag`, `lib/ui/components/body_map/body_map.dart`, `lib/ui/components/body_map/body_map_frames.dart`
- Modify `lib/ui/theme/mf_theme.dart`, `pubspec.yaml` (`shaders`, `assets`)
- Test `test/ui/components/body_map_test.dart`

**Interfaces:**
- Consumes: manifest (Görev 5), `frameForAngle`, `bodyMapRegionId`, tema.
- Produces:
  - `enum BodyMapStyle { dots, glow }`
  - `MfTheme.bodyMapStyle`: Mono → `dots`, Canlı → `glow`. `copyWith` ve `lerp` ile çalışır.
- Produces: `class BodyMapFrames` (bütün kareleri `ui.Image` olarak yükler)
  - `static Future<BodyMapFrames> load(AssetBundle bundle)`
  - `int regionAt(int frame, Offset localPos, Size size)`: kimlik görüntüsünün ham pikselinden; boşta −1.
- Produces: `class BodyMap extends StatefulWidget`
  - Parametreler: `{required Map<String, int> levels, ValueChanged<String>? onRegionTap, String semanticLabel}`
  - Sürükleme açıyı değiştirir, bırakınca yumuşakça durur.
  - İlk gösterimde bir tam tur döner. `MediaQuery.disableAnimations` açıkken dönmez, 000'da durur.
  - Kareler yüklenirken yerini koruyan boş bir kutu gösterir.
  - Tek dokunuş → `onRegionTap(slug)`.
- Shader uniform'ları: `uSize`, `uAccent`, `uBase`, `uOff`, `uStyle` (0 dots / 1 glow), `uPitch` (nokta aralığı, px), `uLevels[15]` (0–3), sampler `uShade`, `uIds`.
  - **Mono:** ekran ızgarası hücresinin merkezinden örnek alır. Nokta yarıçapı ışık değeriyle ve seviyeyle büyür; renk seviye > 0 ise vurgu, değilse `uOff`.
  - **Canlı:** ışık değeri × taban renk; seviye > 0 ise vurgu karışımı ve seviyeyle artan parıltı.

- [ ] **Step 1: Testler**
  - **Varlık okuma:** `BodyMapFrames.load` gerçek varlıklarla 72 kare yükler.
  - **regionAt:** ön karede göğsün ortasına denk gelen noktada (manifestten hesaplanan oran) `regionAt` → 1. Görüntünün köşesi → −1.
  - **Widget:** `disableAnimations: true` altında açı 0'da kalır.
  - **Dokunma:** göğse dokununca `onRegionTap('chest')`.
  - **Erişilebilirlik:** `Semantics` etiketi parametreden gelir.
  - **Tema:** Mono'da `bodyMapStyle == dots`, Canlı'da `glow`.
  - Shader derlenmesi `flutter test` ortamında desteklenmiyorsa boyama testi atlanır; `FragmentProgram.fromAsset` yalnızca cihazda doğrulanır (Görev 11).
- [ ] **Step 2:** FAIL. **Step 3:** Uygula. **Step 4:** PASS + analyze.
- [ ] **Step 5: Commit** `feat(ui): 3B maket bileşeni`

### Task 7: Odak modu

**Files:**
- Create `lib/app/active_workout_controller.dart`, `lib/ui/training/focus_screen.dart`, `lib/ui/training/focus_widgets.dart`, `lib/ui/training/training_routes.dart` (`/antrenman/odak`, kabuk dışında tam ekran); Modify `lib/ui/router.dart`
- Modify `pubspec.yaml` (`wakelock_plus`)
- Test `test/ui/training/focus_screen_test.dart`, `test/app/active_workout_controller_test.dart`

**Interfaces:**
- Consumes: Görev 2 ve 3, `stepWeight`, `tracksWeight`, `prefill`.
- Produces: `activeWorkoutControllerProvider` (`AsyncNotifier<ActiveWorkout?>`)
  - `start(plan, {templateId, name})`, `select(exerciseId)`, `addExercise(PlannedExercise)`
  - `Future<LoggedSet> completeSet(SetValues v)`, `undoLast()`, `editSet(LoggedSet)`, `deleteSet(LoggedSet)`
  - `Future<WorkoutFinish> finish()`, `discard()`
- Produces: `onSetCompletedProvider` (`Provider<void Function(String exerciseId)>`, varsayılan boş). Odak modu set tamamlanınca çağırır; Görev 9 dinlenmeyi başlatacak şekilde değiştirir.
- Produces (UI durumu, bellekte): `Map<String, SetValues> draftValues` — hareket başına düzenlenmekte olan değerler (Review Focus 3).

- [ ] **Step 1: Testler**
  - **Açılış:** ilk hareket; değerler `prefill`'den. İlk kez yapılan harekette alanlar boş ve "Seti tamamla" pasif.
  - **–/+:**
    - "+" ağırlığı ekipman adımıyla artırır. Basılı tutunca tekrarlar (`tester.startGesture` + 1 sn bekle → birden çok adım).
    - Tekrar 1'in altına inmez.
  - **Seti tamamla:**
    - Set yazılır, `HapticFeedback` çağrılır, `onSetCompletedProvider` çağrılır (sahteyle doğrulanır; dinlenme ekranı Görev 9).
    - 5 sn "Geri al" görünür; basınca set silinir.
  - **Set noktası:** 1'e dokun → düzenleme sayfası. Değeri değiştir + "Kaydet" → güncellenir. "Seti sil" → onay → silinir.
  - **Şerit:**
    - "Dips"e dokun → current değişir. Bench'te 65'e çıkarılmış ama tamamlanmamış değer geri dönünce 65 olarak durur (Review Focus 3).
    - "+ Ekle" → arama sayfası → eklenen hareket şeritte sonda ve current.
  - **Hedef dolunca:** "+ Set" görünür.
  - **Takip tipine göre:** `bodyweight` harekette ağırlık alanı yok. `duration` harekette süre –/+ 5 sn ve "Başlat" ile sayan kronometre; durdurunca süre alana yazılır.
  - **Geri tuşu:** "Antrenmanı bitir / devam" diyalogu.
  - **Ekran açık kalır:** wakelock açılır; ekrandan çıkınca kapanır (sahte arayüzle test).
  - **Erişilebilirlik:** –/+ düğmelerinin semantik adları "ağırlığı azalt", "ağırlığı artır", "tekrarı azalt", "tekrarı artır". Boyutları ≥ 60 dp.
- [ ] **Step 2:** FAIL. **Step 3:** Uygula. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(training): odak modu`

### Task 8: Antrenman sekmesi ve başlama ekranı

**Files:**
- Create `lib/ui/training/training_screen.dart`, `lib/ui/training/start_workout_screen.dart`
- Modify `lib/ui/training/training_routes.dart` (Görev 7'de oluşturuldu), `lib/ui/router.dart` ("yakında" ekranı kalkar)
- Test `test/ui/training/training_screen_test.dart`

**Interfaces:**
- Consumes: `weeklyBodyMapProvider`, `recentWorkoutsProvider`, `WorkoutQueries`, `BodyMap`, `activeWorkoutControllerProvider.start(...)` (Görev 7).
- Produces: rotalar
  - `/antrenman` (sekme)
  - `/antrenman/basla` (liste kurma)
  - `/antrenman/ozet/:sessionId`
  - (`/antrenman/odak` Görev 7'de)

- [ ] **Step 1: Testler**
  - **Sekme:**
    - "Bu hafta" başlığı, bölge sayısı ("5/9" değil, `regionsWorked/14`), 6 üst bölgeli liste. Liste satırları set sayılarını sayı olarak yazar.
    - Satıra dokununca kasları açılır, "Son çalışma: 2 gün önce" görünür.
  - **Antrenmana başla** → `/antrenman/basla`.
  - **Tekrarla:** Son 3 antrenman listelenir. "Tekrarla" aynı hareketlerle odak moduna açar.
  - **Hazır programlar:** 10 şablon bu başlık altında. Birine dokununca şablon planıyla başlar.
  - **Devam et kartı:** aktif antrenman varsa sekmenin en üstünde "Devam et" kartı görünür.
  - **Başlama ekranı:**
    - Bölge çipi "Göğüs" → kullanıcının yaptıkları önce gelir. İki hareket işaretlenir → "2 hareketle başla" → odak modu ilk hareketle açılır.
    - Arama çalışır.
    - "Boş başla" planı boş başlatır.
- [ ] **Step 2:** FAIL. **Step 3:** Uygula (taslak dili: `odak-modu.html`, `vucut-3d.html`). **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(training): antrenman sekmesi ve başlama ekranı`

### Task 9: Dinlenme sayacı ve kilit ekranı bildirimi

**Files:**
- Create `lib/app/rest_timer.dart`, `lib/ui/training/rest_screen.dart`
- Modify `lib/data/notifications/notification_service.dart`, `android/app/src/main/AndroidManifest.xml`
- Test `test/app/rest_timer_test.dart`, `test/ui/training/rest_screen_test.dart`, `test/data/notifications/rest_notification_test.dart`

**Interfaces:**
- Consumes: `WorkoutRepository.setRestEnd/rememberRest/restSecondsFor`, `nextUp()`, `onSetCompletedProvider` (Görev 7; burada dinlenmeyi başlatan uygulamayla değiştirilir, dinlenme ekranı odak modunun üstünde tam ekran açılır).
- Produces: `restTimerProvider` (`Notifier<RestState?>`)
  - `RestState {DateTime endsAt; int totalSeconds; String exerciseId}`, `Duration remaining(DateTime now)`
  - `start(exerciseId, seconds)`, `adjust(int deltaSeconds)` (en az 15 sn toplam), `skip()`, `restoreFrom(ActiveWorkout)` (yeniden açılışta `restEndsAt`'ten)
- Produces: `NotificationService` eklentileri
  - `Future<void> showRest({required DateTime endsAt, required String nextLabel})`: sürekli, sessiz, `chronometerCountDown`, `when = endsAt`; eylemler "+15 sn" ve "Atla".
  - `Future<void> scheduleRestEnd(DateTime endsAt)`: tam zamanlı, titreşimli.
  - `Future<void> cancelRest()`
  - Kanal: "Dinlenme".
- Manifest: `<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>` eklenir. `SCHEDULE_EXACT_ALARM` kalır.

- [ ] **Step 1: Testler**
  - **Zaman:** `start(bench, 90)` → `remaining(now + 18 sn) == 72 sn`. `adjust(+15)` → 87. `adjust(-200)` → toplam en az 15 sn.
  - **Yeniden açılış:** `endsAt` gelecekteyse sayaç sürer. Geçmişteyse `null` (dinlenme bitti) ve bildirim iptal edilir (Review Focus 1).
  - **Bildirim çağrıları** (sahte platform): `showRest` + `scheduleRestEnd` doğru zamanlarla. `skip` → `cancelRest`.
  - **Bildirim eylemleri:** "+15 sn" eylemi uygulama arka plandayken de bitiş alarmını yeniden zamanlar.
  - **Ekran:**
    - "1:12" ve "KALAN · 1:30" yazar. Semantics "kalan 1 dakika 12 saniye".
    - "–15 sn" / "+15 sn" / "Atla" çalışır.
    - "Son seti düzenle" sayacı durdurup son seti açar.
    - Sıradaki set ya da hareket satırı `nextUp()`'tan gelir. Motivasyon satırının yeri boş durur (2b).
  - **Hareketi azalt:** `disableAnimations` → halka akmaz, saniyede bir güncellenir.
  - **Süre hafızası:** "+15 sn" ile değişen süre o hareket için kaydedilir; sonraki dinlenme o süreyle başlar.
- [ ] **Step 2:** FAIL. **Step 3:** Uygula. **Step 4:** PASS + `flutter build apk --debug --dart-define-from-file=env.json`.
- [ ] **Step 5: Commit** `feat(training): dinlenme sayacı ve kilit ekranı bildirimi`

### Task 10: Bitiş, özet ve yarım antrenman

**Files:**
- Create `lib/ui/training/workout_summary_screen.dart`
- Modify `lib/ui/training/training_screen.dart`, `lib/ui/router.dart` (açılışta aktif antrenman), profil bilgi ekranı (atıf)
- Test `test/ui/training/workout_summary_test.dart`, `test/ui/training/resume_test.dart`

**Interfaces:**
- Consumes: `finish()`, `discard()`, `WorkoutQueries`, `BodyMap`, `summarizeWorkout`.

- [ ] **Step 1: Testler**
  - **Bitir (setli):**
    - Özet açılır: süre, set sayısı, hacim (kullanıcının biriminde), kalori ve "Bu antrenman" maketi.
    - Maket yalnızca bu oturumun yoğunluğunu gösterir; ölçek `sessionIntensity` değil Global Constraints kademeleri.
  - **Bitir (setsiz):** "Hiç set yok, antrenman kaydedilmedi." mesajı görünür, sekmeye dönülür, oturum silinir (Review Focus 4).
  - **Yarım antrenman:**
    - Uygulama yeniden başlar (sağlayıcı yeniden kurulur), aktif oturum varsa sekmede "Devam et" görünür. Basınca odak modu kaldığı hareket ve setle açılır.
    - 24 saatten eski aktif oturumda "Bitir mi, sil mi?" diyalogu çıkar.
  - **Atıf:** Profil > bilgi ekranında "3B model: MakeHuman / MPFB (CC0)" satırı.
- [ ] **Step 2:** FAIL. **Step 3:** Uygula. **Step 4:** `flutter analyze && flutter test` PASS.
- [ ] **Step 5: Commit** `feat(training): antrenman özeti ve yarım kalanı sürdürme`

### Task 11: Cihazda deneme (kullanıcıyla)

- [ ] **Step 1:** APK'yı Nothing Phone 2a'ya kur. Spec'teki başarı ölçütünü birlikte yürüt:
  - Klavye açılmıyor.
  - Sıra değiştirme, hareket ekleme ve set düzeltme çalışıyor.
  - Kilitliyken sayaç akıyor ve bitişte titriyor.
  - Uygulama kapatılıp açılınca antrenman devam ediyor.
  - Maket iki temada doğru görünüyor ve shader cihazda çalışıyor.
- [ ] **Step 2:** Tek bağımsız genel inceleme; bulgular düzeltilir.
- [ ] **Step 3:** `DEVAM.md` güncellenir (2a bitti, sırada 2b). Notlar dosyasına yazılır: `USE_EXACT_ALARM` Play Store öncesi yeniden düşünülecek. Commit + push.
