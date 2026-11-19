# Aşama 2a: Antrenmanın kalbi (Tasarım)

Tarih: 2026-11-19. Durum: kullanıcı onayladı (2026-11-19).
Taslaklar: `.superpowers/brainstorm/166227-1795094408/content/`. Onaylananlar: `vucut-3d.html` (iki stil), `odak-modu.html` (odak ve dinlenme).

## Neden

Eski RN antrenman ekranı antrenmana yardım etmiyordu. Tüm egzersizler ve setler tek uzun listede duruyordu. Her sette klavye açılıyordu ve geçen seferin değerleri görünmüyordu. Kullanıcı (kendisi, calisthenics ve fonksiyonel) antrenmanı o güne göre şekillendiriyor: "sırtım ağrıyorsa göğüs yaparım". Kafasında bir hareket listesi oluyor ama sırası değişiyor ("dips dolu, önce bench"). Bazen de o an yeni bir hareket deniyor. Bazı haftalar önceden plan yapıyor.

Bu aşamanın amacı şu: antrenmana hızlı başlamak, salonda tek elle ve klavyesiz set girmek, dinlenmeyi telefon kilitliyken de takip etmek. Bunlara ek olarak haftanın kas dağılımını güzel bir 3B maketle görmek. Maket Aşama 5'teki bölge rankının da gösterileceği yer olacak.

## Kapsam (Aşama 2'nin bölünmesi, onaylandı)

- **2a (bu doküman):** Antrenman sekmesi + 3B maket, liste kurarak başlama, odak modu, dinlenme sayacı (tam ekran + kilit ekranı), antrenmanı kaydetme ve özet.
- **2b:** Akıllı ağırlık önerisi, rekor kutlaması, dinlenme ekranında "geçen hafta şöyleydin" motivasyonu.
- **2c:** Calisthenics: katalog eksikleri (muscle-up, L-sit, amuda kalkma, front lever, pistol…), ek ağırlıklı vücut ağırlığı, tutuş süresi, ilerleme basamakları. Kullanıcı kataloğu öne çekmeyi gerekli görmedi.

## Hedefler

1. Antrenman sekmesi açılınca "bu hafta hangi kasları ne kadar çalıştım" sorusu tek bakışta cevaplanır.
2. Bir antrenmana en çok üç dokunuşla başlanır: bölge → hareketler → başla. "Son antrenmanı tekrarla" ile tek dokunuş yeter.
3. Odak modunda klavye açılmaz. Değerler önceden dolu gelir, set tek tuşla tamamlanır.
4. Dinlenme sayacı uygulama arka plandayken ve ekran kilitliyken de doğru akar. Süre dolunca telefon titrer.
5. Yarım kalan antrenman kaybolmaz: uygulama kapansa, telefon yeniden başlasa bile kalan yerden devam edilir.
6. Yanlış girilen set kolayca düzeltilir.

## Hedef dışı (bu aşamada yok)

- Akıllı öneri, rekor, motivasyon metni (2b). Dinlenme ekranında motivasyon satırının yeri ayrılır ama boş kalır.
- Yeni calisthenics hareketleri, tutuş süresi ve ek ağırlık girişi (2c). Mevcut `duration` ve `reps` takip tipleri desteklenir.
- Haftalık plan, kendi şablonunu kaydetme, egzersiz geçmişi grafikleri (sonraya bırakıldı).
- Bölge rankı (Aşama 5). Maket rankı gösterebilecek şekilde kurulur ama rank hesaplanmaz.
- Sunucu şeması değişikliği. Mevcut `workout_sessions` ve `session_sets` yeterli.

## Anti-hedefler (çalışsa bile başarısızlık sayılır)

- Antrenman sırasında klavye açılması, ya da set girmek için küçük alanlara dokunmak zorunda kalınması.
- Kilit ekranında sayacın donması, ya da süre dolunca haber verilmemesi.
- Uygulama arka plana atılınca antrenmanın kaybolması.
- Maketin "kaba" görünmesi. Kullanıcının sözü: "uygulamada bu kadar kaba durmamalı kesinlikle." Taslaktaki elipsoid gövde kabul edilmez.
- Odak modunun sabit sıraya kilitlenmesi. Sıra her an değiştirilebilmeli.

## Yaklaşımlar (maketin çizimi; kullanıcı 1'i seçti)

1. **Önceden çizilmiş kareler (seçilen).** Anatomik model Blender Cycles ile 360° etrafında karelere çizilir. Her karede ışıklı bir görüntü ve bir "bölge kimliği" haritası bulunur. Telefon parmağın açısına göre kareyi seçer ve bölgeleri bir shader ile boyar.
   - Artısı: en gerçekçi görüntü (yumuşak gölge, kas girintileri), her telefonda akıcı, test edilebilir.
   - Eksisi: ~3-4 MB varlık, yalnızca yatay dönüş.
   - Kullanıcının sorusu: "yayınlamayacağım, en iyi görüneni mi yapsam?" Cevap: en iyi görünen zaten bu.
2. **Gerçek zamanlı 3B (`flutter_scene`).** Serbest dönüş sağlar ama motor deneysel ve gölge kalitesi daha düşük. Kullanıcı ileride buna dönmek isteyebilir. Bu yüzden maket tek bir arayüzün arkasında durur ve model hazırlama hattı iki yolda da ortaktır.
3. **WebView + three.js.** Açılışı yavaş, pili daha çok tüketir, uygulamada yabancı hissettirir. Elendi.

## Kullanıcının kararları

### Antrenman sekmesi
- En üstte 3B insan maketi (önden-arkadan değil, döndürülebilir tek model), altında "Bu hafta" bölge listesi ve **Antrenmana başla**.
- Maket **"bu hafta"** görünümünü gösterir (A seçildi): pazartesiden beri her bölgeye yapılan set yoğunluğu. Bir bölgeye ya da listedeki satırına dokununca "son çalışma: 2 gün önce" görünür.
- **Stil temaya bağlı:** Mono (Nothing, Profesyonel) temada nokta-matris maket. Çalışılan bölgenin noktaları vurgu renginde yanar ve yoğunluk arttıkça büyür. Canlı (Spotify, Eğlenceli) temada parlayan heykel. Çalışılan bölge vurgu renginde ışır, yoğunluk arttıkça daha çok parlar. Stil, tema tanımındaki tek bir alanla seçilir: `bodyMapStyle: dots | glow`.
- Yoğunluk sayılarla da yazar (liste ve ölçek). Bilgi yalnızca renkle verilmez.

### Başlarken liste kurma
- Bölge çipleri → o bölge için kullanıcının daha önce yaptığı hareketler (işaretlenir) → katalogda arama → "N hareketle başla".
- Hiç liste kurmadan **boş başla** da mümkün.
- Son 3 antrenman listelenir; "Tekrarla" aynı hareketlerle başlatır. 10 hazır şablon "Hazır programlar" altında kalır.

### Odak modu
- Ekranda yalnızca o anki hareket ve set bulunur. Üstte hareket ilerlemesi (2/4), altında set noktaları (2/4).
- Ağırlık ve tekrar alanları geçen seferin değerleriyle dolu gelir; –/+ ile değişir. İlk kez yapılan harekette alanlar boştur.
- Alttaki şeritten istenen harekete sırasız geçilir. "+ Ekle" antrenman ortasında hareket ekler. Yarım kalan hareket listede bekler.
- **Seti tamamla** → dinlenme ekranı.
- **Önceki sete dönme (kullanıcının isteği):** Set noktasına dokununca o set açılır ve düzenlenir (Kaydet / Seti sil, silme onaylı). Dinlenme ekranında "Son seti düzenle" düğmesi vardır; basınca sayaç durur. Ayrıca tamamladıktan sonra 5 sn boyunca "Geri al" görünür.

### Dinlenme
- Tam ekran geri sayım (Mono: 60 noktalı halka; Canlı: yeşil halka), ±15 sn, Atla.
- Kilit ekranında ve bildirimde akan sayaç: kalan süre, sıradaki set, "+15 sn" ve "Atla". Süre dolunca güçlü titreşim.
- Süre her hareket için hatırlanır, ilk değer 90 sn. Hazır şablondan başlanınca şablonun `rest_seconds` değeri kullanılır.

### Güvenlik ve bitiş
- Yarım kalan antrenman açılışta "Devam et" ile sürer.
- **Bitir** → özet: süre, set, hacim, kalori ve bu antrenmanda çalışılan bölgeler maket üzerinde.
- Her şey önce telefona yazılır, internet olunca senkronlanır (mevcut outbox).

## Claude'un kararları (kullanıcı itiraz edebilir)

- **Yoğunluk ölçeği:** Mevcut `muscle_coverage` kuralı kullanılır: birincil kas 1, ikincil 0,5 ağırlıklı set; "yeterli" ≥ 4. Maketin 4 kademesi şöyle: **0 / 0,5–3,5 / 4–9,5 / 10+ ağırlıklı set**. Taslaktaki 1–5 / 6–11 / 12+ yalnızca örnekti.
- **Bölgeler:** Sunucudaki 14 kas grubu olduğu gibi kullanılır: chest, shoulders, biceps, triceps, forearms, abs, obliques, traps, lats, lower_back, glutes, quads, hamstrings, calves. Listede kullanıcı dostu 6 üst bölgede toplanır (mevcut `BodyRegion`: göğüs, sırt, omuz, kol, karın, bacak). Kas ayrıntısı satıra dokununca açılır.
- **Mono'nun nokta-matrisi ekran ızgarasından yapılır.** Taslakta noktalar 3B yüzeyden örneklenmişti. Uygulamada ise aynı karelerden, ekran üzerinde sabit bir nokta ızgarası çizilir. Noktanın parlaklığı ışıklı görüntüden, rengi ve boyutu bölge kimliğinden gelir. Böylece iki stil aynı varlıklarla çalışır, örtüşme sorunu olmaz ve görüntü Nothing'in Glyph matrisine daha yakın olur. Görüntü taslaktan farklı çıkarsa kullanıcıya gösterilip onay alınır.
- **Görünüş (kullanıcının kararı): kaslı atlet heykeli.** Derisi olan, kasları belirgin bir sporcu vücudu. Kaslar deri altından girinti-çıkıntılarıyla görünür, çalışılan bölge yüzeyin üzerine boyanır. Derisiz anatomi atlası görünümü reddedildi.
- **Model kaynağı (Claude'un kararı): MakeHuman / MPFB** (Blender eklentisi). Kaslı ve düşük yağlı bir erkek vücudu kullanılır; çıktısı CC0'dır. 14 bölge, betikle tanımlanan yüz seçimlerinden (vertex group) oluşur: kas sınırlarına göre elle ayarlanmış, kaydedilmiş bir bölge haritası. Bölge sınırlarının taslaktaki kadar net okunması gerekir. Kas tanımı yetersiz kalırsa normal haritası ya da sculpt ile güçlendirilir; ölçüt "kaba durmamalı". İlk sürümde tek erkek vücudu var; kadın vücudu aynı betikle sonra eklenebilir.
- **Kare sayısı ve boyut:** 72 kare (5° adım). Her kare bir ışıklı görüntü (gri tonlu, WebP) ve bir bölge kimliği haritası (kayıpsız PNG; 0 = cilt, 1–14 = bölge, 255 = boş). Hedef toplam ≤ 4 MB. Kare sayısı ve çözünürlük bu sınıra göre ayarlanabilir.
- **Varlık hazırlama:** Blender betiği `tools/body_map/` altına konur ve depoya girer (tekrar üretilebilsin). Çıktı `assets/body_map/` altına yazılır. Blender bilgisayara pacman ile kurulur (kullanıcı onay verdi).
- **Dönüş:** Sürükleyince kare değişir; bırakınca yumuşak biçimde durur. Kendi kendine yavaş dönme yalnızca sekme ilk açıldığında bir tur atar. "Hareketi azalt" ayarı açıkken dönmez, ön görünümde durur.
- **Dokunma:** Maket üzerindeki dokunuş, o karenin kimlik haritasından bölgeyi bulur. Küçük kaslar için liste satırları her zaman dokunulabilir alternatiftir (≥ 48 dp).
- **Ağırlık adımı ekipmana göre:** halter 2,5; dambıl 2; makine ve kablo 5; vücut ağırlığı 0 (alan gizli, yalnızca tekrar); kettlebell 4 kg. Basılı tutunca değer hızlanarak akar. Birim lb ise eşdeğer adımlar kullanılır (5 lb vb.).
- **Takip tipleri:** `weight_reps` (kg + tekrar), `reps` (tekrar), `duration` (süre; –/+ 5 sn, ayrıca "başlat" ile sayan bir kronometre).
- **Dinlenme sayacının kilit ekranı:** `flutter_local_notifications` ile geri sayan kronometreli, sürekli bir bildirim (Android `chronometerCountDown`) ve süre sonu için tam zamanlı alarmla güçlü titreşimli bildirim. Ön plan servisi gerekmez. Bildirim kanalı "Dinlenme", sessiz akar, yalnızca bitişte titrer.
- **Dinlenme süresi hafızası** telefonda tutulur (hareket → saniye), sunucuya gitmez.
- **Aktif antrenman:** `workout_sessions.status = 'active'` satırı ve tamamlanan her set anında yazılır. Uygulama açılışında aktif satır varsa "Devam et" gösterilir. Aynı anda tek aktif antrenman olabilir. 24 saatten eski aktif antrenman açılışta "Bitir mi, sil mi?" diye sorulur.
- **Antrenmanın hareket listesi telefonda tutulur.** Plan, sıra, henüz başlanmamış hareketler ve dinlenme hafızası yeni bir yerel drift tablosuna yazılır. Bu tablo sunucuya gitmez; sunucu şeması değişmez. Devam etme yalnızca aynı telefonda çalışır; tamamlanan setler zaten senkronlanır.
- **`exercise_order`, hareketin ilk setinin yapıldığı sırayı** tutar (planlanan sırayı değil). Sıra değişince senkronlanmış setler yeniden yazılmaz, sunucudaki benzersizlik kuralı bozulmaz. Bir hareketin tüm setleri silinirse sırası boşta kalır; sonraki hareketler kaydırılmaz. "Tekrarla" yalnızca yapılmış hareketleri geri getirir.
- **Hedef set sayısı:** Şablondan başlanırsa şablonun `sets` değeri kullanılır. Yoksa o hareketin son antrenmandaki set sayısı, o da yoksa 3. Hedef bir sınır değildir: hedefe ulaşınca "+ Set" ile devam edilir. Sıradaki set yoksa dinlenme ekranında ve bildirimde sıradaki hareket gösterilir.
- **Tam zamanlı alarm izni:** Android 14+ `SCHEDULE_EXACT_ALARM` iznini varsayılan olarak vermez. Uygulama yayınlanmayacağı için kullanıcıya izin sorulmadan verilen `USE_EXACT_ALARM` eklenir. Bu, Play Store'a çıkılacaksa yeniden düşünülecek (o zaman izin ekranına yönlendirme ya da kısa bir ön plan servisi). Bu not 'notlar' dosyasına da yazılır.
- **Titreşim:** set tamamlanınca kısa, dinlenme bitince güçlü. Başka yerde titreşim yok.
- **Ekran açık kalır** (odak ve dinlenme ekranlarında), kilit tuşuna basılırsa kilitlenir.
- **Erişilebilirlik:** –/+ ve ana düğme 60 dp; sayaç "kalan 1 dakika 12 saniye" diye okunur; düğmelerin adları "ağırlığı azalt" gibidir. Büyük yazıda rakamlar küçülmez, düzen alt alta kayar. "Hareketi azalt" açıkken halka akmaz, saniyede bir güncellenir.
- **Kalori:** mevcut `estimateWorkoutKcal` (MET) kullanılır.
- **Sekme ve yönlendirme:** Antrenman sekmesindeki "yakında" ekranı kaldırılır. Odak modu tam ekran açılır; alt bar gizlidir ve geri tuşu "Antrenmanı bitir / devam" sorar.

## Kurucuya kalanlar

- Blender betiğinin ayrıntıları: kamera, ışık (yumuşak üç nokta ve kenar ışığı), çözünürlük, malzeme. Ölçüt: taslaktaki iki stilin ruhu, gerçekçi anatomik görünüm.
- Shader'ın yazımı (`FragmentProgram`). Mono ızgarasının nokta aralığı, Canlı'nın parıltısı.
- Veri sorguları, Riverpod sağlayıcılarının yapısı, ekran dosya düzeni.
- Liste kurma ekranındaki "daha önce yaptığın hareketler" sıralaması (önerim: son yapılma tarihine göre).
- Özet ekranının ayrıntılı yerleşimi (taslak yok; odak modu diliyle tutarlı).

## Başarı ölçütü

Kullanıcı telefonda gerçek bir antrenmanı baştan sona bu ekranlarla yapar ve şunları doğrular:
- Klavye hiç açılmadı.
- Sıra değişti, hareket eklendi, yanlış set düzeltildi.
- Telefon kilitliyken sayaç aktı ve bitişte titredi.
- Uygulama kapatılıp açılınca antrenman devam etti.
- Antrenman sonunda maket bu haftanın çalışmasını doğru gösterdi.
