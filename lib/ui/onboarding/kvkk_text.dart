/// Yasal metinler: RN `src/features/legal/texts.ts` ile aynı, TASLAKTIR.
/// Yayından önce bir hukukçuya (KVKK) kontrol ettir. Özellikle: veri sorumlusu bilgileri,
/// yurt dışına aktarım ve özel nitelikli kişisel veri (sağlık verisi) için açık rıza metni.
library;

const healthDisclaimer =
    'MissionFit tıbbi veya diyetisyen tavsiyesi vermez. Kalori hedefi ve yakılan kalori değerleri genel formüllere dayanan tahminlerdir. Bir sağlık sorunun, hamileliğin veya özel bir beslenme ihtiyacın varsa bir sağlık profesyoneline danış.';

/// 3B maket modelinin kaynağı (CC0; atıf zorunlu değil ama belirtilir).
const modelAttribution = '3B model: MakeHuman / MPFB (CC0)';

const kvkkTitle = 'KVKK Aydınlatma Metni';

/// Açık rıza onay kutusu metni (RN onboarding ile aynı).
const explicitConsentText =
    'Boy, kilo, yaş gibi sağlık verilerimin kalori hedefi ve takip amacıyla işlenmesine açık rıza veriyorum.';

class KvkkSection {
  const KvkkSection(this.heading, this.body);
  final String heading;
  final String body;
}

/// Bölüm bölüm aydınlatma metni (taslak).
const kvkkSections = <KvkkSection>[
  KvkkSection(
    'Veri sorumlusu',
    'MissionFit uygulamasını geliştiren bireysel geliştirici [AD SOYAD / İLETİŞİM ADRESİ — doldurulacak]. Başvuru için: [E-POSTA — doldurulacak].',
  ),
  KvkkSection(
    'İşlenen veriler',
    'Kimlik/iletişim: e-posta adresi. Sağlık verisi (özel nitelikli): boy, kilo, doğum yılı, cinsiyet, aktivite seviyesi, hedef, antrenman ve yemek kayıtları. Kullanım: görevler, uygulama tercihleri, saat dilimi. Doğum tarihinin tamamı yalnızca 18 yaş kontrolü için cihazda kullanılır, yalnızca doğum yılı saklanır.',
  ),
  KvkkSection(
    'İşleme amaçları',
    'Hesabını oluşturmak ve güvenliğini sağlamak; günlük kalori hedefini ve tahmini yakılan kaloriyi hesaplamak; antrenman, beslenme ve görev takibini sunmak; hatırlatma bildirimleri göndermek. Verilerin reklam, profilleme veya satış amacıyla kullanılmaz.',
  ),
  KvkkSection(
    'Hukuki sebep',
    'Hesap ve hizmetin sunulması için sözleşmenin ifası (KVKK m.5/2-c). Sağlık verilerin için açık rızan (KVKK m.6). Açık rızanı dilediğin zaman hesabını silerek geri alabilirsin.',
  ),
  KvkkSection(
    'Aktarım ve saklama',
    'Veriler, altyapı hizmet sağlayıcısı Supabase üzerinden Avrupa Birliği (Frankfurt, Almanya) bölgesindeki sunucularda saklanır; bu bir yurt dışı aktarımdır. Veriler hesabın açık olduğu sürece saklanır, hesap silindiğinde tüm kayıtlar kalıcı olarak silinir.',
  ),
  KvkkSection(
    'Hakların (KVKK m.11)',
    'Verilerinin işlenip işlenmediğini öğrenme, bilgi talep etme, düzeltilmesini veya silinmesini isteme, aktarıldığı üçüncü kişileri bilme, itiraz etme ve zararın giderilmesini talep etme haklarına sahipsin. Profil > Veri dışa aktarma ve Hesap silme seçenekleriyle verilerine ulaşabilir ve silebilirsin.',
  ),
];
