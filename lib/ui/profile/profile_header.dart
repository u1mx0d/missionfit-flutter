import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/profile_controller.dart';
import '../../app/providers.dart';
import '../../domain/username.dart';
import '../components/dot_grid.dart';
import '../components/mf_avatar.dart';
import '../components/mf_button.dart';

/// Profil ekranının üstü: fotoğraf, görünen ad, `@kullaniciadi`; eksikse "Profilini tamamla".
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = mf(context);
    final p = ref.watch(profileProvider).value;
    final name = p?.displayName?.trim();
    final hasName = name != null && name.isNotEmpty;
    final username = p?.username;
    final title = hasName ? name : (username != null ? '@$username' : 'Profil');
    final avatarPath = p?.avatarPath;
    final url = avatarPath == null
        ? null
        : ref.read(profileIdentityRepositoryProvider).publicUrl(avatarPath);
    void edit() => context.push('/profil/duzenle');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: p == null ? null : edit,
              child: MfAvatar(
                url: url,
                initials: initialsFor(displayName: name, username: username),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      key: const Key('profile-title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontFamily: t.displayFont, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (hasName && username != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '@$username',
                        key: const Key('profile-username'),
                        style: TextStyle(color: t.textMuted),
                      ),
                    ),
                ],
              ),
            ),
            if (p != null && hasName && username != null)
              IconButton(
                tooltip: 'Profili düzenle',
                icon: const Icon(Icons.edit_outlined),
                onPressed: edit,
              ),
          ],
        ),
        if (p != null && (!hasName || username == null))
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: MfButton(
              key: const Key('complete-profile'),
              label: 'Profilini tamamla',
              secondary: true,
              onPressed: edit,
            ),
          ),
      ],
    );
  }
}
