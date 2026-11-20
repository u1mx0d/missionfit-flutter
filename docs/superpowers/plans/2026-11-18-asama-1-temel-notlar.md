# Aşama 1 yürütme notları (ledger)

Görev ilerlemesi, verilen kararlar (Ruling) ve sonraya bırakılan küçük bulgular (minor deferred). Kaynak: SDD ledger, 2026-11-18.

```
# SDD ledger — plan: docs/superpowers/plans/2026-11-18-asama-1-temel.md
Spec: docs/superpowers/specs/2026-11-18-asama-1-temel-design.md
Executor: hybrid — Tasks 1-4, 9, 12-16 inline; 5-8, 10-11 subagent-driven; 17 with user.
Ruling: work on main and push per task, no worktree — user asked for step-by-step pushes to GitHub (public repo, solo dev) — cost if wrong: messy main history, revertible.
Pre-flight:
- T2→T3/T4: domain types (LocalDate, WeekStartsOn, WeightUnit) consumed — consistent.
- T6→T7/T8/T10: AppDatabase, outboxOps, clearAllUserData — consistent.
- T7→T8: OutboxRepository/OutboxOp — consistent.
- T9→T11: ThemeFamily/AccentColor/familyFromString/accentFromString — consistent.
- T10→T11/T12/T13/T16: AuthRepository, authStateProvider — consistent.
- T14→T15/T16: NotificationService (reordered before onboarding in plan fix) — consistent.
- T5→T8: deletions table, updated_at columns — consistent.
Task 1: Ruling: lib importları package:material_ui kullanır — Flutter 3.50'de package:flutter/material.dart deprecated (analyze info) — yanlışsa import değişikliği ucuz.
Task 1: Ruling: dart format --line-length 100 — 80 karakter Türkçe metinlerde gereksiz satır kırar — yanlışsa tek komutla yeniden biçimlenir.
Task 1: complete (commits 4d19385..ef9a2ce, tests: ./tool/check.sh → check: tamam)
Task 2: Ruling: format testleri (3) workout.test.ts'ten format_test.dart'a alındı; units.test.ts'teki 2 calorieTargetForProfile testi Task 3'e (calories) kaydı — test dosyası modüle göre — yanlışsa yalnızca dosya yeri.
Task 2: Ruling: isValidDate NaN durumu atlandı — Dart int NaN olamaz, tip sistemi engelliyor — maliyet yok.
Task 2: Ruling: WeekWindow alanları TS'teki gibi weekKey/start/end/days (plan 'key' demişti); isInWindow DateRange arayüzü alır; jsRound yardımcısı JS Math.round eşdeğeri — RN ile birebir sonuç — yanlışsa küçük yeniden adlandırma.
Task 2: complete (commits ef9a2ce..a4247e5, tests: ./tool/check.sh → check: tamam)
Task 3: Ruling: suggestTemplate son eşitlik kırıcısı localeCompare('tr') yerine String.compareTo — Dart'ta intl olmadan Türkçe sıralama yok, yalnızca puan/kapsam/set tam eşitse devreye girer — yanlışsa nadir durumda farklı şablon önerilir.
Task 3: Ruling: levelLabels feedback.dart'a kondu (RN'de features/workout/types.ts) — Level enum'u orada — maliyet yok.
Task 3: Ruling: roundPercentages eşit kesirde indeks sırasıyla kararlı sıralanır — JS sort kararlı, Dart değil — RN ile aynı sonuç.
Task 3: Ruling: ilk commit check.sh kırmızıyken pushlandı (analiz info'ları); düzeltme commit'i eklendi — komut zincirinde ';' hatası — maliyet: geçmişte 1 kırmızı commit.
Task 3: complete (commits a4247e5..7d75aed, tests: ./tool/check.sh → check: tamam)
Task 4: Ruling: auth_rules form düzeyinde doğrular (validateSignIn/SignUp/ForgotPassword/VerifyCode/ResetPassword → FormResult) + emailError/passwordError/normalizeOtp; authErrorMessage(AuthErrorInfo, AuthAction) — RN schemas/authErrors birebir; ağ hatası regex'ine Dart soket mesajları eklendi — yanlışsa Task 10/13 adaptasyonu.
Task 4: Ruling: greetingFor(int minutes) (plan 'hour' demişti) + suggestedMealFor — RN imzası dakika — maliyet yok.
Task 4: Ruling: email_not_confirmed mesajı 'bağlantısına dokun' yerine 'kodu gir' — RN kod akışına geçmişti, metin eskimişti — kullanıcıya doğru yönerge.
Task 4: Ruling: home_test ve impl aynı adımda yazıldı (RED gözlenmedi) — testler RN'de geçen birebir taşıma; diğer dosyalarda RED gözlendi — risk düşük.
Task 4: domain toplamı 171 test (plan 169; greeting 2 test + auth 13+9=22).
Task 4: complete (commits 7d75aed..897320f, tests: ./tool/check.sh → check: tamam)
Task 5: dispatched implementer (sonnet), BASE saglik-app 654436e; Step 6 (remote push) held for user approval.
Task 5: complete (saglik-app commits 654436e..8d2a251, review clean, 3 minor deferred)
Final: minor (deferred): delete-account deletions temizliği {error} dönüşünü kontrol etmiyor (sessiz başarısızlık, istek yine başarılı)
Final: minor (deferred): deletions tablosunda budama/retention yok; panelden silinen kullanıcının kayıtları kalır
Final: minor (deferred): pgTAP'ta profiles row_id ve updated_at UPDATE tetikleyicisi testi yok
Task 5: Ruling: saglik-app main'e yerel commit, git push yok; uzak DB push + delete-account deploy kullanıcı onayına bırakıldı — paylaşılan prod DB — onay gelmezse Flutter senkronu uzakta çalışmaz.
Task 6: Ruling: yerel tablo sayısı 17 (plan '18' yanlış saymış: 8 kullanıcı + 7 katalog + outboxOps + syncCursors); sunucu deletions tablosu yerelde aynalanmaz, yalnızca çekmede okunur — yanlışsa bir tablo eklenir.
Task 6: complete (commits 897320f..ff7f084, review clean, 4 minor deferred; check.sh re-run by controller → tamam)
Final: minor (deferred): favoriteFoods yerelde (user_id, food_id)/(user_id, custom_food_id) unique yok
Final: minor (deferred): database_test adı '18 tablo' diyor, 17 doğruluyor
Final: minor (deferred): database.dart import sırası
Final: minor (deferred): sqlite3_flutter_libs ^0.6.0+eol — sqlite3 3.x'te yerel kütüphane build hook ile geliyor olabilir; cihazda açılış Task 17'de doğrulanacak
Task 7: complete (commits ff7f084..4a764a4, review clean, minors deferred)
Final: minor (deferred): tables.dart outboxOps yorum satırı eskimiş ('Task 7')
Final: minor (deferred): dış transaction'da throw → outbox rollback testi yok
Task 7: Ruling: drift satır sınıfı OutboxRow olarak adlandırıldı (domain OutboxOp ile çakışma) — maliyet yok.
Task 5 Step 6: kullanıcı onayıyla uzak migration 20261118120000 uygulandı (migration list doğruladı). delete-account deploy izin sınıflandırıcısı tarafından reddedildi → kullanıcıya bırakıldı.
Task 8: Ruling: syncNow() SyncResult döndürür (brief 'Future<void>' diyordu) — spec: kalıcı hatada işlem bırakılır ve kullanıcıya bildirilir; void dönüş bildirimi imkânsız kılıyor — maliyet: imza değişikliği, tüketici yok henüz.
Task 8: minor (deferred): favorites cihazlar arası çift kayıt (yerel unique yok; 23505 drop)
Task 8: minor (deferred): geç commit eden satırlar atlanabilir (pull örtüşme penceresi yok)
Task 8: minor (deferred): profiles update 0 satırda başarı sayılıyor
Task 8: minor (deferred): push/pull/downloadCatalogs tek kilitte değil; çalışan senkrona katılan çağrı sonradan eklenen op'ları göndermiyor
Task 8: fix round 1/5 (2 addressed, 0 open; commits 5dfb9a7..67ff4d4)
Task 8: complete (commits 4a764a4..67ff4d4, review clean after 1 fix round)
Task 8: minor (deferred): push ağ hatasında throw ederse pull atlanır ve syncNow exception fırlatır → Task 10 SessionController syncNow hatalarını yakalamalı (çevrimdışı açılış)
Task 8: minor (deferred): drop sonrası başarılı geri alma kullanıcıya 'geri alındı' demiyor; UI droppedReasons'ı göstermeli (Task 16/ileri)
Task 8: minor (deferred): newer-pending-skip ve delete-drop-restore dalları için birim test yok
Task 8: NOTE for later tasks: outbox payload anahtarları SQL snake_case; drift toJson (camelCase) doğrudan kullanılmaz; tasks.time sunucudan 'HH:MM:SS' gelir.
Task 9: Ruling: Mono radius 20 (plan 4 demişti) — taslak kartları 22px yuvarlak; spec 'değerler taslaktan' diyor — yanlışsa tek sabit.
Task 9: Ruling: sari açık tonu #8A5300, kirmizi koyu tonu #FF5A5C (RN #d71921 koyu zeminde 4.5 altında) — AA testi — maliyet yok.
Task 9: Ruling: fontlar değişken (variable) TTF; FontWeight'in wght eksenine yansıması cihazda Task 12'de kontrol edilecek — yanlışsa fontVariations eklenir.
Task 9: Ruling: ek API: contrastRatio, modeFromString, defaultAccentFor, buildThemeData(MfTheme) testli.
Task 9: complete (commits d109dfe..59feabd, tests: ./tool/check.sh → check: tamam)
Task 10: implementer DONE 98f4e26 (no separate RED run — tests with code; noted for final review); review dispatched (opus).
Task 10: review Changes requested (2 Critical race/user-switch, 2 Important keystore crash + missing race tests) → fix round 1 sent to implementer.
Task 10: minor (deferred): signOut offline'da ağ hatasını yeniden fırlatıyor (veri yine de temizleniyor)
Task 10: minor (deferred): zorla çıkışta (refresh token iptal) gönderilmemiş outbox sessizce silinir — ürün sahibine bildirilecek
Task 10: minor (deferred): signOut için AuthAction.callback, yeniden doğrulama için signIn mesajları kontrol edilmeli
Task 10: fix round 1/5 (4 addressed, 1 new open — resetOnError→last==null skips clear; commits 98f4e26..897ceb0)
Task 10: minor (deferred): _sync zaman aşımı yok; asılı istek çıkış temizliğini geciktirir (güvenli)
Task 10: minor (deferred): engine.syncNow kontrolcü dışında çağrılırsa kuyruğu atlar — belgelenmeli
Task 10: minor (deferred): persist/removePersistedSession keystore hatasında throw
Task 10: minor (deferred): kontrol başarısızsa Supabase oturumlu ama state.userId null — router bunu oturum saymamalı (Task 12)
Task 10: fix round 2/5 (1 addressed, 0 open; commits 897ceb0..c76c5c5)
Task 10: complete (commits 59feabd..c76c5c5, review clean after 2 fix rounds)
Task 10: Ruling: last_user_id null iken de temizlik yapılır; çıkışta 'signed-out' işareti yazılır — keystore sıfırlanınca kullanıcılar arası sızıntıyı önler — maliyet: keystore bozulduğunda gönderilmemiş yerel değişiklikler silinir.
Task 11: review Changes requested (1 Important: update no-op without local row) → fix round 1 sent.
Task 11: minor (deferred): tema önbelleği ve accent_customized kullanıcıya özel değil (kullanıcı değişiminde kısa süre eski tema)
Task 11: minor (deferred): hızlı art arda dokunuşta ara değer kısa süre görünebilir; prefs yazımları await edilmiyor
Task 11: fix round 1/5 (2 addressed, 0 open; commits b8e32c1..c2f5ef8)
Task 11: complete (commits c76c5c5..c2f5ef8, review clean after 1 fix round)
Task 11: minor (deferred): fromServer bilinmeyen enum değerlerini normalleştirip geri itebilir (nadir yol)
Ruling: Görev 12-16 (ekranlar) controller bağlamını korumak için tek bir implementer ajana sırayla verilir, görev başı ayrı inceleme YOK (kullanıcının ara yol kararı: ekranlarda görev başı inceleme yok); son tüm-dal incelemesi hepsini kapsar — maliyet: inline ile benzer token, controller bağlamı korunur.
Task 12: complete (commits c2f5ef8..0e225fc, no per-task review per ruling; device check skipped — user away; /profil/ayarlar placeholder to be replaced in Task 16)
Task 13: complete (commits 0e225fc..cb8db92, no per-task review per ruling; no device)
Task 13: minor (deferred): AuthRepository.resendSignUpCode birim testi yok
Task 14: complete (commits cb8db92..e020143, no per-task review per ruling; no device)
Task 14: Ruling (implementer): deneme bildirimi Future.delayed+show (uygulama açıkken); compileSdk 37 + core library desugaring eklendi (plugin v23 gereği).
Task 15: complete (commits e020143..a3e8ea5, no per-task review per ruling; no device)
Task 15: minor (deferred): onboarding saat dilimini yazmıyor (RN cihaz saat dilimini yazıyordu); varsayılan Europe/Istanbul
Task 15: Ruling (implementer): 'aktivite ve hedef' tek adımda (7 adım toplam); izin reddedilirse notification_settings.enabled=false.
Task 16: complete (commits a3e8ea5..c6ebb71, no per-task review per ruling; no device)
Task 16: minor (deferred): bildirim izni reddedildiğinde 'Ayarları aç' düğmesi yok
Final review: Ready with fixes (2 Important: I-1 first-login onboarding redirect/catalog failure skips pull; I-2 Google re-auth different account before delete).
Final: Ruling: re-graded to fix-wave by user effect: M-1 (onboarding'den çıkış yok), M-2 (şifre sıfırlamada updatePassword hatası kayboluyor), M-3 (hesap silmede beklenmeyen hata mesajsız), controller-found UI bug: alt bardaki etiketin altında sarı çift çizgi (Material/DefaultTextStyle ataması eksik), deferred minors 'push throws→pull skipped' (I-1 kökü), 'onboarding saat dilimi yazmıyor', 'userId null→sonsuz splash' (splash'te yeniden dene/çıkış) — hepsi kullanıcının göreceği hatalar.
Final: minor (deferred): M-4 data katmanı ui/theme enumlarını import ediyor (ileride domain'e taşınmalı); M-5 ThemeController her profil emisyonunu benimsiyor (onboarding önizlemesi sıfırlanabilir)
Final: fix wave re-review — 7/7 addressed (commits c6ebb71..004c19f).
Final: Ruling: m1 (ilk çekme biter bitmez profil akışı henüz yayılmadan 1 karelik /onboarding görünmesi) park edildi — hiçbir şey yazılmıyor, yalnızca anlık titreme; ikinci fix dalgası yok — maliyet: ilk Flutter girişinde kısa bir yanıp sönme, Aşama 2 başında düzeltilebilir.
Final: Ruling: m2 (Google sub ön kontrolü karar veremezse yanlış hesapla oturum açılır, ardından eşleşmezlik yakalanıp çıkış yapılır; orijinal kullanıcının gönderilmemiş yerel değişiklikleri silinebilir) park edildi — nadir köşe durumu, hesap silinmiyor — maliyet: nadir yerel veri kaybı.
Final: minor (deferred): şifre sıfırlamada kod doğrulandıktan sonra uygulama kapanırsa eski şifreyle oturum açık kalır; onboarding onam adımındaki çıkış hatası _saveError'u paylaşıyor
```

## Aşama 2a notu: tam zamanlı alarm izni

- Dinlenme bitişi tam zamanlı alarmla (`zonedSchedule`, `exactAllowWhileIdle`) gelir. API 33+ için `USE_EXACT_ALARM` kullanılıyor; kullanıcıya sorulmadan verilir. `SCHEDULE_EXACT_ALARM` yalnızca API 31–32 için (`maxSdkVersion="32"`).
- **Play Store'a çıkmadan önce yeniden düşünülmeli:** `USE_EXACT_ALARM` mağaza denetimine tabidir (yalnızca alarm/takvim uygulamalarına izin verilir). Seçenekler: `SCHEDULE_EXACT_ALARM` + izin ekranına yönlendirme ya da dinlenme boyunca kısa bir ön plan servisi.
- İzin yoksa eklenti `exact_alarms_not_permitted` verir; uygulama gecikebilen alarma (`inexactAllowWhileIdle`) düşer.
