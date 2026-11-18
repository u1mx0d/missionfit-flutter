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
- **Auth: Supabase'de kalınıyor (Appwrite reddedildi).** E-posta Gmail SMTP + uygulama şifresiyle gönderilecek (domain gerekmez, ~500/gün). Ayrıca 'Google ile devam et' (native, signInWithIdToken). Dokümana eklendi.
- **Aşama 1 tasarımı onaylandı ve commitlendi.** Repo: github.com/u1mx0d/missionfit-flutter. Plan: `docs/superpowers/plans/2026-11-18-asama-1-temel.md` (17 görev). Kullanıcının plan onayı ve yürütme yöntemi seçimi bekleniyor.
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
