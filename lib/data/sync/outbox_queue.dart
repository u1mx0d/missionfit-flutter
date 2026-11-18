import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

/// Çevrimdışı yazma kuyruğunun saf kısmı (`outboxQueue.ts` karşılığı).
///
/// Her işlem bir `key` taşır (ör. `food_entries:<uuid>`). Aynı key'e yeni işlem gelirse eskisinin
/// yerine geçer ve kuyruktaki sırası korunur; böylece bağımlılıklar bozulmaz.
/// İşlemler istemci uuid'si ile upsert edildiğinden tekrar göndermek güvenlidir.
class OutboxOp {
  const OutboxOp({
    required this.opId,
    required this.key,
    required this.type,
    required this.payload,
    required this.attempts,
    required this.createdAt,
  });

  /// Bu işlemin kendi kimliği (kuyruk içi).
  final String opId;

  /// Birleştirme anahtarı: aynı kaydı etkileyen işlemler aynı key'i taşır.
  final String key;

  /// `'<tablo>.upsert'` veya `'<tablo>.delete'`.
  final String type;
  final Map<String, Object?> payload;
  final int attempts;
  final int createdAt;

  OutboxOp copyWith({int? attempts}) => OutboxOp(
    opId: opId,
    key: key,
    type: type,
    payload: payload,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt,
  );
}

/// Bu kadar denemeden sonra işlem bırakılır (kalıcı bir sorun vardır).
const maxAttempts = 15;

List<OutboxOp> enqueue(List<OutboxOp> queue, OutboxOp op) {
  final index = queue.indexWhere((q) => q.key == op.key);
  if (index == -1) return [...queue, op];
  final next = [...queue];
  // Yeni işlem eskisinin yerini alır; deneme sayısı sıfırlanır (yeni içerik).
  next[index] = op.copyWith(attempts: 0);
  return next;
}

/// Başarıyla yazılan işlemi çıkarır; aynı key'e gelmiş daha yeni işleme dokunmaz.
List<OutboxOp> removeOp(List<OutboxOp> queue, String opId) =>
    queue.where((q) => q.opId != opId).toList();

List<OutboxOp> bumpAttempts(List<OutboxOp> queue, String opId) =>
    queue.map((q) => q.opId == opId ? q.copyWith(attempts: q.attempts + 1) : q).toList();

final _permanent = RegExp(r'^(22|23|42)[0-9A-Z]{3}$');

/// Hata kalıcı mı (tekrar denemek işe yaramaz)? SQLSTATE 22 = geçersiz veri, 23 = kısıt ihlali,
/// 42 = yetki/RLS veya sorgu hatası. Ağ, 5xx, süresi dolmuş JWT geçici sayılır.
bool isPermanentError(Object? error) {
  final Object? code;
  if (error is PostgrestException) {
    code = error.code;
  } else if (error is Map) {
    code = error['code'];
  } else {
    return false;
  }
  return code is String && _permanent.hasMatch(code);
}

/// Yeniden deneme beklemesi: 5 sn, 15 sn, 30 sn, sonra en çok 60 sn.
Duration retryDelay(int failures) {
  const steps = [5, 15, 30];
  if (failures <= 0) return Duration(seconds: steps[0]);
  return Duration(seconds: failures <= steps.length ? steps[failures - 1] : 60);
}
