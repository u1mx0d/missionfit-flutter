import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/turkish_text.dart';

void main() {
  test('İ/I/ı/i aynı anahtar', () {
    expect(turkishKey('İSTANBUL'), turkishKey('istanbul'));
    expect(turkishKey('ISPARTA'), turkishKey('ısparta'));
    expect(turkishKey('Işık'), turkishKey('işik'));
  });

  test('Ş Ç Ğ Ö Ü büyük/küçük ve aksansız eşleşir', () {
    expect(turkishKey('ŞINAV'), turkishKey('şınav'));
    expect(turkishKey('Çömelme'), turkishKey('çömelme'));
    expect(turkishKey('ĞÖÜ'), 'gou');
    expect(turkishKey('öğüş'), 'ogus');
  });

  test('baştaki/sondaki boşluk atılır', () {
    expect(turkishKey('  Şınav '), 'sinav');
  });
}
