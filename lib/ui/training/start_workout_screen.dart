import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/active_workout_controller.dart';
import '../../app/profile_controller.dart';
import '../../app/today_provider.dart';
import '../../app/workout_providers.dart';
import '../../domain/active_workout.dart';
import '../../domain/date_labels.dart';
import '../../domain/dates.dart';
import '../../domain/muscle_coverage.dart';
import '../../domain/turkish_text.dart';
import '../components/dot_grid.dart';
import '../theme/mf_theme.dart';
import 'focus_widgets.dart' show FocusCta;
import 'training_screen.dart' show regionTitle;

/// Antrenmanı başlatır ve odak moduna geçer. Süren bir antrenman varsa ikincisi açılmaz:
/// doğrudan ona devam edilir.
Future<void> startOrResume(
  BuildContext context,
  WidgetRef ref,
  Future<List<PlannedExercise>> Function() planOf, {
  String? templateId,
  String? name,
}) async {
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final ctl = ref.read(activeWorkoutControllerProvider.notifier);
  try {
    final active = await ref.read(activeWorkoutControllerProvider.future);
    if (active != null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Süren bir antrenman var, ona devam ediliyor.')),
      );
      router.go('/antrenman/odak');
      return;
    }
    await ctl.start(await planOf(), templateId: templateId, name: name);
  } catch (e) {
    debugPrint('Antrenman başlatılamadı: $e');
    messenger.showSnackBar(const SnackBar(content: Text('Antrenman başlatılamadı. Tekrar dene.')));
    return;
  }
  router.go('/antrenman/odak');
}

/// Liste kurarak başlama: bölge çipi → hareketleri işaretle (önce yaptıkların, sonra katalog)
/// ya da ara → "N hareketle başla". Liste kurmadan "Boş başla" da olur.
class StartWorkoutScreen extends ConsumerStatefulWidget {
  const StartWorkoutScreen({super.key});

  @override
  ConsumerState<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends ConsumerState<StartWorkoutScreen> {
  BodyRegion? _region;
  String _query = '';
  Future<List<ExerciseOption>>? _results;

  /// İşaretlenen hareketler, işaretlenme sırasıyla (plan bu sırayla kurulur).
  final _selected = <ExerciseOption>[];
  bool _busy = false;
  String _zone = defaultTimeZone;
  LocalDate _today = '';

  void _reload() {
    final q = ref.read(workoutQueriesProvider);
    final userId = ref.read(signedInUserIdProvider);
    if (_query.trim().isNotEmpty) {
      _results = q.searchExercises(_query.trim());
    } else if (_region != null && userId != null) {
      _results = q.exercisesForRegion(userId, _region!);
    } else {
      _results = null;
    }
  }

  void _pickRegion(BodyRegion r) => setState(() {
    _region = _region == r ? null : r;
    _reload();
  });

  void _search(String q) => setState(() {
    _query = q;
    _reload();
  });

  void _toggle(ExerciseOption e) => setState(() {
    final i = _selected.indexWhere((x) => x.id == e.id);
    if (i >= 0) {
      _selected.removeAt(i);
    } else {
      _selected.add(e);
    }
  });

  Future<void> _start({required bool empty}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final ids = empty ? const <String>[] : [for (final e in _selected) e.id];
    try {
      await startOrResume(
        context,
        ref,
        () async => ids.isEmpty ? const [] : ref.read(planForExercisesProvider)(ids),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final mono = t.family == ThemeFamily.mono;
    final n = _selected.length;
    // "Son: 2 gün önce" yerel tarihle hesaplanır.
    _zone = ref.watch(profileProvider.select((p) => p.value?.timezone)) ?? defaultTimeZone;
    _today = ref.watch(todayProvider.select((x) => x.date));
    return Scaffold(
      appBar: AppBar(
        title: Text(mono ? turkishUpper('Hareket seç') : 'Hareket seç'),
        backgroundColor: t.background,
        foregroundColor: t.text,
      ),
      body: MfBackground(
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Çipler ve arama listeyle birlikte kayar (yatayda ve büyük yazıda yer açılır).
                  Expanded(child: _list(t, _top())),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FocusCta(
                          key: const Key('start-selected'),
                          label: n == 0 ? 'Hareket seç' : '$n hareketle başla',
                          onPressed: n == 0 || _busy ? null : () => _start(empty: false),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _busy ? null : () => _start(empty: true),
                          style: TextButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: t.text,
                          ),
                          child: const Text('Boş başla'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _top() => [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Wrap(
        spacing: 8,
        children: [
          for (final r in BodyRegion.values)
            ChoiceChip(
              label: Text(regionTitle(r)),
              selected: _region == r && _query.trim().isEmpty,
              onSelected: (_) => _pickRegion(r),
            ),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          labelText: 'Katalogda ara',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: _search,
      ),
    ),
  ];

  Widget _message(MfTheme t, String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: t.textMuted, fontSize: 15),
      ),
    ),
  );

  Widget _list(MfTheme t, List<Widget> top) {
    final results = _results;
    final searching = _query.trim().isNotEmpty;
    return FutureBuilder<List<ExerciseOption>>(
      future: results,
      builder: (context, snap) {
        // Hep aynı ListView: arama alanı yeniden kurulmaz, odağı ve metni kaybolmaz.
        Widget only(Widget w) => ListView(children: [...top, w]);
        if (results == null) return only(_message(t, 'Bir bölge seç ya da hareket ara.'));
        if (snap.hasError) return only(_message(t, 'Hareketler yüklenemedi.'));
        final list = snap.data;
        if (list == null) {
          return only(
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (list.isEmpty) {
          return only(_message(t, searching ? 'Hareket bulunamadı.' : 'Bu bölgede hareket yok.'));
        }
        if (searching) {
          return ListView(children: [...top, for (final e in list) _tile(t, e)]);
        }
        final done = [
          for (final e in list)
            if (e.lastDoneAt != null) e,
        ];
        final rest = [
          for (final e in list)
            if (e.lastDoneAt == null) e,
        ];
        return ListView(
          children: [
            ...top,
            if (done.isNotEmpty) ...[_header(t, 'Yaptıkların'), for (final e in done) _tile(t, e)],
            if (rest.isNotEmpty) ...[_header(t, 'Katalog'), for (final e in rest) _tile(t, e)],
          ],
        );
      },
    );
  }

  Widget _header(MfTheme t, String text) {
    final mono = t.family == ThemeFamily.mono;
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          mono ? turkishUpper(text) : text,
          style: TextStyle(
            color: t.textMuted,
            fontSize: mono ? 12 : 13,
            fontWeight: FontWeight.w600,
            letterSpacing: mono ? 1.6 : 0.2,
          ),
        ),
      ),
    );
  }

  Widget _tile(MfTheme t, ExerciseOption e) {
    final selected = _selected.any((x) => x.id == e.id);
    final last = e.lastDoneAt;
    String? subtitle;
    if (last != null) {
      subtitle = 'Son: ${daysAgoLabel(localDateInZone(last, _zone), _today)}';
    }
    return CheckboxListTile(
      value: selected,
      onChanged: (_) => _toggle(e),
      minTileHeight: 56,
      controlAffinity: ListTileControlAffinity.trailing,
      activeColor: t.accent,
      checkColor: t.onAccent,
      title: Text(e.nameTr, style: TextStyle(color: t.text)),
      subtitle: subtitle == null ? null : Text(subtitle, style: TextStyle(color: t.textMuted)),
    );
  }
}
