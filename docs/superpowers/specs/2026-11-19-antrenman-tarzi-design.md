# Antrenman tarzı, seviye ve hedefler — Tasarım (kısa)

Tarih: 2026-11-19. Durum: onaylandı (2026-11-19).

## Neden

Uygulama "canlı" olacak: kişinin ne için spor yaptığını bilip antrenmanda ona göre öneri yapacak ("muscle-up hedefin için şunları ekle", "itişin zayıf, dips ve pike push-up seni geliştirir"). Bunun için tarz baştan, onboarding'de sorulmalı. Aşama 1 tasarımında Aşama 4'e bırakılmıştı; kullanıcı şimdi istedi. Toplamak ucuz, sonradan eski kullanıcılara tekrar sormak pahalı.

## Hedefler

- Onboarding'de **ana tarz + isteğe bağlı yan tarzlar** ve **seviye** sorulur (zorunlu).
- Ayrı, **atlanabilir** bir adımda **hedef hareketler** ve **geliştirilecek alanlar** seçilir.
- Hepsi Profil'den değiştirilebilir.
- Çevrimdışı kaydedilir (mevcut outbox senkronu).

## Hedef dışı

- Seçimlere göre öneri/tepki üretmek (Antrenman sayfası tasarımında ve Aşama 4'te).
- Kalori hedefi (kilo ver/koru/al) değişmez; ayrı kalır.
- Serbest metin hedef girişi (kural tabanlı v1 anlayamaz).

## Yaklaşımlar

- **A · `profiles` tablosuna sütunlar (seçildi).** Mevcut outbox yolu, çevrimdışı çalışır, sunucuda yalnızca ekleme, en az kod.
- B · Ayrı `training_preferences` tablosu: yeni RLS + senkron kodu; tek satırlık veri için fazla.
- C · Tek JSON sütunu: sunucu doğrulayamaz, ileride (rank/sıralama) sorgulamak zor.

## Veri (kararlaştırılan)

`profiles` tablosuna, hepsi boş başlayan (nullable):

| Sütun | Tür | Değerler |
|---|---|---|
| `training_style` | text | `calisthenics`, `bodybuilding`, `functional`, `strength`, `conditioning`, `general` |
| `side_styles` | text[] | aynı küme; ana tarzı içeremez, tekrar yok |
| `training_level` | text | `beginner`, `intermediate`, `advanced` |
| `goal_moves` | text[] | aşağıdaki anahtarlar |
| `focus_areas` | text[] | `push`, `pull`, `legs`, `core`, `mobility`, `conditioning` |

- Sunucuda check kısıtları değerleri doğrular; bu sütunlar istemcinin `grant update` listesine eklenir (RLS: yalnızca kendi satırı).
- Yerel drift şeması bir sürüm artar (`addColumn`); `Profile.toPayload()` bu alanları **gönderir** (kullanıcı adı/avatarın aksine).
- RN istemcisi etkilenmez (kısmi update yapıyor).

## Hedef hareket listesi (Claude'un kararı, düzenlenebilir)

Ekranda ana tarzın listesi önce, yan tarzlarınki ardından gösterilir (tekrar edenler bir kez).

- **Calisthenics:** `first_pullup` İlk barfiks, `muscle_up` Muscle-up, `handstand` Handstand, `front_lever` Front lever, `pistol_squat` Pistol squat, `l_sit` L-sit, `planche` Planche
- **Vücut geliştirme:** `bench_up` Bench press'i artırmak, `squat_up` Squat'ı artırmak, `deadlift_up` Deadlift'i artırmak, `bigger_arms` Daha güçlü kollar, `wider_back` Daha geniş sırt, `shoulders` Omuz gelişimi
- **Fonksiyonel:** `first_pullup`, `rope_climb` Halat tırmanışı, `box_jump` Box jump, `kb_swing` Kettlebell swing, `get_up` Turkish get-up
- **Güç:** `squat_up`, `bench_up`, `deadlift_up`, `ohp_up` Overhead press'i artırmak
- **Kondisyon:** `run_5k` 5 km koşu, `run_10k` 10 km koşu, `hiit_endurance` HIIT dayanıklılığı
- **Genel form:** `consistency` Düzenli antrenman, `flexibility` Esneklik, `posture` Duruş

## Arayüz (taslak onaylandı: `.superpowers/brainstorm/…/tarz-adimi.html`)

- **Onboarding sırası:** Rıza → Profilin → **Tarzın** → **Hedeflerin** → Doğum → Vücut → Hareket ve hedef → Kalori önizlemesi → Bildirim → Tema (10 adım).
- **Tarzın:** 2 sütunlu kart ızgarası (çizgi ikon + ad + kısa açıklama). İlk dokunuş ana tarz ("ANA" rozeti), sonrakiler yan tarz; seçili karta tekrar dokunmak kaldırır; ana olmayan seçili karta uzun basmak onu ana yapar (ana kaldırılırsa ilk yan tarz ana olur). Altında Yeni/Orta/İleri seviye seçici. Ana tarz ve seviye seçilmeden Devam hata gösterir.
- **Hedeflerin:** "Hedef hareketler" ve "Geliştirmek istediğin alanlar" çoklu seçim çipleri; "Devam" ve "Şimdilik atla". Atlanınca listeler boş kaydedilir.
- **Profil:** "Antrenman tarzım" satırı → aynı iki bölümü tek sayfada düzenleyen ekran; Kaydet outbox'a yazar.
- **Eksik profil:** Onboarding'i bitirmiş ama `training_style` boş hesaplarda profil başlığındaki "Profilini tamamla" görünür ve tarz ekranına da götürür.
- ui-ux-pro-max kuralları: dokunma alanı ≥ 48 dp, kontrast ≥ 4.5:1 (her iki tema, açık/koyu), emoji yerine ikon, seçimde görsel + metin geri bildirim (yalnızca renk değil: rozet/onay işareti).

## Sonraki tasarıma taşınan kural (öneriler — kullanıcının kararı)

Öneriler bu işin kapsamında değil, ama Antrenman sayfası/Aşama 4 tasarımı şuna uymalı:

- Öneri **ana tarza uygun** hareket olmalı. "İtiş zayıf" → calisthenics: dips, pike push-up; vücut geliştirme: incline dumbbell press, göğüs press makinesi; güç: close-grip bench, overhead press. Tarzına uymayan hareket önerilmez (bodybuilder'a "dips yap" denmez).
- **Geçmişe dayalı basit algoritma:** önce kişinin son haftalarda yaptığı ve zayıf alanı çalıştıran hareketler (ör. "bench'e bir set ekle / ağırlığı artır"); yalnızca yoksa tarzına uygun, hiç yapmadığı bir hareket kısa açıklamayla ("yeni bir hareket dene").
- Gereken: egzersiz kataloğunda her hareketin **tarz(lar)** ve **alan** (push/pull/legs/core/mobility/conditioning) etiketi.

## Kurucuya kalanlar

- İkonların tam seçimi (Material Symbols içinden), metinlerin son hali.
- Testler: onboarding akışı (zorunlu alan, atla, geri dönünce korunma), ana/yan tarz kuralları (saf Dart, `lib/domain`), drift göçü, pgTAP (check kısıtları, başkasının satırı), Profil düzenleme.
