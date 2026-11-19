const _aylar = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

/// Sporcu kartındaki üyelik satırı, ör. "Üye: Kasım 2026".
String formatMemberSince(DateTime d) => 'Üye: ${_aylar[d.month - 1]} ${d.year}';
