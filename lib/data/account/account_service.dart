import 'package:supabase_flutter/supabase_flutter.dart';

import '../db/database.dart';
import '../export/export_service.dart' show isNetworkFailure;

enum DeleteAccountFailure { reauthenticationRequired, unauthorized, failed, network }

/// Hesap silme hatası; [message] doğrudan arayüzde gösterilir.
class DeleteAccountError implements Exception {
  const DeleteAccountError(this.failure);
  final DeleteAccountFailure failure;

  String get message => switch (failure) {
    DeleteAccountFailure.reauthenticationRequired =>
      'Güvenlik için kimliğini yeniden doğrulaman gerekiyor. Lütfen tekrar dene.',
    DeleteAccountFailure.unauthorized =>
      'Oturumun doğrulanamadı. Çıkış yapıp tekrar giriş yaptıktan sonra dene.',
    DeleteAccountFailure.network =>
      'Sunucuya ulaşılamadı. İnternet bağlantını kontrol edip tekrar dene.',
    DeleteAccountFailure.failed => 'Hesabın şu an silinemedi. Lütfen daha sonra tekrar dene.',
  };

  @override
  String toString() => message;
}

abstract interface class AccountService {
  /// Sunucudaki hesabı ve tüm veriyi siler, ardından yerel kullanıcı verisini temizler.
  /// Oturumu kapatmak çağıranın işidir (kullanıcı sunucuda artık yok; yalnızca yerel çıkış).
  Future<void> deleteAccount();
}

class SupabaseAccountService implements AccountService {
  SupabaseAccountService(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;

  @override
  Future<void> deleteAccount() async {
    try {
      await _client.functions.invoke('delete-account', method: HttpMethod.post);
    } on FunctionException catch (e) {
      throw DeleteAccountError(switch (e.status) {
        403 => DeleteAccountFailure.reauthenticationRequired,
        401 => DeleteAccountFailure.unauthorized,
        _ => DeleteAccountFailure.failed,
      });
    } catch (e) {
      if (isNetworkFailure(e)) throw const DeleteAccountError(DeleteAccountFailure.network);
      rethrow;
    }
    await _db.clearAllUserData();
  }
}
