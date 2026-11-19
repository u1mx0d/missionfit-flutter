# Giriş ekranları ve sporcu kartı — Uygulama planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Nokta-matris logolu yeni "Hoş geldin" açılışı, sporcu kartlı giriş/kayıt/kod ekranları ve telefonda kayıtlı hesap kartları.

**Architecture:** Logo ve kart `lib/ui/components` altında kendi çizdiğimiz bileşenler (CustomPainter, tema renkleri). Kayıtlı kartlar `lib/app/known_accounts.dart` içinde SharedPreferences'ta JSON listesi; bir eşitleme sağlayıcısı oturum açıkken profil değiştikçe kartı günceller. Yönlendirici oturum yokken yarım kayıt → `/dogrula`, kayıtlı kart → `/giris`, yoksa `/hosgeldin` seçer.

**Tech Stack:** Flutter 3.50 / Dart 3.14, Riverpod 3, go_router, shared_preferences, drift (yalnızca okuma). Yeni paket yok.

**Spec:** `docs/superpowers/specs/2026-11-19-giris-ekrani-design.md`

## Global Constraints

- Sunucu değişikliği yok; e-postadan kullanıcı adı/fotoğraf sorgulanmaz.
- Kart metinleri (aynen): "SPORCU KİMLİĞİ", "KOD BEKLENİYOR", "AKTİF", "Tekrar hoş geldin", "MissionFit sporcusu", "Üye: <Ay> <Yıl>" (ör. "Üye: Kasım 2026").
- Hoş geldin metinleri (aynen): "MISSIONFIT", "Her gün bir görev. Her set bir adım.", "Google ile devam et", "E-posta ile kayıt ol", "Hesabın var mı? Giriş yap".
- Kayıt düğmesi: "Kartımı oluştur". Giriş düğmesi: "Giriş yap". Kod düğmesi: "Doğrula".
- `known_accounts` en çok 5 kayıt, en son giriş en üstte; e-posta eşleşmesi kırpılmış ve küçük harf.
- Açılış animasyonu: noktalar ~900 ms, orta nokta ~150 ms, yazı/düğmeler ~250 ms; `MediaQuery.disableAnimations` açıkken animasyon yok.
- "AKTİF" sonrası yönlendirme ~700 ms bekletilir (`authHoldProvider`).
- Dokunma alanı ≥ 48 dp; metin kontrastı ≥ 4.5:1, ikon/damga ≥ 3:1 (Canlı ve Mono, açık ve koyu).
- Mevcut `auth_rules.dart` hata metinleri ve doğrulama kuralları değişmez.

## Review Focus

1. Yarım kayıt + kayıtlı kart birlikte varken açılış: yarım kayıt kazanır (`/dogrula`).
2. Kullanıcı `/hosgeldin` ↔ `/giris` ↔ `/kayit` arasında gezinirken yönlendirici araya girmez (yalnızca kimlik dışı yoldan gelirken seçer).
3. Kod doğrulama başarısızsa `authHold` bırakılır; aksi halde kullanıcı kod ekranında kilitli kalır.
4. Hesap silinince kart telefondan gider; çıkış yapınca kalır.
5. Onboarding'i bitmemiş hesap için kart yazılmaz (yarıda çıkış → kart yok).

Her biri ilgili görevde testle bağlanmıştır (Görev 3, 4, 5, 8).

---

## Dosya haritası

- Create `lib/domain/member_since.dart` — `formatMemberSince(DateTime) -> String`.
- Create `lib/ui/components/mf_logo.dart` — `mLogoCells`, `MfLogo`.
- Create `lib/ui/components/athlete_card.dart` — `AthleteCardMode`, `AthleteCardData`, `AthleteCard`.
- Create `lib/app/known_accounts.dart` — `KnownAccount`, `knownAccountsProvider`, `knownAccountSyncProvider`.
- Create `lib/ui/auth/welcome_screen.dart` — `/hosgeldin`.
- Modify `lib/ui/router.dart`, `lib/ui/auth/{auth_scaffold,login_screen,register_screen,verify_code_screen,forgot_password_screen}.dart`, `lib/ui/components/mf_text_field.dart`, `lib/ui/onboarding/identity_step.dart`, `lib/ui/profile/delete_account_screen.dart`, `lib/main.dart`, `android/app/src/main/res/values*/` (splash rengi).

---

### Task 1: Logo ve üyelik tarihi

**Files:**
- Create: `lib/domain/member_since.dart`, `lib/ui/components/mf_logo.dart`
- Test: `test/domain/member_since_test.dart`, `test/ui/components/mf_logo_test.dart`

**Interfaces:**
- Produces: `String formatMemberSince(DateTime d)`; `const List<(int col, int row)> mLogoCells` (12 M noktası, orta nokta hariç); `MfLogo({double size = 128, double progress = 1})` — `progress` 0..1 animasyon ilerlemesi (1 = son hali; Görev 6 kullanır).

- [ ] **Step 1: Testler:** `formatMemberSince(DateTime(2026, 11, 2)) == 'Üye: Kasım 2026'`, `DateTime(2027, 1, 31)` → `'Üye: Ocak 2027'`; `mLogoCells.toSet() == {(0,0),(0,1),(0,2),(0,3),(0,4),(1,1),(3,1),(4,0),(4,1),(4,2),(4,3),(4,4)}`; `MfLogo` widget testi: `find.bySemanticsLabel('MissionFit')` bulunur, `progress: 0` ve `1` hatasız çizilir.
- [ ] **Step 2:** `flutter test test/domain/member_since_test.dart test/ui/components/mf_logo_test.dart` → FAIL.
- [ ] **Step 3:** Uygula. Ay adları Türkçe sabit liste. `MfLogo` bir `CustomPaint` + `Semantics(label: 'MissionFit')`; 5×5 ızgara, M noktaları `mf(context).text`, orta nokta `(2,2)` `mf(context).accent`, kalan 12 hücre `text` %8 opaklık. `progress < 1` iken M noktaları önceden belirli (tohumlu `Random(7)`) ızgara konumlarından hedefe `Curves.easeOutCubic` ile ilerler; orta nokta `progress >= 0.85` sonrası belirir.
- [ ] **Step 4:** Testler + `flutter analyze` PASS.
- [ ] **Step 5: Commit** `feat(ui): nokta-matris logo ve üyelik tarihi`

### Task 2: Sporcu kartı

**Files:**
- Create: `lib/ui/components/athlete_card.dart`
- Test: `test/ui/components/athlete_card_test.dart`

**Interfaces:**
- Consumes: `MfLogo`, `formatMemberSince`, `MfAvatar`.
- Produces: `enum AthleteCardMode { empty, filling, awaitingCode, active, saved, sample }`; `class AthleteCardData { String? displayName, username, email, avatarUrl; Uint8List? avatarBytes; DateTime? memberSince; bool passwordOk }` (const ctor, hepsi isteğe bağlı, `passwordOk` varsayılan false); `AthleteCard({required AthleteCardMode mode, AthleteCardData data = const AthleteCardData(), VoidCallback? onAvatarTap, VoidCallback? onRemove})`.

- [ ] **Step 1: Testler** (Canlı ve Mono, açık ve koyu döngüsünde her biri hatasız çizilir):
  - Her modda "SPORCU KİMLİĞİ" görünür.
  - `empty`: "····" yer tutucu, damga yok.
  - `filling` + `email: 'a@b.com', passwordOk: true`: 'a@b.com' ve "✓ Şifre".
  - `awaitingCode`: "KOD BEKLENİYOR". `active`: "AKTİF".
  - `saved` + `displayName: 'Alperen', username: 'alperen', memberSince: DateTime(2026,11,2)`: 'Alperen', '@alperen', 'Üye: Kasım 2026'; ad yoksa başlık '@alperen', o da yoksa e-posta.
  - `sample`: "MissionFit sporcusu".
  - `onRemove` verilirse `Key('athlete-card-remove')` düğmesi var ve çağırır; verilmezse yok.
  - `onAvatarTap` verilirse avatar dokunulabilir (`Key('athlete-card-avatar')`).
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** Uygula. Zemin: `t.cardStyle == CardStyle.flat` (Mono) ise `t.surface` + ince kenarlık, değilse `t.gradientTop`'tan `t.surface`'e degrade; ikisinde de soluk nokta dokusu (mevcut `dot_grid.dart` deseni). Damga `AnimatedScale` + hafif dönüş (~300 ms) ile girer. Alan değişimleri `AnimatedSwitcher` (~200 ms). Kart kendi animasyonunu `MediaQuery.disableAnimations` ile kapatır.
- [ ] **Step 4:** PASS + analyze.
- [ ] **Step 5: Commit** `feat(ui): sporcu kartı`

### Task 3: Telefonda kayıtlı kartlar

**Files:**
- Create: `lib/app/known_accounts.dart`
- Modify: `lib/main.dart` (kök `build` içinde `ref.watch(knownAccountSyncProvider)`), `lib/ui/profile/delete_account_screen.dart` (silme başarılı olunca `remove(userId)`, `signOut`'tan önce)
- Test: `test/app/known_accounts_test.dart`, `test/ui/profile/profile_screens_test.dart`

**Interfaces:**
- Produces: `class KnownAccount { String userId, email; String? displayName, username, avatarUrl; DateTime? memberSince; DateTime lastSignedInAt; Map<String,Object?> toJson(); factory fromJson(Map) }`; `const knownAccountsKey = 'known_accounts'`; `knownAccountsProvider = NotifierProvider<KnownAccounts, List<KnownAccount>>` ile `Future<void> upsert(KnownAccount a)`, `Future<void> remove(String userId)`, `KnownAccount? match(String email)`; `knownAccountSyncProvider = Provider<void>` (yalnızca dinler).

- [ ] **Step 1: Testler:**
  - `upsert` aynı `userId`'yi günceller ve en üste taşır; 6. kayıtta en eskisi düşer (uzunluk 5).
  - `match('  A@B.com ')` → `email: 'a@b.com'` kaydını bulur; eşleşme yoksa null.
  - Bozuk JSON → boş liste (çökmez).
  - `remove` kaydı siler ve kalıcıdır (yeni container aynı prefs ile okur).
  - Eşitleme: onboarded + profil (`displayName 'Ali'`, `username 'ali'`, `avatarPath 'u1/1.jpg'`, `createdAt '2026-11-02T10:00:00Z'`) + e-posta `a@b.com` → kayıt `avatarUrl == repo.publicUrl('u1/1.jpg')`, `memberSince == DateTime.utc(2026,11,2,10)`; ad değişince kayıt güncellenir.
  - Eşitleme: `onboarded == false` → kayıt yazılmaz (Review Focus 5).
  - `createdAt: 'x'` (çözülemez) → `memberSince == null`.
  - Hesabı sil başarılı akışı → kart silinir; çıkış yap → kart kalır (Review Focus 4; `profile_screens_test.dart`).
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** Uygula. Eşitleme `ref.listen` ile `profileProvider`, `onboardedProvider`, `currentUserEmailProvider` değişince çalışır; `lastSignedInAt = DateTime.now()` yalnızca kayıt ilk yazılırken ya da kullanıcı değişince. Fotoğraf URL'si `profileIdentityRepositoryProvider.publicUrl`.
- [ ] **Step 4:** `flutter analyze && flutter test` PASS.
- [ ] **Step 5: Commit** `feat(auth): telefonda kayıtlı sporcu kartları`

### Task 4: Yönlendirme ve `/hosgeldin` rotası

**Files:**
- Modify: `lib/ui/router.dart`
- Test: `test/ui/router_test.dart`

**Interfaces:**
- Consumes: `pendingSignupEmailProvider`, `knownAccountsProvider`.
- Produces: `authRoutes` artık `'/hosgeldin'` içerir; `redirectFor(..., String? pendingSignupEmail, bool hasKnownAccount = false)`; rota `'/hosgeldin'` → `const WelcomeScreen()`. Bu görev `lib/ui/auth/welcome_screen.dart` içinde yalnızca "MISSIONFIT" yazan bir iskelet oluşturur; Görev 5 doldurur.

- [ ] **Step 1: Testler** (`redirectFor` saf testleri):
  - Oturum yok, konum `/bugun`, yarım kayıt `a@b.com`, kayıtlı kart var → `'/dogrula?email=a%40b.com'` (Review Focus 1).
  - Oturum yok, `/bugun`, yalnızca kayıtlı kart → `'/giris'`; hiçbiri → `'/hosgeldin'`.
  - Oturum yok, konum `/giris` ya da `/kayit` ya da `/hosgeldin`, yarım kayıt var → `null` (Review Focus 2).
  - Oturum var, onboarded, konum `/hosgeldin` → `'/bugun'`.
  - Mevcut router testlerinde `'/giris'` bekleyenler: kayıtlı kart yokken artık `'/hosgeldin'`.
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** Uygula; `routerProvider` iki sağlayıcıyı `ref.listen` ile dinleyip `refresh.poke()` yapar ve `redirect` içinde okur.
- [ ] **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(auth): oturum yokken hoş geldin / giriş / kod seçimi`

### Task 5: Hoş geldin ekranı

**Files:**
- Create/Fill: `lib/ui/auth/welcome_screen.dart`
- Test: `test/ui/auth/auth_screens_test.dart`

**Interfaces:**
- Consumes: `MfLogo(progress:)`, `GoogleButton`, `authRepositoryProvider.signInWithGoogle`, `envProvider.googleSignInEnabled`.
- Produces: `WelcomeScreen` (`ConsumerStatefulWidget`); `welcomeIntroPlayedProvider = NotifierProvider<WelcomeIntroPlayed, bool>` (uygulama açılışı başına bir kez true olur).

- [ ] **Step 1: Testler:** Sabit metinler görünür (Global Constraints); "E-posta ile kayıt ol" → `/kayit`; "Hesabın var mı? Giriş yap" → `/giris`; Google kapalıyken Google düğmesi yok, açıkken `signInWithGoogle` çağrılır; `MediaQueryData(disableAnimations: true)` ile ilk `pump()` sonrası düğmeler hemen görünür ve `MfLogo.progress == 1`; ekrana ikinci kez gelince animasyon tekrar oynamaz (`progress == 1` ilk karede).
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** Uygula: zemin `MfBackground`; tek `AnimationController` (toplam ~1300 ms: 0–900 noktalar, 900–1050 orta nokta, 1050–1300 yazı/düğmeler `FadeTransition`); `dispose` edilir.
- [ ] **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(auth): nokta-matris hoş geldin ekranı`

### Task 6: Yeni kimlik iskeleti ve giriş ekranı

**Files:**
- Modify: `lib/ui/auth/auth_scaffold.dart`, `lib/ui/auth/login_screen.dart`, `lib/ui/auth/forgot_password_screen.dart`, `lib/ui/components/mf_text_field.dart`
- Test: `test/ui/auth/auth_screens_test.dart`

**Interfaces:**
- Consumes: `AthleteCard`, `knownAccountsProvider.match/remove`, `MfLogo`.
- Produces: `AuthScaffold({required String title, String? subtitle, Widget? header, bool showBack = false, required List<Widget> children})` — `header` (kart) başlığın üstünde; `header` yoksa küçük `MfLogo(size: 40)`; geri oku `/hosgeldin`'e gider. `MfTextField` ve `PasswordField` yeni `Iterable<String>? autofillHints` parametresi.

- [ ] **Step 1: Testler:**
  - Kayıtlı kart (`a@b.com`, 'Alperen') varken `/giris`: e-posta alanı 'a@b.com' dolu, kart `saved` modunda 'Alperen' ve üstte "Tekrar hoş geldin".
  - E-posta 'x@y.com' yazılınca kart `sample` ("MissionFit sporcusu"); tekrar 'A@B.com' yazılınca 'Alperen' döner.
  - Kartın kaldır düğmesi → kayıt silinir, kart `sample` olur, e-posta alanı korunur.
  - Kayıtlı kart yokken `sample` ve e-posta boş.
  - "Kaydını tamamla" kartı yarım kayıt varken hâlâ görünür (mevcut test korunur).
  - E-posta alanı `AutofillHints.email`, şifre `AutofillHints.password`; `AutofillGroup` içinde.
  - Şifremi unuttum ekranında kart yok, `MfLogo` var; mevcut iki aşamalı akış testleri geçer.
  - Tüm temalarda giriş ekranı çizilir (mevcut döngülü test).
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** Uygula.
- [ ] **Step 4:** `flutter test test/ui/auth` PASS.
- [ ] **Step 5: Commit** `feat(auth): kartlı giriş ekranı ve yeni kimlik iskeleti`

### Task 7: Kayıt ve kod ekranları

**Files:**
- Modify: `lib/ui/auth/register_screen.dart`, `lib/ui/auth/verify_code_screen.dart`
- Test: `test/ui/auth/auth_screens_test.dart`

**Interfaces:**
- Consumes: `AthleteCard`, `authHoldProvider`, `validateSignUp` (mevcut), `pendingSignupEmailProvider`.
- Produces: `const activeStampHold = Duration(milliseconds: 700)` (verify_code_screen.dart; testler kısaltabilsin diye `activeStampHoldProvider = Provider<Duration>`).

- [ ] **Step 1: Testler:**
  - `/kayit` açılışta kart `empty`; geçerli e-posta yazılınca kartta e-posta (`filling`); kurallara uyan şifre + tekrar → "✓ Şifre"; düğme "Kartımı oluştur" → `signUp` çağrılır, `/dogrula`'ya gidilir (mevcut test uyarlanır).
  - `/dogrula`: kart "KOD BEKLENİYOR" ve e-posta.
  - Doğrulama başarılı: "AKTİF" görünür; `authHoldProvider` doğrulama sürerken ve bekleme boyunca true, bekleme sonunda false; yarım kayıt silinir.
  - Doğrulama başarısız: hata metni, `authHoldProvider` false (Review Focus 3).
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** Uygula: `_submit` başında `authHold.set(true)`; başarıda `setState(active)`, `await Future.delayed(hold)`, `finally` içinde `authHold.set(false)`.
- [ ] **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(auth): kart dolan kayıt ve AKTİF damgalı kod ekranı`

### Task 8: Onboarding "Profilin" adımında kart

**Files:**
- Modify: `lib/ui/onboarding/identity_step.dart`
- Test: `test/ui/onboarding/onboarding_flow_test.dart`

**Interfaces:**
- Consumes: `AthleteCard(mode: AthleteCardMode.active, data:, onAvatarTap:)`, `currentUserEmailProvider`.

- [ ] **Step 1: Testler:** "Profilin" adımında `AthleteCard` var; ad 'Ali Kaya' yazılınca kartta 'Ali Kaya'; kullanıcı adı önerisi kartta '@sporcu'; `Key('athlete-card-avatar')`'a dokunmak kaynak sayfasını açar ("Galeriden seç"); mevcut fotoğraf testleri `Key('identity-avatar')` yerine bu anahtarla geçer; Google fotoğrafı kartta `Key('avatar-url')`.
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** Uygula (mevcut avatar sütunu kaldırılır, "Fotoğraf ekle/değiştir" metin düğmesi kartın altında kalır).
- [ ] **Step 4:** `flutter analyze && flutter test` PASS.
- [ ] **Step 5: Commit** `feat(onboarding): Profilin adımında sporcu kartı`

### Task 9: Açılış rengi, cihaz kontrolü, inceleme

- [ ] **Step 1:** `android/app/src/main/res/values/colors.xml` ve `values-night` açılış zemini uygulama zemini ile eşlenir (açık: Canlı açık zemin, koyu `#0B0F0C`); `flutter build apk --debug --dart-define-from-file=env.json` derlenir.
- [ ] **Step 2:** Telefona ve emülatöre kur; kullanıcıyla kontrol: ilk açılış animasyonu, kayıt → kod → AKTİF → onboarding kartı, çıkış → giriş kartı "Tekrar hoş geldin", başka e-posta → örnek kart, animasyon azaltma ayarı, Mono/Canlı açık/koyu.
- [ ] **Step 3:** Tek bağımsız inceleme (en yetenekli model), bulgular düzeltilir.
- [ ] **Step 4:** `DEVAM.md` güncellenir; commit + push.
