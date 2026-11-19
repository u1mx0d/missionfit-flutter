# Antrenman tarzı, seviye ve hedefler — Uygulama planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Onboarding'de ana/yan tarz, seviye ve (atlanabilir) hedef hareketler + geliştirilecek alanlar; Profil'den düzenleme; çevrimdışı senkron.

**Architecture:** Beş yeni `profiles` sütunu sunucuda (ekleme, check kısıtları, `grant update`) ve yerel drift aynasında; mevcut outbox yolundan gider. Seçim kuralları saf Dart (`lib/domain/training_style.dart`). Onboarding'e iki adım, Profil'e bir ekran.

**Tech Stack:** Flutter 3.50 / Dart 3.14, Riverpod 3, go_router, drift; Supabase Postgres + pgTAP (`~/projelerim/saglik-app`).

**Spec:** `docs/superpowers/specs/2026-11-19-antrenman-tarzi-design.md`

## Global Constraints

- Sunucu yalnızca ekleme; RN istemcisi bozulmaz (`npm test` 299/299).
- Değerler (aynen): tarz `calisthenics|bodybuilding|functional|strength|conditioning|general`; seviye `beginner|intermediate|advanced`; alan `push|pull|legs|core|mobility|conditioning`; hedef anahtarları ve Türkçe etiketleri spec'teki "Hedef hareket listesi" bölümündeki gibi.
- `side_styles` ana tarzı içeremez, tekrar yok. Tarz ve seviye zorunlu; hedefler/alanlar atlanabilir (boş liste).
- Onboarding sırası: Rıza → Profilin → Tarzın → Hedeflerin → Doğum → Vücut → Hareket ve hedef → Kalori → Bildirim → Tema (10 adım).
- Yeni alanlar `Profile.toPayload()` içinde **gönderilir**.
- Dokunma ≥ 48 dp; seçili durum yalnızca renkle değil, rozet/işaretle de belli olur; ikon, emoji değil.

## Review Focus

1. Ana tarzı kaldırınca ilk yan tarz ana olur; son tarz da kaldırılırsa ana boş kalır ve Devam hata verir.
2. Yan tarz değişince hedef listesi değişir ama önceden seçilmiş, artık listede olmayan hedefler kaybolmaz (kaydedilir, listede en sonda gösterilir).
3. Eski hesap (tarz boş) Profil'de "Profilini tamamla" görür ve tarz ekranına gidebilir.
4. Çevrimdışı Profil'den tarz değiştirme kaydedilir (outbox), çevrimiçi olunca gönderilir.
5. Geri dönülüp tekrar gelinince Tarzın/Hedeflerin seçimleri korunur.

---

## Dosya haritası

- saglik-app: Create `supabase/migrations/20261120120000_training_style.sql`, `supabase/tests/training_style.test.sql`.
- Create `lib/domain/training_style.dart`, `lib/ui/training/training_style_picker.dart` (iki bölümün ortak widget'ları), `lib/ui/onboarding/style_step.dart`, `lib/ui/onboarding/goals_step.dart`, `lib/ui/profile/training_style_screen.dart`.
- Modify `lib/data/db/database.dart` (+tablo), `lib/data/profile/profile_repository.dart`, `lib/app/onboarding_controller.dart`, `lib/ui/onboarding/{onboarding_flow,onboarding_draft}.dart`, `lib/ui/profile/{profile_screen,profile_routes,profile_header}.dart`.

---

### Task 1: Sunucu sütunları (saglik-app)

**Files:** Create migration + pgTAP testi (yukarıda).

- [ ] **Step 1: pgTAP testi** (`profile_identity.test.sql` kalıbı, A ve B kullanıcıları): A kendi satırına beş alanı yazar (`update ... set training_style='calisthenics', side_styles='{functional}', training_level='intermediate', goal_moves='{muscle_up}', focus_areas='{push}'`) → lives_ok; `training_style='yoga'` → 23514; `training_level='pro'` → 23514; `side_styles='{calisthenics}'` iken `training_style='calisthenics'` → 23514; `side_styles='{functional,functional}'` → 23514; `focus_areas='{arms}'` → 23514; `goal_moves='{fly}'` → 23514; A, B'nin satırını güncelleyemez (0 satır).
- [ ] **Step 2:** `npm run db:test` → FAIL.
- [ ] **Step 3:** Migration: beş nullable sütun; check kısıtları (`<@ array[...]`, `cardinality(x) = cardinality(array(select distinct unnest(x)))`, `not (training_style = any(side_styles))`); `grant update (training_style, side_styles, training_level, goal_moves, focus_areas) on public.profiles to authenticated`.
- [ ] **Step 4:** `npm run db:reset && npm run db:test && npm run db:advisors && npm test` → hepsi PASS / uyarı yok / 299.
- [ ] **Step 5: Commit** (saglik-app, yerel; uzak push ve `db push` Görev 6'da kullanıcı onayıyla) `feat(db): antrenman tarzı, seviye ve hedef sütunları`

### Task 2: Alan kuralları (saf Dart)

**Files:** Create `lib/domain/training_style.dart`; Test `test/domain/training_style_test.dart`

**Interfaces:**
- Produces: `enum TrainingStyle {calisthenics, bodybuilding, functional, strength, conditioning, general}`, `enum TrainingLevel {beginner, intermediate, advanced}`, `enum FocusArea {push, pull, legs, core, mobility, conditioning}`; `const Map<TrainingStyle, List<String>> goalMovesByStyle`; `const Map<String, String> goalMoveLabels` (anahtar → Türkçe); `class StyleSelection { final TrainingStyle? main; final List<TrainingStyle> sides; StyleSelection tap(TrainingStyle s); StyleSelection makeMain(TrainingStyle s); }`; `List<String> goalOptionsFor(StyleSelection s, {Iterable<String> keep = const []})`; `String? validateStyle(StyleSelection s, TrainingLevel? level)` → "Ana tarzını seç." / "Seviyeni seç." / null; enum ↔ sunucu dizgisi için `.name` kullanılır.

- [ ] **Step 1: Testler:** boştan `tap(calisthenics)` → main; sonra `tap(functional)` → sides `[functional]`; `tap(calisthenics)` (ana) → main `functional`, sides `[]` (Review Focus 1); `tap(functional)` tekrar → main null; `makeMain(functional)` (yan) → main functional, eski ana sides başına; seçili olmayana `makeMain` → değişmez. `goalOptionsFor(main: calisthenics, sides: [functional])` → önce calisthenics listesi sonra functional'ın calisthenics'te olmayanları (`first_pullup` bir kez); `keep: ['bench_up']` → sonda `bench_up` (Review Focus 2). `validateStyle` üç durum. Her `goalMovesByStyle` anahtarının `goalMoveLabels`'ta etiketi var.
- [ ] **Step 2:** FAIL. **Step 3:** Uygula. **Step 4:** PASS + analyze.
- [ ] **Step 5: Commit** `feat(domain): antrenman tarzı kuralları`

### Task 3: Yerel şema v3 ve `Profile` alanları

**Files:** Modify `lib/data/db/database.dart`, `lib/data/profile/profile_repository.dart`; Test `test/data/db/*`, `test/data/profile/*`

**Interfaces:**
- Consumes: Görev 2 enum'ları.
- Produces: `Profile` yeni alanlar `TrainingStyle? trainingStyle`, `List<TrainingStyle> sideStyles`, `TrainingLevel? trainingLevel`, `List<String> goalMoves`, `List<FocusArea> focusAreas` (listeler varsayılan `const []`); `copyWith`'e eklenir; `toRow/toPayload` sunucu adlarıyla (`training_style`, `side_styles`…) listeleri Dart `List<String>` olarak verir; drift'te listeler JSON metin sütunu (`notification_settings` gibi), `fromServer` hem `List` hem JSON metni kabul eder; bilinmeyen değerler sessizce atılır.

- [ ] **Step 1: Testler:** v2 → v3 göçünde mevcut satır korunur, yeni sütunlar null; `fromServer({'training_style':'calisthenics','side_styles':['functional','yoga'], ...})` → sides `[functional]`; `toPayload()` beş alanı içerir, `username`/`avatar_path` hâlâ içermez; `copyWith(trainingStyle: ...)` sonrası `ProfileRepository.update` outbox'a tek kayıt yazar.
- [ ] **Step 2:** FAIL. **Step 3:** `schemaVersion => 3`, `if (from < 3) addColumn ×5`; `dart run build_runner build -d`. **Step 4:** `flutter analyze && flutter test` PASS.
- [ ] **Step 5: Commit** `feat(db): yerel profil şeması v3 (antrenman tarzı)`

### Task 4: Onboarding "Tarzın" ve "Hedeflerin"

**Files:** Create `lib/ui/training/training_style_picker.dart` (`StyleGrid`, `LevelSelector`, `GoalChips`), `lib/ui/onboarding/style_step.dart`, `lib/ui/onboarding/goals_step.dart`; Modify `onboarding_flow.dart`, `onboarding_draft.dart`, `lib/app/onboarding_controller.dart`; Test `test/ui/onboarding/onboarding_flow_test.dart`

**Interfaces:**
- Consumes: `StyleSelection`, `goalOptionsFor`, `validateStyle`, `Profile.copyWith`.
- Produces: `StyleGrid({required StyleSelection value, required ValueChanged<StyleSelection> onChanged})` (kart anahtarları `Key('style-<name>')`, ana rozet metni "ANA"); `LevelSelector({TrainingLevel? value, onChanged})` (`Key('level-<name>')`, etiketler "Yeni", "Orta", "İleri"); `GoalChips({required List<String> options, required Set<String> goals, required Set<FocusArea> areas, onGoals, onAreas})` (`Key('goal-<key>')`, `Key('area-<name>')`); `OnboardingData` yeni alanları aynı tek profil güncellemesine girer.

- [ ] **Step 1: Testler:**
  - Adım sayacı 10; "Profilin"den sonra "Nasıl antrenman yapıyorsun?" başlığı.
  - Tarz/seviye seçmeden Devam → "Ana tarzını seç." ve ilerlemez; yalnızca tarzla → "Seviyeni seç.".
  - `style-calisthenics`, `style-functional`, `level-intermediate` → Devam → "Neye ulaşmak istiyorsun?"; `goal-muscle_up`, `area-push` → Devam → "Doğum tarihin".
  - "Şimdilik atla" → hedef/alan boş, "Doğum tarihin".
  - Geri dönüp gelince seçimler korunur (Review Focus 5).
  - `style-calisthenics` uzun basma yok sayılır (zaten ana); `style-functional`'a uzun basma → onda "ANA".
  - Bitişte profil satırı: `training_style 'calisthenics'`, `side_styles ['functional']`, `training_level 'intermediate'`, `goal_moves ['muscle_up']`, `focus_areas ['push']`; outbox'ta hâlâ tek kayıt.
  - Mevcut tüm onboarding testleri yeni adımlar için yardımcı (`_style(t)`, `_goals(t)`) ile güncellenir.
- [ ] **Step 2:** FAIL. **Step 3:** Uygula (taslak: `.superpowers/brainstorm/227680-1795075968/content/tarz-adimi.html`; ikonlar Material Symbols). **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(onboarding): Tarzın ve Hedeflerin adımları`

### Task 5: Profil'den düzenleme

**Files:** Create `lib/ui/profile/training_style_screen.dart`; Modify `profile_screen.dart` ("Vücut ve hedef" bölümüne `SettingsRow(title: 'Antrenman tarzım')`, alt yazı ana tarz + seviye ya da "Seçilmedi"), `profile_routes.dart` (`'tarz'`), `profile_header.dart` (eksiklik koşuluna `trainingStyle == null` eklenir; "Profilini tamamla" ad/kullanıcı adı tamamsa `/profil/tarz`'a gider); Test `test/ui/profile/profile_screens_test.dart`, `profile_identity_test.dart`

**Interfaces:** Consumes Görev 4 widget'ları ve `saveProfile(context, ref, (p) => p.copyWith(...))`.

- [ ] **Step 1: Testler:** satır alt yazısı "Calisthenics · Orta"; ekranda mevcut seçimler dolu; değiştir + Kaydet → satır güncellenir, outbox'ta kayıt (Review Focus 4: test bağlantı durumundan bağımsız, outbox'a yazıldığını doğrular); tarz boş profilde başlıkta "Profilini tamamla" → `/profil/tarz` (Review Focus 3); geçersiz (tarz yok) Kaydet → "Ana tarzını seç.".
- [ ] **Step 2:** FAIL. **Step 3:** Uygula. **Step 4:** `flutter analyze && flutter test` PASS.
- [ ] **Step 5: Commit** `feat(profile): antrenman tarzını düzenleme`

### Task 6: Uzak sunucu ve cihaz (kullanıcıyla)

- [ ] **Step 1:** Migration özetini kullanıcıya göster, onay al → `npx supabase db push --remote --yes`; `npx supabase migration list --remote` ile doğrula; saglik-app push.
- [ ] **Step 2:** APK'yı telefona kur; kontrol: yeni hesapla 10 adımlı onboarding, atla, Profil'den değiştirme, çevrimdışı değiştirme sonra senkron, eski hesapta "Profilini tamamla".
- [ ] **Step 3:** Tek bağımsız inceleme (iki depo); bulgular düzeltilir; `DEVAM.md` güncellenir, commit + push.
