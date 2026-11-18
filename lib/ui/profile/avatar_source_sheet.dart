import 'package:material_ui/material_ui.dart';

enum AvatarAction { gallery, camera, remove }

/// Fotoğraf kaynağı seçimi; vazgeçilirse null.
Future<AvatarAction?> showAvatarSourceSheet(BuildContext context, {required bool canRemove}) =>
    showModalBottomSheet<AvatarAction>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden seç'),
              onTap: () => Navigator.of(ctx).pop(AvatarAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Fotoğraf çek'),
              onTap: () => Navigator.of(ctx).pop(AvatarAction.camera),
            ),
            if (canRemove)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Fotoğrafı kaldır'),
                onTap: () => Navigator.of(ctx).pop(AvatarAction.remove),
              ),
          ],
        ),
      ),
    );
