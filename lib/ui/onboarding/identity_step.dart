import 'package:material_ui/material_ui.dart';

import '../../domain/username.dart';
import '../components/athlete_card.dart';
import '../components/mf_text_field.dart';
import '../profile/edit_profile_screen.dart' show AvatarBytes, AvatarChange, AvatarFromUrl;
import '../profile/username_field.dart';
import 'onboarding_widgets.dart';

/// "Profilin": görünen ad ve kullanıcı adı zorunlu, fotoğraf isteğe bağlı.
class IdentityStep extends StatelessWidget {
  const IdentityStep({
    required this.displayName,
    required this.username,
    required this.avatar,
    required this.onPickAvatar,
    required this.onChanged,
    required this.errors,
    this.email,
    this.ownUsername,
    this.enabled = true,
    super.key,
  });
  final TextEditingController displayName;
  final TextEditingController username;
  final AvatarChange? avatar;
  final VoidCallback onPickAvatar;
  final VoidCallback onChanged;
  final Map<String, String> errors;

  /// Kartta gösterilen e-posta (oturumdan).
  final String? email;

  /// Bu oturumda zaten alınmış ad; ona dönülürse sunucuya sorulmaz.
  final String? ownUsername;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final a = avatar;
    final handle = normalizeUsername(username.text);
    return StepShell(
      title: 'Profilin',
      subtitle: 'Seni nasıl görelim? Fotoğraf isteğe bağlı, sonra da ekleyebilirsin.',
      children: [
        Center(
          child: Column(
            children: [
              AthleteCard(
                mode: AthleteCardMode.active,
                data: AthleteCardData(
                  displayName: displayName.text,
                  username: handle.isEmpty ? null : handle,
                  email: email,
                  avatarUrl: a is AvatarFromUrl ? a.url : null,
                  avatarBytes: a is AvatarBytes ? a.bytes : null,
                ),
                onAvatarTap: enabled ? onPickAvatar : null,
              ),
              TextButton(
                onPressed: enabled ? onPickAvatar : null,
                child: Text(a == null ? 'Fotoğraf ekle' : 'Fotoğrafı değiştir'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        MfTextField(
          key: const Key('display-name'),
          label: 'Görünen ad',
          controller: displayName,
          errorText: errors['displayName'],
          enabled: enabled,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        UsernameField(
          key: const Key('username'),
          controller: username,
          ownUsername: ownUsername,
          errorText: errors['username'],
          enabled: enabled,
          onStatus: (_) => onChanged(),
        ),
        StepError(errors['identity']),
      ],
    );
  }
}
