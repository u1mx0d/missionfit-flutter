# MissionFit Flutter: Beyin fırtınası notları (devam noktası)

Son oturum: 2026-11-18. Durum: **tasarım konuşması sürüyor**. Henüz tasarım dokümanı yazılmadı, kod yok.
Akış: superpowers:brainstorming → (yaklaşımlar → tasarım dokümanı → onay) → superpowers:writing-plans.

## Ne yapıyoruz
`~/projelerim/saglik-app` içindeki React Native (Expo SDK 58) MissionFit uygulaması Flutter'da sıfırdan yazılacak.
Kaynak projede ayrıntılı durum ve kararlar için `PROGRESS.md` var. Orijinal spec: `~/Masaüstü/Masaüstü/PROMPT.md`.

Modüller aynı kalıyor:
- Antrenman: şablon veya boş antrenman, set set giriş, vücut haritasında çalışılan bölgeler, seri
- Kalori: hazır yemek veritabanından arama, kişisel yemek ekleme
- Görevler: görev öncesi bildirim

## Kullanıcının kararları
- **Neden Flutter'a geçiliyor:** Tasarım baştan ele alınacak ve daha profesyonel olacak. Modern, işe yarar fikirler de eklenebilir.
- **İlk sürüme eklenecek yeni özellikler (1, 2 ve 5 seçildi):**
  1. Akıllı ağırlık önerisi ("geçen sefer 60×8, bugün 62.5 dene") ve kişisel rekor kutlaması
  2. Kilit ekranında / bildirimde akan dinlenme sayacı
  5. Kilo takibi ve ilerleme grafikleri (kilo, haftalık hacim, egzersiz başına en iyi set)
- **Sonraya bırakılanlar:** Android widget, barkodla yemek ekleme (Open Food Facts), haftalık paylaşılabilir özet kartı, Health Connect.
- **Beğendiği tasarımlar:**
  - Yemeksepeti'nin yüzen navigasyon barı
  - Telegram tarzı çok sayıda tema, kategorilere ayrılmış (ör. "Profesyonel" / "Eğlenceli")
  - Spotify tasarımı
  - En sevdiği marka Nothing (sade, asil, farklı)
- **Tema yönü (görsel taslaklarla seçildi):**
  - Kendisine en yakın: **A · Mono** (Nothing esintili). Siyah-beyaz, noktalı zemin, nokta-matris rakamlar (Doto), Space Grotesk, tek kırmızı vurgu (#d71921).
  - Diğer kullanıcılar muhtemelen **B · Canlı**'yı seçer (Spotify esintili). Koyu zemin, yeşil #1ed760, degrade kartlar, Inter.
  - Kural: Uygulama içinde A ile B arasında geçiş yapılabilmeli. Yapılamıyorsa ya da çok zorluyorsa yalnızca B yapılır.

## Yeni kararlar (2026-11-18, 2. oturum)
- **MissionFit yalnızca mobil (Android) olacak, masaüstü sürümü yok.** Flutter'ın seçilme sebebi ileride yapılacak masaüstü uygulamaları: AKINSOFT ve Wolvox Restoran benzeri restoran/POS yazılımları (Windows + Linux). Bu yüzden Flutter tecrübesi bu projede kazanılıyor.
- **Renk seçimi = yalnızca vurgu rengi (A seçildi).** Tema (Mono/Canlı, açık/koyu) seçildikten sonra 8-10 hazır renkten vurgu rengi seçilir; butonlar, halkalar, grafikler, aktif sekme bu renge geçer. Zemin/yazı sabit kalır (okunabilirlik korunur). Telegram tarzı. Tüm paleti düzenleme reddedildi.
- **Yüzen alt bar: aktif sekme hap şeklinde genişler (C tarzı), seçildi.** Yalnızca aktif sekmenin adı yazar, hap vurgu rengini kullanır, sekme değişince kayarak genişler. 4 sekme: Antrenman, Kalori, Görevler, Profil.
- **Git/GitHub:** Yeni, herkese açık depo: u1mx0d/missionfit-flutter (gh ile bağlı hesap u1mx0d). Plan görevi başına commit + push. Eski RN deposu u1mx0d/missionfit dokunulmadan kalır. Kullanıcı ilerlemeyi Android Studio'dan (Nothing Phone 2a, hot reload, Git log) takip edecek.
- **Antrenman ekranı = Odak modu (kabul edildi).** Mevcut RN ekranının sorunu: tüm egzersiz/setler tek uzun listede, her set için klavye, geçen seferin değerleri görünmüyor, antrenmana yardım etmiyor. Yeni: ekranda yalnızca o anki egzersiz + set; değerler geçen seferden/akıllı öneriden dolu gelir; klavye yerine –/+; tek tuş "Seti tamamla"; ardından tam ekran dinlenme sayacı (kilit ekranında da); kaydırarak sonraki egzersiz; istenirse tam liste; rekor kutlaması.
- **Dinlenme ekranında motivasyon:** "Geçen hafta şöyleydin, bu hafta şöylesin, devam" tarzı, gaz veren karşılaştırmalar.
- **Amaca duyarlı "canlı" uygulama:** Kullanıcı antrenman tarzını/amacını girer (kendisi: bodybuilding'den calisthenics + fonksiyonel'e geçti, "hantallaştım" dedi). Uygulama buna göre tepki verir: ör. "dips ekledin, senin amacına faydası şu". Calisthenics için vücut ağırlığı/ağırlıklı vücut ağırlığı, tutuş süreleri (plank, L-sit) ve ilerleme basamakları düşünülmeli. Mevcut tracking tipleri: weight_reps | reps | duration.
- **Canlı içerik = önce A (hazır kurallar), sonra B (yapay zekâ koçu). Seçildi.** Sebep: LLM maliyetini şu an karşılayamıyor. v1 tamamen kural tabanlı, çevrimdışı, ücretsiz; mimari ileride YZ koçu eklenebilecek şekilde kurulacak.
- **Rank sistemi (yeni istek):** Kullanıcı boy, kilo, yağ oranı, kas oranı girer → başlangıç "görünüş rankı". Rank diyet ve antrenmana göre gün gün yavaş artar. Her vücut bölgesinin ayrı rankı var (o hafta kol çalışmazsa kol rankı düşer). Diyet verisi girilmezse genel rank düşer. Derece derece (kademeli) olacak. İleride YZ'ye fotoğraf verilerek tamamen görüntüden rank (B aşaması). Mevcut RN'de muscleCoverage (bölge/kas eşlemesi) temeli var.
- **Rank şimdilik yalnızca kişisel.** Uygulama şu an yayınlanmayacak; yayınlanırsa rank sıralaması (liderlik tablosu) eklenebilir, veri modeli buna kapı bırakmalı.
- **Claude'un önerisi (itiraz edilmedi):** Rank görünüşe değil sağlıklı aralığa yaklaşma + tutarlılığa bağlı; çok düşük yağ oranı ödüllendirilmez. Düşüş yumuşak ve telafi edilebilir.
- **Aşamalar onaylandı:** 1 Temel → 2 Antrenman → 3 Kalori+Görevler → 4 Akıllı içerik → 5 Rank. Her aşamanın kendi tasarım dokümanı + planı. Şu an: **Aşama 1 tasarımı.**
- Kullanıcı eski sistemin (saglik-app) incelenip geliştirilebilir yerlerin uygulanmasını/sorulmasını istedi. Bulgular: Expo Go kısıtları (bildirim kanalı hatası, tam zamanlı alarm yok, arka planda dinlenme bildirimi yok, oturum şifresiz sqlite'ta) Flutter'da kalkıyor; uygulama ikonu hâlâ Expo şablonu; 5 vurgu rengi vardı.
- **Ana Sayfa kalıyor → 5 sekme:** Bugün (Ana Sayfa), Antrenman, Kalori, Görevler, Profil. İleride rank, motivasyon ve "bugün ne yapmalı" önerisi burada.
- İyileştirmeler (Claude'un kararı, kullanıcıya bildirildi): güvenilir bildirim kanalı + tam zamanlı alarm, arka planda dinlenme sayacı (Aşama 2), oturum flutter_secure_storage'da, 10 vurgu rengi + kontrast testleri, yeni uygulama ikonu.
- **Veri katmanı = B (drift/SQLite telefon öncelikli + Supabase senkronu). Seçildi.** Riverpod + go_router + drift. İş kuralları lib/domain'de saf Dart.
- **Supabase bölgesi eu-west-1 (İrlanda) kalıyor;** Frankfurt taşıması değerlendirildi, anlamlı fark yok (AB içinde, ~20-30 ms), pas geçildi (2026-11-18).
- **Auth: Supabase'de kalınıyor (Appwrite reddedildi).** E-posta Gmail SMTP + uygulama şifresiyle gönderilecek (domain gerekmez, ~500/gün). Ayrıca 'Google ile devam et' (native, signInWithIdToken). Dokümana eklendi.
- **Aşama 1 tasarımı onaylandı ve commitlendi.** Repo: github.com/u1mx0d/missionfit-flutter. Plan: `docs/superpowers/plans/2026-11-18-asama-1-temel.md` (17 görev). **Yürütme = ara yol (kullanıcı seçti):** Görev 5-8 ve 10-11 yardımcı ajanlarla (yazıcı + kontrolcü, superpowers:subagent-driven-development); 1-4, 9, 12-16 Claude kendisi yazar (superpowers:executing-plans); 17 kullanıcıyla birlikte; en sonda tek bağımsız inceleme. İlerleme: Görev 1-16 + son inceleme düzeltmeleri tamam (336 test). Kararlar ve ertelenen küçük bulgular: `docs/superpowers/plans/2026-11-18-asama-1-temel-notlar.md`. **Kalan: Görev 17 (kullanıcıyla):** ~~Gmail SMTP~~ (2026-11-18 tamam; +test1 adresine kod geldi. Not: var olan adresle kayıtta Supabase sessizce e-posta göndermiyor), ~~delete-account deploy~~ (kullanıcı yaptı), ~~Google Cloud OAuth + Supabase Google sağlayıcısı~~ (2026-11-18 tamam; emülatörde giriş çalıştı. Web client ID env.json içinde. Not: Android Studio env.json değişince yeniden derlemeyebilir, gerekirse `flutter clean`), Nothing Phone 2a uçtan uca test (kalan tek adım; telefonun SHA-1'i aynı debug anahtarı olduğu için ek Google ayarı gerekmez). Sonra Aşama 2 (antrenman odak modu) beyin fırtınası. Ayrıca kullanıcı arkadaşlara dağıtım sordu: Android → Firebase App Distribution önerildi; iOS → Apple Developer (99$/yıl) + Codemagic + iOS platform desteği, ayrı aşama.
- Tema kurgusuna (aşağıdaki öneri) itiraz etmedi, renk seçimini ekledi.

## Claude'un önerisi (kullanıcı henüz onaylamadı)
- Tema = tema tanımı (ThemeExtension benzeri). İçinde renkler, yazı tipleri, köşe yuvarlaklığı, kart stili ve birkaç görünüm seçeneği var (ör. kalori: halka mı, büyük sayı + çubuk mu). Ekranlar yalnızca tema tanımını okur. Baştan böyle kurulursa A ile B arasında geçiş zor değil.
- Onboarding'de tema seçimi olacak, B önceden seçili gelecek. Profil'de Telegram tarzı bir Tema galerisi olacak: Profesyonel / Eğlenceli kategorileri, her temanın açık/koyu sürümü.
- C · Sıcak (krem, Yemeksepeti tarzı) bırakıldı.

## Bekleyen sorular (buradan devam)
1. Yukarıdaki tema kurgusu doğru mu?
3. Sonra: kalan ekranlar (antrenman oturumu, kalori, görevler), yaklaşımlar, tasarım dokümanı.

## Teknik notlar (Claude'un kararları, kullanıcı itiraz edebilir)
- **Supabase arka ucu korunacak:** migration'lar, RLS, seed ve `delete-account` fonksiyonu saglik-app/supabase altında. Yalnızca istemci yeniden yazılıyor.
- **İş kuralları Dart'a taşınacak:** `saglik-app/src/domain` (299 Vitest testi) birebir Dart'a çevrilecek, testleriyle birlikte.
- **Ortam:** Flutter 3.50.0 / Dart 3.14 (`~/development/flutter`). Android toolchain hazır. Chrome yok, web hedeflenmiyor. Test cihazı Nothing Phone 2a.
- **Masaüstü (gelecekteki projeler için):** Linux derleme araçları hazır (clang, cmake, ninja, GTK 3.24). Windows sürümü Linux'ta derlenemez; Windows makinesi ya da GitHub Actions gerekir.
- **Tasarım aracı:** ui-ux-pro-max skill'i kullanılacak (Flutter yönergeleri var).
- **Görsel taslaklar:** `.superpowers/brainstorm/` altında (`tema-yonleri.html`). Sunucuyu yeniden başlatmak için brainstorming skill'indeki `scripts/start-server.sh --project-dir <bu klasör> --open` kullanılır.
- **Git:** Bu klasör henüz bir git deposu değil. Depo oluşturulunca `.superpowers/` `.gitignore`'a eklenecek.

## 2026-11-19 durumu
- **Giriş ekranı yeniden tasarımı bitti** (plan `2026-11-19-giris-ekrani.md`): nokta-matris hoş geldin, sporcu kartlı giriş/kayıt, AKTİF damgalı kod ekranı, telefonda kayıtlı kartlar (en çok 5). Genel inceleme + düzeltmeler `e1146b0`.
- **Antrenman tarzı bitti** (plan `2026-11-19-antrenman-tarzi.md`): onboarding 10 adım (Tarzın, Hedeflerin eklendi), Profil > "Antrenman tarzım", yerel şema v3. Uzak migration `20261119130000` canlıda (kullanıcı onayıyla). Son commit `c3e4108`.
- Kural: sunucuda yeni sütun gerektiren sürümde **önce `db push`, sonra APK**. Hedef listesine yeni anahtar eklenirse önce istemci yayınlanmalı (istemci bilinmeyen anahtarları atıp tam satır gönderiyor).
- Telefonda deneme bekleniyor: yeni hesapla 10 adım, atla, Profil'den değiştirme, çevrimdışı değiştirme → senkron, eski hesapta "Profilini tamamla".
- Sonraki büyük adım: **Aşama 2 (Antrenman odak modu) beyin fırtınası.**

## 2026-11-19 akşam: Aşama 2a uygulaması sürüyor (KALDIĞIN YER)
- Spec: `docs/superpowers/specs/2026-11-19-asama-2a-antrenman-design.md` (onaylı). Plan: `docs/superpowers/plans/2026-11-19-asama-2a-antrenman.md` (11 görev, subagent-driven).
- **İlerleme defteri (önce bunu oku):** `.superpowers/sdd/2026-11-19-asama-2a-antrenman/progress.md`. 2026-11-20: Görev 1-10, son inceleme düzeltmeleri, Görev 12 (kas vurgusu + set sayısı) ve Görev 13 (açık temada açık maket + değere dokunarak yazma) tamam ve push'landı (son `c7f30a1`). **Kalan: Görev 11, kullanıcının telefonda denemesi** (APK `c7f30a1` kurulu). Geri bildirim gelirse yeni görev (14…) olarak deftere yazılır.
- Sıra kuralı: Görev 9 (dinlenme) ve 8 (sekme) maketten sonra; aynı anda tek uygulayıcı ajan.
- Push: kullanıcı onay verdi. Her görevin incelemesi temiz çıkınca controller push'lar (alt ajanların push'u izin denetimine takılıyor).
- Blender 5.2.4 LTS taşınabilir: `~/.local/opt/blender/blender` (pacman veritabanı eski, `sudo pacman -Syu` kullanıcıya kaldı). MPFB eklentisi kurulu.
- Önizleme görselleri: `.superpowers/sdd/2026-11-19-asama-2a-antrenman/preview/`.
