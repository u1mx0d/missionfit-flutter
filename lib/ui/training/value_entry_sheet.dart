import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/value_input.dart';
import '../components/dot_grid.dart';
import '../components/mf_button.dart';

/// Değere dokununca açılan küçük giriş: sayı klavyesi, değer önceden dolu ve tümü seçili.
/// "Tamam" geçersiz değerde kapanmaz, hata alanın altında yazılır; "İptal" değeri değiştirmez.
/// –/+ birincil denetim olarak kalır; bu giriş uzun yollar için isteğe bağlı kısayoldur.
Future<T?> showValueEntry<T>(
  BuildContext context, {
  required String title,
  required String label,
  required String initial,
  required Parsed<T> Function(String) parse,
  bool decimal = false,
  bool clock = false,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: mf(context).surface,
  builder: (_) => _ValueEntry<T>(
    title: title,
    label: label,
    initial: initial,
    parse: parse,
    decimal: decimal,
    clock: clock,
  ),
);

class _ValueEntry<T> extends StatefulWidget {
  const _ValueEntry({
    required this.title,
    required this.label,
    required this.initial,
    required this.parse,
    required this.decimal,
    required this.clock,
  });

  final String title;
  final String label;
  final String initial;
  final Parsed<T> Function(String) parse;
  final bool decimal;
  final bool clock;

  @override
  State<_ValueEntry<T>> createState() => _ValueEntryState<T>();
}

class _ValueEntryState<T> extends State<_ValueEntry<T>> {
  late final _ctrl = TextEditingController(text: widget.initial)
    ..selection = TextSelection(baseOffset: 0, extentOffset: widget.initial.length);
  String? _error;

  /// Sayfa bir kez kapanır: çift "Tamam" ya da "Tamam" + klavyenin Bitti'si alttaki ekranı
  /// kapatmasın.
  bool _done = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_done || !mounted) return;
    final r = widget.parse(_ctrl.text);
    if (r.value == null) {
      setState(() => _error = r.error);
      return;
    }
    _close(r.value);
  }

  void _close([T? value]) {
    if (_done || !mounted) return;
    _done = true;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    // Süre "dk:sn" yazıldığından sayı klavyesinde ':' yoktur; metin klavyesi açılır.
    final keyboard = widget.clock
        ? TextInputType.datetime
        : TextInputType.numberWithOptions(decimal: widget.decimal);
    final allowed = widget.clock
        ? RegExp(r'[0-9:]')
        : widget.decimal
        ? RegExp(r'[0-9.,]')
        : RegExp('[0-9]');
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: t.text),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('value-entry-field'),
                controller: _ctrl,
                autofocus: true,
                keyboardType: keyboard,
                inputFormatters: [FilteringTextInputFormatter.allow(allowed)],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                style: TextStyle(fontSize: 24, fontFamily: t.numberFont, color: t.text),
                decoration: InputDecoration(
                  labelText: widget.label,
                  helperText: widget.clock ? 'ör. 1:30' : null,
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MfButton(label: 'İptal', secondary: true, onPressed: _close),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MfButton(label: 'Tamam', onPressed: _submit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
