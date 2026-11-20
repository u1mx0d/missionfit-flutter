# Aşama 2b: Akıllı antrenman (Tasarım)

Tarih: 2026-11-20. Durum: kullanıcı tasarımı onayladı (2026-11-20). Uygulama bu oturumda yapılmayacak; yalnızca tasarım kaydedildi.
Önceki: `2026-11-19-asama-2a-antrenman-design.md` (2b orada "akıllı ağırlık önerisi, rekor kutlaması, dinlenmede motivasyon" olarak ayrılmıştı).

## Neden

2a ile antrenman hızlı ve klavyesiz girilir hâle geldi; ama uygulama hâlâ yalnızca kaydediyor, yol göstermiyor. Odak modu değerleri geçen seferden aynen dolduruyor; kullanıcı ilerlemek için ne yapacağını kendisi hesaplıyor, kırdığı rekoru fark etmiyor, dinlenirken boş bir ekrana bakıyor.

Kullanıcı (kendisi) bodybuilding'den calisthenics + fonksiyonele geçti. Antrenmanı hedefe göre seçiyor: "amuda kalkmak istiyorum, bunun için dips, şınav gibi itiş ve omuz hareketlerinde ustalaşmam gerek." Bu yüzden ilerleme çoğu harekette kilodan değil **tekrar ve süreden** gelir. "Akıllı ağırlık önerisi" fikri bu gerçeğe göre genişletildi.

Hedefe göre hareket seçimi ("amuda kalkma için bu hafta pike şınav, duvara amut") ayrı bir yardım türüdür ve Aşama 4'e (amaca duyarlı içerik) kalır. Kullanıcı "sırayla gidelim" dedi.

## Kapsam

- **Hareket içi öneri:** odak modunda o anki setin değeri, geçmişe göre bir adım ileri önerilir.
- **Rekor kutlaması:** set tamamlanınca kişisel rekor kırıldıysa kutlanır; özette listelenir.
- **Dinlenmede motivasyon satırı:** dinlenme ekranında ayrılmış boş yere tek bir olumlu karşılaştırma.

## Hedefler

1. Odak modunda değerler "geçen seferin aynısı" değil, "bugün denemen gereken" olarak dolu gelir; kabul etmek için ek dokunuş gerekmez.
2. Önerinin nedeni her zaman görünür (sayı kendiliğinden değişmiş gibi durmaz).
3. Kişisel rekor kırıldığı an fark edilir, ama antrenmanın akışı bölünmez.
4. Dinlenme ekranı kullanıcıya "ilerliyorsun" duygusu verir; asla moral bozmaz.
5. Her şey internetsiz, ücretsiz, kurallarla çalışır (YZ koçu sonraki aşama; mimari ona kapı bırakır).

## Hedef dışı

- Hedefe göre hareket seçimi ve "bu hareket amacına şöyle faydalı" metinleri (Aşama 4).
- Ek ağırlıklı vücut ağırlığı, ilerleme basamakları (ör. duvara amut → serbest amut), yeni calisthenics hareketleri (2c). 2b mevcut takip tiplerini (`weight_reps`, `reps`, `duration`) kullanır.
- Geçmiş grafikleri, kilo takibi.
- Liderlik tablosu, rekorların başkalarıyla paylaşılması.
- Sunucu şeması değişikliği.

## Anti-hedefler (çalışsa bile başarısızlık)

- Motivasyon satırının olumsuz/suçlayıcı olması ("geçen haftadan azsın").
- Uzun aradan sonra dönen kullanıcıya artış önermek (sakatlık riski).
- Önerinin açıklamasız değişmesi; kullanıcının "bu sayı nereden çıktı" demesi.
- Kutlamanın antrenmanı bölmesi: tam ekran konfeti, kapatılması gereken pencere, ekstra dokunuş.
- Odak modunda klavye açılması (2a anti-hedefi aynen geçerli).

## Yaklaşımlar (nasıl kurulacağı; Claude seçti, kullanıcı itiraz etmedi)

1. **Her seferinde geçmişten hesaplama (seçilen).** Öneri, rekor ve motivasyon telefondaki `workout_sessions`/`session_sets` geçmişinden anlık hesaplanır. Kurallar `lib/domain` altında saf Dart.
   - Artısı: sunucu değişmez; set düzeltilir/silinirse rekor kendiliğinden doğru kalır; test edilebilir.
   - Eksisi: her hareket için geçmiş taranır. Kullanıcının veri boyutunda milisaniyeler; sorun değil.
2. **Rekorları sunucuda ayrı tabloda tutmak.** Hızlı okuma, ileride liderlik tablosu. Ama aynı bilginin ikinci kopyası; set düzeltme/silmede bozulabilir; migration + senkron işi. Liderlik tablosu yalnızca uygulama yayınlanırsa gelecek. Elendi.
3. **Yalnızca telefonda türetilmiş önbellek tablosu.** Küçük hız kazancı, güncel tutma yükü. Şu an gereksiz. Elendi.

## Kararlar

### Öneri kuralı (Claude önerdi, kullanıcı onayladı)

Tanımlar: "geçen seans" = hareketin son tamamlanmış antrenmandaki setleri; "önceki seans" = ondan bir önceki. "Tutturdu" = geçen seansta her setin değeri, önceki seansın aynı sıradaki setinden düşük değil (önceki seans yoksa tutturmuş sayılır; geçen seansta önceki seanstan daha az set yapıldıysa tutturmamış sayılır).
- `weight_reps` için "düşük değil" = **hem ağırlık hem tekrar** düşük değil (Claude'un kararı; klasik çift ilerleme). Örn. 60×8'den 62,5×6'ya geçildiyse tekrar düştüğü için tutturmamış sayılır; sonraki öneri 62,5×7 olur. Böylece ağırlık arka arkaya artmaz (anti-hedef: sakatlık riski).

- **Yalnızca tekrar (`reps`; dips, barfiks, şınav):** tutturduysa her set için geçen seansın aynı sıradaki tekrarı **+1**; tutturmadıysa aynısı.
- **Süre (`duration`; plank, amutta durma):** aynı mantık, artış **+5 sn**.
- **Ağırlık + tekrar (`weight_reps`):** tutturduysa ağırlık **ekipmanın en küçük adımı** kadar artar (mevcut `weightStep`, kullanıcının biriminde), tekrar aynı kalır. Tutturmadıysa aynı ağırlıkla **+1 tekrar**.
  - Vücut ağırlığı ekipmanlı (`bodyweight`) `weight_reps` hareketlerinde ağırlık alanı yoktur; yalnızca tekrar kuralı uygulanır.
- **Temkin:** hareket **21 günden** uzun süredir yapılmadıysa artış önerilmez; geçen seansın değerleri aynen verilir.
- **2. ve sonraki setler (Claude'un kararı):** öneri geçen seansın aynı sıradaki setinden hesaplanır. Ama kullanıcı bugün bir önceki sette o setin önerisinin **altında** kaldıysa (ör. öneri 9, yaptığı 7), sonraki setlere bugünkü bir önceki setin değeri gelir (2a `prefill` davranışı): zorlandığı gün itilmez. Neden satırı o sette yalnızca `Geçen sefer: …` gösterir.
- Geçen seansta olmayan sıradaki setler (bugün daha fazla set yapılıyorsa): bugünkü bir önceki setin değeri kullanılır (2a davranışı).
- İlk kez yapılan hareket: öneri yok, alanlar boş (2a davranışı).
- Öneri yalnızca alanlar ilk dolarken uygulanır. Kullanıcı –/+ ile ya da yazarak değiştirdiyse taslak korunur (2a `FocusDraft` kuralı), öneri üstüne yazılmaz.

### Önerinin görünümü (kullanıcı onayladı; "kutuya dolu gelsin" Claude'un önerisi, kullanıcı kabul etti)

- Önerilen değer kutuya dolu gelir. Kabul için dokunmak gerekmez; –/+ ve değere dokunarak yazma aynen çalışır.
- Kutunun altında (mevcut "Geçen sefer" şeridinin yerinde) neden satırı: `Geçen sefer 8 · bugün 9 dene`. Artış yoksa yalnızca `Geçen sefer: …` (bugünkü gibi). Temkin devredeyse `Bir süredir yapmadın · geçen seferki gibi`.

```
  DIPS                         2/4
  ┌──────────────────────────────┐
  │  Tekrar      [ – ]  9  [ + ] │
  └──────────────────────────────┘
  ↑ Geçen sefer 8 · bugün 9 dene
  ● ● ○ ○  SET 1/4
        [ Seti tamamla ]
```

### Rekor

- Hareket türüne göre ölçü:
  - `reps`: tek sette en çok tekrar.
  - `duration`: en uzun süre.
  - `weight_reps` (ağırlıklı): en ağır ağırlık (en az 1 tekrar). Vücut ağırlığı ekipmanlıda tek sette en çok tekrar.
- Rekor, o hareketin **önceki tüm tamamlanmış setlerine** göre kırılır (bugünkü önceki setler dahil; aynı antrenmanda art arda kırılabilir).
- Hareketin ilk kez yapıldığı antrenmanda kutlama yok (kırılacak ölçü yok).
- Yalnızca kesin büyüklük sayılır (eşitlemek rekor değil).
- Kutlama yalnızca **Seti tamamla** ile tetiklenir (Claude'un kararı). Geçmiş bir seti düzenleyip yükseltmek kutlama göstermez (dinlenme ekranı yok); ama özetteki rekor listesine girer.
- Set geri alınır ya da düzenlenip rekor altına düşerse kutlama geri çekilmez (an geçti), ama özetteki rekor listesi kaydedilmiş verilere göre yeniden hesaplanır.

### Kutlamanın görünümü

- Set tamamlanınca açılan dinlenme ekranının üstünde: `YENİ REKOR · Dips 12 tekrar`.
- Telefon dinlenme bitişinden farklı, kısa bir titreşimle titrer. Reduce motion açıksa titreşim kalır, animasyon yok.
- Mono: yazı nokta-matris, bir kez yanıp söner. Canlı: vurgu renginde kısa parlama.
- Konfeti, tam ekran ya da kapatılması gereken pencere yok.
- Özet ekranında "Rekorlar" bölümü: o antrenmanda kırılan rekorlar (hareket, yeni değer, eski değer).

### Dinlenmede motivasyon satırı

- Dinlenme ekranındaki ayrılmış yerde (`rest-motivation`) tek satır. Aday karşılaştırmalar öncelik sırasıyla; ilk uygun olan gösterilir:
  1. **Hareket, bu hafta / geçen hafta:** o hareketin bu haftaki toplamı geçen haftayı geçtiyse. Toplam (Claude'un kararı): `reps` → toplam tekrar; `duration` → toplam süre; `weight_reps` → hacim (kg × tekrar, kullanıcının biriminde; vücut ağırlığı ekipmanlıda toplam tekrar). Örn: `Dips'te bu hafta 27 tekrar, geçen hafta 24.`
  2. **Bölge, bu hafta / geçen hafta:** hareketin ana bölgesinin set sayısı geçen haftayı geçtiyse. Bölge = maketteki/Antrenman sekmesindeki **üst bölgeler** (göğüs, sırt, omuz, kol, karın, bacak; `BodyRegion`). Set sayımı Antrenman sekmesiyle **aynı** kuralla yapılır (`muscle_coverage`: yardımcı kas 0,5 set), sayılar ekranlar arasında tutarlı olsun (Claude'un kararı; itiş/çekiş gruplaması 2b'de yok). Örn: `Bu hafta omuz: 11 set, geçen hafta 6.` Kullanıcının hedefleri (`goal_moves`) arasında bu bölgeyle ilişkili olan varsa kısa ek: `· amut hedefin için`.
  3. **Süreklilik:** art arda en az 2 hafta antrenman yapıldıysa. Örn: `3 haftadır her hafta antrenmandasın.`
- Hiçbiri uygun değilse satır boş kalır. Olumsuz karşılaştırma hiç gösterilmez.
- Hafta sınırı profildeki `week_starts_on` ile belirlenir (mevcut hafta kuralı).
- Aynı dinlenme boyunca satır değişmez.

## Kısıtlar

- Sunucu şeması değişmez; mevcut tablolar yeterli.
- Kurallar saf Dart, `lib/domain` altında, birim testli. UI katmanı veri katmanını doğrudan içe aktarmaz (mevcut kural).
- Odak modu ve dinlenme ekranının 2a davranışları (klavyesiz, tek dokunuş, kilit ekranı sayacı) bozulmaz.
- Metinler Türkçe; sayılar Türkçe biçimde (`102,5`, `1.500`).
- Kilo birimi lb ise öneri ve rekor kullanıcının biriminde gösterilir; saklama kg.

## İnşa edene kalanlar

- Sorguların konumu (`workout_queries.dart` genişletilir mi, ayrı sorgu sınıfı mı) ve önbellekleme (provider ömrü).
- Titreşim deseninin tam değeri ve kutlama animasyonunun süresi (Mono/Canlı dilinde).
- Motivasyon satırında hareketten bölgeye ve bölgeden hedef hareketlere eşleme: mevcut `muscle_groups` üst bölgeleri ve `training_style.dart` hedef anahtarları kullanılır; eşleme tablosu inşa edende.
- Özet ekranında "Rekorlar" bölümünün yeri (istatistik kartı ile maket arası önerilir).

## Açık not

2026-11-20'de kullanıcı bir antrenmanı bitirince özet ekranına geçişte donma (ANR) yaşadı (Mono tema, 2 hareket, 6 set, ~8 dk); Claude iki denemede yeniden üretemedi. Bir sonraki donmada uygulamaya hata ayıklayıcıyla bağlanılıp yığın alınacak.
Plan sırası (Claude'un kararı): odak modu önerisi, rekor tespiti/kutlaması ve dinlenme motivasyonu önce yapılabilir. Özet ekranındaki "Rekorlar" bölümü, donmanın nedeni bulunana kadar en son aşamaya bırakılır.
