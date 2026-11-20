import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/session_controller.dart';

const unsyncedTitle = 'Kaydedilmemiş değişiklikler var';
const unsyncedBody =
    'Son değişikliklerin henüz hesabına gönderilemedi. İnternet bağlantını kontrol edip '
    'tekrar dene. Şimdi çıkarsan bu değişiklikler kaybolur.';
const unsyncedConfirm = 'Yine de çık';

/// Çıkıştan önce bekleyen değişiklikleri göndermeyi dener. Hepsi gittiyse `true`;
/// kalan varsa uyarır ve yalnızca kullanıcı "Yine de çık" derse `true` döner.
Future<bool> flushOrConfirmSignOut(BuildContext context, WidgetRef ref) async {
  final left = await ref.read(signOutFlushProvider)();
  if (left == 0) return true;
  if (!context.mounted) return false;
  final yes = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(unsyncedTitle),
      content: const Text(unsyncedBody),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text(unsyncedConfirm),
        ),
      ],
    ),
  );
  return yes == true;
}
