import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import 'dot_grid.dart';

/// Profil fotoğrafı: önce yerel bayt (seçilmiş, henüz yüklenmemiş), sonra URL (önbellekli),
/// yoksa ya da yüklenemezse vurgu renginde baş harfler.
class MfAvatar extends StatelessWidget {
  const MfAvatar({this.bytes, this.url, required this.initials, this.size = 72, super.key});
  final Uint8List? bytes;
  final String? url;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final fallback = Container(
      key: const Key('avatar-initials'),
      color: t.accent,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: t.onAccent,
          fontFamily: t.displayFont,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
    final Widget image;
    if (bytes != null) {
      image = Image.memory(
        bytes!,
        key: const Key('avatar-bytes'),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    } else if (url != null) {
      image = CachedNetworkImage(
        key: const Key('avatar-url'),
        imageUrl: url!,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      );
    } else {
      image = fallback;
    }
    return Semantics(
      label: 'Profil fotoğrafı',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(child: image),
      ),
    );
  }
}
