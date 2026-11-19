import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/known_accounts.dart';
import '../../app/profile_controller.dart';
import '../../app/providers.dart';
import '../auth/auth_scaffold.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';
import '../components/mf_card.dart';
import 'profile_widgets.dart';

const deleteConfirmWord = 'SİL';
const unexpectedErrorMessage = 'Bir şeyler ters gitti. Lütfen tekrar dene.';

const _deletedItems = [
  'Profil ve fiziksel bilgilerin',
  'Tüm antrenman oturumların ve setlerin',
  'Yemek kayıtların, kişisel yemeklerin ve favorilerin',
  'Görevlerin ve tamamlama geçmişin',
  'Giriş bilgilerin (e-posta ve şifre)',
];

/// Türkçe büyük/küçük harf farkını (İ/I) yok sayan karşılaştırma anahtarı.
String _key(String s) => s.trim().replaceAll('İ', 'i').replaceAll('I', 'i').toLowerCase();

/// Hesabı kalıcı siler: onay metni, yeniden doğrulama (şifre; şifre yoksa ya da seçilirse Google), sunucu fonksiyonu,
/// yerel temizlik, çıkış ve `/giris`.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirm = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  /// Şifre ve Google birlikteyse kullanıcı Google'ı seçebilir; varsayılan şifredir.
  bool _preferGoogle = false;

  @override
  void dispose() {
    _confirm.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Şifresi olan hesap şifreyle doğrulanır; yalnızca Google kimliği varsa ya da kullanıcı
  /// Google'ı seçtiyse Google ile.
  bool _usesPassword({required bool password, required bool google}) =>
      password && !(google && _preferGoogle);

  bool get _confirmed => _key(_confirm.text) == _key(deleteConfirmWord);

  Future<void> _run() async {
    if (_busy || !_confirmed) return;
    final hasPassword = _usesPassword(
      password: ref.read(hasPasswordIdentityProvider),
      google: ref.read(hasGoogleIdentityProvider),
    );
    final email = ref.read(currentUserEmailProvider);
    if (hasPassword && _password.text.isEmpty) {
      setState(() => _error = 'Devam etmek için şifreni yaz.');
      return;
    }
    if (hasPassword && email == null) {
      setState(() => _error = 'Oturum bilgisi alınamadı. Lütfen tekrar giriş yap.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final auth = ref.read(authRepositoryProvider);
    // Kök mesaj alanı: yanlış hesapla çıkış yapılınca ekran kapansa da mesaj görünür.
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      // Önce kimlik doğrulanır; başarısızsa sunucu fonksiyonu ASLA çağrılmaz.
      if (hasPassword) {
        await auth.reauthenticateWithPassword(email!, _password.text);
      } else {
        await auth.reauthenticateWithGoogle();
      }
      final userId = ref.read(signedInUserIdProvider);
      await ref.read(accountServiceProvider).deleteAccount();
      // Hesap artık yok; telefondaki sporcu kartı da silinir.
      if (userId != null) await ref.read(knownAccountsProvider.notifier).remove(userId);
      try {
        // Kullanıcı sunucuda yok artık; yalnızca yerel oturum kapatılır.
        await auth.signOut();
      } catch (_) {
        // Hesap silindi; çıkış hatası kullanıcıya gösterilmez.
      }
      if (!mounted) return;
      // Telefonda başka kart kalmadıysa giriş yerine hoş geldin ekranı açılır.
      context.go(ref.read(knownAccountsProvider).isEmpty ? '/hosgeldin' : '/giris');
    } on AuthFailure catch (e) {
      if (e.message == googleWrongAccountMessage) {
        messenger?.showSnackBar(SnackBar(content: Text(e.message)));
      }
      if (mounted) setState(() => _error = e.message);
    } on DeleteAccountError catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e, st) {
      debugPrint('Hesap silme başarısız: $e\n$st');
      if (mounted) setState(() => _error = unexpectedErrorMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final passwordIdentity = ref.watch(hasPasswordIdentityProvider);
    final googleIdentity = ref.watch(hasGoogleIdentityProvider);
    final hasPassword = _usesPassword(password: passwordIdentity, google: googleIdentity);
    // İki yol da açıksa kullanıcı aralarında geçebilir.
    final canSwitch = passwordIdentity && googleIdentity;
    return SubPage(
      title: 'Hesabı sil',
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(t.radius),
            border: Border.all(color: t.danger),
          ),
          child: MfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: t.danger),
                    const SizedBox(width: 8),
                    Text(
                      'Bu işlem geri alınamaz',
                      style: TextStyle(color: t.danger, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Hesabını silersen aşağıdakiler kalıcı olarak silinir:',
                  style: TextStyle(color: t.textMuted),
                ),
                const SizedBox(height: 6),
                for (final item in _deletedItems)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: t.textMuted)),
                        Expanded(
                          child: Text(item, style: TextStyle(color: t.textMuted)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  'Verilerinin bir kopyasını istersen önce Profil > Verilerimi dışa aktar '
                  'seçeneğini kullan.',
                  style: TextStyle(color: t.textMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Onaylamak için aşağıya $deleteConfirmWord yaz.',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('delete-confirm'),
          controller: _confirm,
          enabled: !_busy,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() => _error = null),
          decoration: const InputDecoration(labelText: 'Onay metni'),
        ),
        const SizedBox(height: 12),
        if (hasPassword)
          PasswordField(label: 'Onay için şifren', controller: _password, enabled: !_busy)
        else
          Text(
            'Devam ettiğinde kimliğini Google ile yeniden doğrulayacağız.',
            style: TextStyle(color: t.textMuted),
          ),
        if (canSwitch)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                      _preferGoogle = !_preferGoogle;
                      _password.clear();
                      _error = null;
                    }),
              child: Text(_preferGoogle ? 'Şifreyle doğrula' : 'Şifre yerine Google ile doğrula'),
            ),
          ),
        InlineError(_error),
        const SizedBox(height: 16),
        MfButton(
          label: 'Hesabımı kalıcı olarak sil',
          loading: _busy,
          danger: true,
          onPressed: _confirmed ? _run : null,
        ),
      ],
    );
  }
}
