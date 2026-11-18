import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/profile_controller.dart';
import '../../app/providers.dart';
import '../components/dot_grid.dart';
import '../components/mf_card.dart';

/// Başlıklı kart bölümü.
class ProfileSection extends StatelessWidget {
  const ProfileSection({required this.title, required this.children, super.key});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: t.displayFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
            ),
          ),
          MfCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ],
      ),
    );
  }
}

/// Dokunulabilir ayar satırı: simge, başlık, alt başlık, sağda değer ve ok.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.danger = false,
    this.loading = false,
    super.key,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool danger;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final color = danger ? t.danger : t.text;
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: danger ? t.danger : t.textMuted, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: color, fontWeight: FontWeight.w600),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(subtitle!, style: TextStyle(color: t.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Text(
                  value!,
                  style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
                ),
              ],
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (onTap != null)
                Icon(Icons.chevron_right, color: t.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alt sayfa çerçevesi: geri okuyla başlık çubuğu + kaydırılabilir içerik (klavye güvenli).
class SubPage extends StatelessWidget {
  const SubPage({required this.title, required this.children, super.key});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: t.text,
        title: Text(
          title,
          style: TextStyle(fontFamily: t.displayFont, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: children,
        ),
      ),
    );
  }
}

class InlineError extends StatelessWidget {
  const InlineError(this.message, {super.key});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message!,
          key: const Key('inline-error'),
          style: TextStyle(color: mf(context).danger, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

void showSnack(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

String profileSaveErrorMessage(Object e) {
  if (e is ProfileNotReadyException) return ProfileNotReadyException.message;
  return 'Ayar kaydedilemedi.';
}

/// Profili günceller; hata olursa kullanıcıya söyler. Başarıysa true.
Future<bool> saveProfile(
  BuildContext context,
  WidgetRef ref,
  Profile Function(Profile) change,
) async {
  try {
    await ref.read(profileUpdaterProvider)(change);
    return true;
  } catch (e) {
    if (context.mounted) showSnack(context, profileSaveErrorMessage(e));
    return false;
  }
}
