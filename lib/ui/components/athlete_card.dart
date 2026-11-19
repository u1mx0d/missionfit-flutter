import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../domain/member_since.dart';
import '../../domain/username.dart';
import '../theme/mf_theme.dart';
import 'dot_grid.dart';
import 'mf_avatar.dart';
import 'mf_logo.dart';

/// Sporcu kartının hangi aşamada olduğu.
enum AthleteCardMode { empty, filling, awaitingCode, active, saved, sample }

/// Kartta gösterilen alanlar; hepsi isteğe bağlı.
class AthleteCardData {
  const AthleteCardData({
    this.displayName,
    this.username,
    this.email,
    this.avatarUrl,
    this.avatarBytes,
    this.memberSince,
    this.passwordOk = false,
  });
  final String? displayName;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final DateTime? memberSince;
  final bool passwordOk;
}

const _placeholder = '····';

String? _nonEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

/// Kart üstündeki soluk yazı rengi. Canlı degradenin üst bandında `textMuted` bazı
/// vurgularda 4.5:1'in altında kalır; asıl yazıya biraz yaklaştırılır.
Color athleteCardMutedColor(MfTheme t) => Color.lerp(t.textMuted, t.text, 0.35)!;

/// Giriş/kayıt ekranlarının "sporcu kimliği" kartı. Salt sunum: gezinme ve sağlayıcı yok.
class AthleteCard extends StatelessWidget {
  const AthleteCard({
    required this.mode,
    this.data = const AthleteCardData(),
    this.onAvatarTap,
    this.onRemove,
    super.key,
  });
  final AthleteCardMode mode;
  final AthleteCardData data;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onRemove;

  String? get _stamp => switch (mode) {
    AthleteCardMode.awaitingCode => 'KOD BEKLENİYOR',
    AthleteCardMode.active => 'AKTİF',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final noAnim = MediaQuery.of(context).disableAnimations;
    final fade = noAnim ? Duration.zero : const Duration(milliseconds: 200);

    final name = _nonEmpty(data.displayName);
    final user = _nonEmpty(data.username);
    final email = _nonEmpty(data.email);
    final userLine = user == null ? null : '@$user';

    final String? title;
    final String? subtitle;
    if (mode == AthleteCardMode.sample) {
      title = 'MissionFit sporcusu';
      subtitle = null;
    } else {
      // Form aşamalarında e-posta kendi satırında gösterilir; başlıkta tekrarlanmaz.
      final formMode =
          mode == AthleteCardMode.empty ||
          mode == AthleteCardMode.filling ||
          mode == AthleteCardMode.awaitingCode;
      title = name ?? userLine ?? (formMode ? null : email);
      subtitle = name != null ? userLine : null;
    }
    // Ay, kullanıcının yerel saatine göre gösterilir (UTC gece yarısı kayması olmasın).
    final since = data.memberSince == null ? null : formatMemberSince(data.memberSince!.toLocal());
    final muted = athleteCardMutedColor(t);
    final hasIdentity =
        data.avatarBytes != null ||
        _nonEmpty(data.avatarUrl) != null ||
        name != null ||
        user != null;

    Widget switcher(String text, TextStyle style, {Key? key}) => AnimatedSwitcher(
      duration: fade,
      layoutBuilder: (current, previous) =>
          Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
      child: Text(
        text,
        key: ValueKey('${key ?? ''}$text'),
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final titleStyle = TextStyle(
      color: title == null ? muted : t.text,
      fontFamily: t.displayFont,
      fontWeight: FontWeight.w700,
      fontSize: 22,
    );
    final smallStyle = TextStyle(color: muted, fontSize: 14);

    Widget avatar = SizedBox.square(
      dimension: 64,
      child: hasIdentity
          ? MfAvatar(
              bytes: data.avatarBytes,
              url: _nonEmpty(data.avatarUrl),
              initials: initialsFor(displayName: name, username: user),
              size: 64,
            )
          : Center(child: MfLogo(size: 56)),
    );
    if (onAvatarTap != null) {
      avatar = Semantics(
        button: true,
        label: 'Fotoğrafı değiştir',
        onTap: onAvatarTap,
        excludeSemantics: true,
        child: InkResponse(
          key: const Key('athlete-card-avatar'),
          onTap: onAvatarTap,
          radius: 36,
          child: avatar,
        ),
      );
    }

    final stamp = _stamp;
    final border = t.cardStyle == CardStyle.flat ? Border.all(color: t.border) : null;
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(t.radius),
      border: border,
      color: t.cardStyle == CardStyle.flat || t.gradientTop == null ? t.surface : null,
      gradient: t.cardStyle == CardStyle.flat || t.gradientTop == null
          ? null
          : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [t.gradientTop!, t.surface],
            ),
    );

    return DecoratedBox(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(t.radius),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: DotGridPainter(color: t.dot.withValues(alpha: 0.5))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'SPORCU KİMLİĞİ',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (onRemove != null)
                        IconButton(
                          key: const Key('athlete-card-remove'),
                          tooltip: 'Bu telefondan kaldır',
                          onPressed: onRemove,
                          icon: Icon(Icons.close, color: t.textMuted, size: 20),
                        )
                      else
                        const SizedBox(height: 48),
                    ],
                  ),
                  Row(
                    children: [
                      avatar,
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (mode == AthleteCardMode.saved) ...[
                              Text('Tekrar hoş geldin', style: smallStyle),
                              const SizedBox(height: 2),
                            ],
                            switcher(title ?? _placeholder, titleStyle),
                            if (subtitle != null) switcher(subtitle, smallStyle),
                            if (since != null) switcher(since, smallStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (mode == AthleteCardMode.empty ||
                      mode == AthleteCardMode.filling ||
                      mode == AthleteCardMode.awaitingCode) ...[
                    const SizedBox(height: 14),
                    switcher(
                      email ?? _placeholder,
                      smallStyle.copyWith(color: email == null ? muted : t.text),
                      key: const Key('email'),
                    ),
                    if (data.passwordOk) ...[
                      const SizedBox(height: 4),
                      Text('✓ Şifre', style: TextStyle(color: t.text, fontSize: 14)),
                    ],
                  ],
                  if (stamp != null) ...[
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _Stamp(
                        key: ValueKey(stamp),
                        label: stamp,
                        color: mode == AthleteCardMode.active ? t.success : t.accent,
                        textColor: t.text,
                        animate: !noAnim,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mühür: girişte büyükten yerine oturur ve hafif döner.
class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.label,
    required this.color,
    required this.textColor,
    required this.animate,
    super.key,
  });
  final String label;
  final Color color;
  final Color textColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 1.4,
        ),
      ),
    );
    const angle = -0.1;
    if (!animate) return Transform.rotate(angle: angle, child: box);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.rotate(
        angle: angle * v,
        child: Transform.scale(
          scale: 1.6 - 0.6 * v,
          child: Opacity(opacity: v.clamp(0, 1), child: child),
        ),
      ),
      child: box,
    );
  }
}
