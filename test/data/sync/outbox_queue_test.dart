import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:missionfit/data/sync/outbox_queue.dart';

OutboxOp op(String opId, String key, [String type = 'x.upsert']) =>
    OutboxOp(opId: opId, key: key, type: type, payload: const {}, attempts: 0, createdAt: 0);

void main() {
  group('enqueue', () {
    test('farklı key: sona eklenir', () {
      final q = enqueue(enqueue([], op('1', 'a')), op('2', 'b'));
      expect(q.map((o) => o.opId).toList(), ['1', '2']);
    });

    test('aynı key: yerini alır, sıra korunur, deneme sıfırlanır', () {
      var q = enqueue([], op('1', 'a'));
      q = enqueue(q, op('2', 'b'));
      q = bumpAttempts(q, '1');
      q = enqueue(q, op('3', 'a', 'x.delete'));
      expect(q.map((o) => [o.opId, o.type, o.attempts]).toList(), [
        ['3', 'x.delete', 0],
        ['2', 'x.upsert', 0],
      ]);
    });

    test("removeOp yalnızca o işlemi çıkarır (aynı key'in yeni işlemi kalır)", () {
      var q = enqueue([], op('1', 'a'));
      final sent = q[0];
      q = enqueue(q, op('2', 'a'));
      expect(removeOp(q, sent.opId).map((o) => o.opId).toList(), ['2']);
    });
  });

  group('isPermanentError', () {
    test('kısıt, RLS ve veri hataları kalıcı', () {
      expect(isPermanentError({'code': '23514'}), true);
      expect(isPermanentError({'code': '42501'}), true);
      expect(isPermanentError({'code': '22P02'}), true);
    });

    test('ağ, JWT ve bilinmeyen hatalar geçici', () {
      expect(isPermanentError({'code': '', 'message': 'TypeError: Network request failed'}), false);
      expect(isPermanentError({'code': 'PGRST301'}), false);
      expect(isPermanentError(Exception('x')), false);
      expect(isPermanentError(null), false);
    });

    test('PostgrestException.code okunur', () {
      expect(isPermanentError(const PostgrestException(message: 'm', code: '23505')), true);
      expect(isPermanentError(const PostgrestException(message: 'm', code: 'PGRST301')), false);
    });
  });

  group('retryDelay', () {
    test('artan bekleme, en çok 60 sn', () {
      expect([0, 1, 2, 3, 4, 10].map(retryDelay).map((d) => d.inMilliseconds).toList(), [
        5000,
        5000,
        15000,
        30000,
        60000,
        60000,
      ]);
    });
  });
}
