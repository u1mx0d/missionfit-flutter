import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/member_since.dart';

void main() {
  test('Türkçe ay adıyla biçimlenir', () {
    expect(formatMemberSince(DateTime(2026, 11, 2)), 'Üye: Kasım 2026');
    expect(formatMemberSince(DateTime(2027, 1, 31)), 'Üye: Ocak 2027');
  });
}
