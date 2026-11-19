import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/profile_controller.dart';
import '../../app/providers.dart';
import '../../domain/username.dart';
import '../components/mf_avatar.dart';
import '../components/mf_button.dart';
import '../components/mf_text_field.dart';
import 'avatar_source_sheet.dart';
import 'profile_widgets.dart';
import 'username_field.dart';

const photoFailedMessage = 'Fotoğraf yüklenemedi, tekrar dene.';
const identityUnexpectedMessage = 'Bir şeyler ters gitti. Lütfen tekrar dene.';

/// Bekleyen fotoğraf değişikliği: yeni bayt, Google URL'si ya da kaldırma.
sealed class AvatarChange {
  const AvatarChange();
}

class AvatarBytes extends AvatarChange {
  const AvatarBytes(this.bytes);
  final Uint8List bytes;
}

class AvatarFromUrl extends AvatarChange {
  const AvatarFromUrl(this.url);
  final String url;
}

class AvatarRemoval extends AvatarChange {
  const AvatarRemoval();
}

/// Bekleyen değişikliği uygular. Arayüzden bağımsız olduğu için onboarding de kullanır.
Future<void> applyAvatarChange(
  ProfileIdentityRepository repo,
  String userId,
  AvatarChange change,
) => switch (change) {
  AvatarBytes(:final bytes) => repo.uploadAvatar(userId, bytes),
  AvatarFromUrl(:final url) => repo.uploadAvatarFromUrl(userId, url),
  AvatarRemoval() => repo.removeAvatar(userId),
};

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  AvatarChange? _avatar;
  bool _initialized = false;
  bool _busy = false;
  String? _nameError;
  String? _usernameError;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  void _init(Profile p) {
    if (_initialized) return;
    _initialized = true;
    final google = ref.read(googleProfileProvider);
    final name = p.displayName?.trim();
    _name.text = (name == null || name.isEmpty) ? (google?.name ?? '') : name;
    if (p.username != null) {
      _username.text = p.username!;
    } else if (google != null) {
      _username.text = usernameBase(
        fullName: google.name,
        email: ref.read(currentUserEmailProvider),
      );
    }
    // Google fotoğrafı yalnızca profil eksikken önerilir; kaldırılmış fotoğraf geri gelmez.
    final incomplete = p.username == null || name == null || name.isEmpty;
    if (incomplete && p.avatarPath == null && google?.photoUrl != null) {
      _avatar = AvatarFromUrl(googlePhotoAt512(google!.photoUrl!));
    }
  }

  Future<void> _pickAvatar(Profile p) async {
    final hasPhoto =
        _avatar is AvatarBytes ||
        _avatar is AvatarFromUrl ||
        (_avatar == null && p.avatarPath != null);
    final action = await showAvatarSourceSheet(context, canRemove: hasPhoto);
    if (action == null || !mounted) return;
    if (action == AvatarAction.remove) {
      setState(() => _avatar = p.avatarPath == null ? null : const AvatarRemoval());
      return;
    }
    final source = action == AvatarAction.camera ? AvatarSource.camera : AvatarSource.gallery;
    final Uint8List? bytes;
    try {
      bytes = await ref.read(avatarPickerProvider).pick(source);
    } catch (_) {
      if (mounted) setState(() => _error = 'Fotoğraf açılamadı.');
      return;
    }
    if (bytes == null || !mounted) return;
    setState(() {
      _avatar = AvatarBytes(bytes!);
      _error = null;
    });
  }

  Future<void> _save(Profile p) async {
    final name = _name.text.trim();
    final username = normalizeUsername(_username.text);
    setState(() {
      _nameError = validateDisplayName(name);
      _usernameError = validateUsername(username);
      _error = null;
    });
    if (_nameError != null || _usernameError != null) return;

    final userId = p.userId;
    final repo = ref.read(profileIdentityRepositoryProvider);
    final usernameChanged = username != p.username;
    final nameChanged = name != (p.displayName ?? '');
    final avatar = _avatar;
    setState(() => _busy = true);
    try {
      // 1. Kullanıcı adı: başarısızsa hiçbir şey kaydedilmez.
      if (usernameChanged) {
        try {
          await repo.setUsername(userId, username);
        } on IdentityError catch (e) {
          if (!mounted) return;
          setState(() {
            if (e.failure == IdentityFailure.usernameTaken ||
                e.failure == IdentityFailure.usernameInvalid) {
              _usernameError = e.message;
            } else {
              _error = e.message;
            }
          });
          return;
        }
      }
      // 2. Fotoğraf: çevrimdışıysa ve henüz bir şey kaydedilmediyse dur.
      var photoFailed = false;
      if (avatar != null) {
        try {
          await applyAvatarChange(repo, userId, avatar);
          if (mounted) setState(() => _avatar = null);
        } on IdentityError catch (e) {
          if (e.failure == IdentityFailure.offline && !usernameChanged) {
            if (mounted) setState(() => _error = e.message);
            return;
          }
          photoFailed = true;
        }
      }
      // 3. Görünen ad (outbox; çevrimdışı da çalışır).
      if (nameChanged) {
        if (!mounted) return;
        final ok = await saveProfile(context, ref, (q) => q.copyWith(displayName: name));
        if (!ok) return;
      }
      if (!mounted) return;
      if (photoFailed) {
        setState(() => _error = photoFailedMessage);
        return;
      }
      if (context.canPop()) context.pop();
    } catch (e) {
      // Eşlenmemiş sunucu/auth hatası: sessizce yutulmasın.
      debugPrint('Profil kaydedilemedi: $e');
      if (mounted) setState(() => _error = identityUnexpectedMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(profileProvider).value;
    if (p == null) {
      return const SubPage(title: 'Profili düzenle', children: [LinearProgressIndicator()]);
    }
    _init(p);
    final repo = ref.read(profileIdentityRepositoryProvider);
    final avatar = _avatar;
    final preview = switch (avatar) {
      AvatarBytes(:final bytes) => (bytes: bytes, url: null),
      AvatarFromUrl(:final url) => (bytes: null, url: url),
      AvatarRemoval() => (bytes: null, url: null),
      null => (bytes: null, url: p.avatarPath == null ? null : repo.publicUrl(p.avatarPath!)),
    };
    return SubPage(
      title: 'Profili düzenle',
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                key: const Key('edit-avatar'),
                onTap: _busy ? null : () => _pickAvatar(p),
                child: MfAvatar(
                  bytes: preview.bytes,
                  url: preview.url,
                  size: 104,
                  initials: initialsFor(
                    displayName: _name.text,
                    username: _username.text.isEmpty ? null : _username.text,
                  ),
                ),
              ),
              TextButton(
                onPressed: _busy ? null : () => _pickAvatar(p),
                child: const Text('Fotoğrafı değiştir'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        MfTextField(
          key: const Key('display-name'),
          label: 'Görünen ad',
          controller: _name,
          errorText: _nameError,
          enabled: !_busy,
          onChanged: (_) => setState(() => _nameError = null),
        ),
        const SizedBox(height: 12),
        UsernameField(
          key: const Key('username'),
          controller: _username,
          ownUsername: p.username,
          errorText: _usernameError,
          enabled: !_busy,
          onStatus: (_) {
            if (_usernameError != null) setState(() => _usernameError = null);
          },
        ),
        InlineError(_error),
        const SizedBox(height: 16),
        MfButton(label: 'Kaydet', loading: _busy, onPressed: _busy ? null : () => _save(p)),
      ],
    );
  }
}
