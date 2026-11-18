import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/profile_controller.dart';
import '../../app/providers.dart';
import '../../domain/dates.dart';
import '../components/dot_grid.dart';
import 'profile_widgets.dart';

/// Aranabilir IANA saat dilimi listesi; cihazın saat dilimi ilk sırada.
class TimezoneScreen extends ConsumerStatefulWidget {
  const TimezoneScreen({super.key});

  @override
  ConsumerState<TimezoneScreen> createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends ConsumerState<TimezoneScreen> {
  late final List<String> _all = selectableTimeZones();
  String _query = '';

  String _norm(String s) => s.toLowerCase().replaceAll('_', ' ');

  Future<void> _pick(String zone) async {
    final ok = await saveProfile(context, ref, (p) => p.copyWith(timezone: zone));
    if (ok && mounted && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final current = ref.watch(profileProvider).value?.timezone;
    final device = ref.watch(deviceTimezoneProvider).value;
    final deviceValid = device != null && isValidTimeZone(device);
    final q = _norm(_query.trim());
    bool matches(String z) => q.isEmpty || _norm(z).contains(q);
    final zones = [
      if (deviceValid && matches(device)) device,
      for (final z in _all)
        if (z != device && matches(z)) z,
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: t.text,
        title: Text(
          'Saat dilimi',
          style: TextStyle(fontFamily: t.displayFont, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: TextField(
                key: const Key('tz-search'),
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  labelText: 'Ara (ör. Istanbul)',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: zones.isEmpty
                  ? Center(
                      child: Text('Eşleşen saat dilimi yok.', style: TextStyle(color: t.textMuted)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: zones.length,
                      itemBuilder: (context, i) {
                        final zone = zones[i];
                        final isDevice = zone == device && deviceValid;
                        return ListTile(
                          title: Text(zone),
                          subtitle: isDevice ? const Text('Cihazın saat dilimi') : null,
                          trailing: zone == current ? Icon(Icons.check, color: t.accent) : null,
                          selected: zone == current,
                          selectedColor: t.accent,
                          onTap: () => _pick(zone),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
