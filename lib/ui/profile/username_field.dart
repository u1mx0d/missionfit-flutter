import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../domain/username.dart';
import '../components/dot_grid.dart';
import '../components/mf_text_field.dart';
import '../theme/mf_theme.dart';

enum UsernameStatus { empty, invalid, checking, available, taken, offline }

const usernameCheckDelay = Duration(milliseconds: 400);

/// Kullanıcı adı alanı: yazılanı anında normalleştirir, yerelde geçersizse sunucuya sormaz,
/// 400 ms bekleyip uygunluğu sorar ve yalnızca son isteğin cevabını gösterir.
class UsernameField extends ConsumerStatefulWidget {
  const UsernameField({
    required this.controller,
    this.ownUsername,
    this.onStatus,
    this.errorText,
    this.enabled = true,
    super.key,
  });
  final TextEditingController controller;

  /// Kullanıcının şu anki adı; ona dönülürse sunucuya sorulmadan uygun sayılır.
  final String? ownUsername;
  final ValueChanged<UsernameStatus>? onStatus;

  /// Dışarıdan verilen hata (ör. kaydederken "alınmış"); yazınca temizlenmesi çağıranın işi.
  final String? errorText;
  final bool enabled;

  @override
  ConsumerState<UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends ConsumerState<UsernameField> {
  UsernameStatus _status = UsernameStatus.empty;
  String? _localError;
  Timer? _debounce;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _evaluate(widget.controller.text, initial: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _set(UsernameStatus s, {String? error}) {
    if (!mounted) return;
    setState(() {
      _status = s;
      _localError = error;
    });
    widget.onStatus?.call(s);
  }

  void _onChanged(String raw) {
    final normalized = normalizeUsername(raw);
    if (normalized != raw) {
      widget.controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
    _evaluate(normalized);
  }

  void _evaluate(String value, {bool initial = false}) {
    _debounce?.cancel();
    final request = ++_request;
    if (value.isEmpty) return _setLater(UsernameStatus.empty, initial);
    final error = validateUsername(value);
    if (error != null) return _setLater(UsernameStatus.invalid, initial, error: error);
    if (value == widget.ownUsername) return _setLater(UsernameStatus.available, initial);
    _setLater(UsernameStatus.checking, initial);
    _debounce = Timer(usernameCheckDelay, () async {
      UsernameStatus result;
      try {
        final ok = await ref.read(profileIdentityRepositoryProvider).isUsernameAvailable(value);
        result = ok ? UsernameStatus.available : UsernameStatus.taken;
      } on IdentityError catch (e) {
        result = e.failure == IdentityFailure.offline
            ? UsernameStatus.offline
            : UsernameStatus.taken;
      } catch (_) {
        result = UsernameStatus.offline;
      }
      if (request == _request) _set(result);
    });
  }

  void _setLater(UsernameStatus s, bool initial, {String? error}) {
    if (initial) {
      _status = s;
      _localError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onStatus?.call(s));
    } else {
      _set(s, error: error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final error = widget.errorText ?? _localError ?? _statusError;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MfTextField(
          label: 'Kullanıcı adı',
          controller: widget.controller,
          onChanged: _onChanged,
          errorText: error,
          enabled: widget.enabled,
          suffix: _suffix(t),
        ),
        if (error == null && _status == UsernameStatus.available)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              '✓ Uygun',
              key: const Key('username-available'),
              style: TextStyle(color: t.success, fontSize: 12),
            ),
          ),
      ],
    );
  }

  String? get _statusError => switch (_status) {
    UsernameStatus.taken => 'Bu kullanıcı adı alınmış.',
    UsernameStatus.offline => 'İnternet bağlantısı gerekiyor.',
    _ => null,
  };

  Widget? _suffix(MfTheme t) => switch (_status) {
    UsernameStatus.checking => const Padding(
      padding: EdgeInsets.all(14),
      child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
    ),
    UsernameStatus.available => Icon(Icons.check_circle, color: t.success),
    UsernameStatus.taken || UsernameStatus.invalid => Icon(Icons.error, color: t.danger),
    _ => null,
  };
}
