import 'dart:typed_data';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

enum AvatarSource { gallery, camera }

abstract interface class AvatarPicker {
  /// İptal edilirse null.
  Future<Uint8List?> pick(AvatarSource source);
}

class DeviceAvatarPicker implements AvatarPicker {
  @override
  Future<Uint8List?> pick(AvatarSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source == AvatarSource.camera ? ImageSource.camera : ImageSource.gallery,
    );
    if (picked == null) return null;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 512,
      maxHeight: 512,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
    );
    if (cropped == null) return null;
    return cropped.readAsBytes();
  }
}
