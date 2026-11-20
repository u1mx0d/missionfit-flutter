import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/profile_controller.dart';
import '../../app/providers.dart';
import '../../app/theme_controller.dart';
import '../../domain/calories.dart';
import '../../domain/format.dart';
import '../../domain/notification_settings.dart';
import '../../domain/units.dart';
import '../../domain/week.dart';
import '../components/dot_grid.dart';
import '../onboarding/consent_step.dart' show showKvkkDialog;
import '../onboarding/goal_step.dart' show activityOptions, goalOptions;
import '../onboarding/kvkk_text.dart';
import '../theme/mf_theme.dart';
import '../training/training_style_picker.dart' show levelLabels, styleTitle;
import 'profile_header.dart';
import 'profile_widgets.dart';

String _activityLabel(ActivityLevel a) => activityOptions.firstWhere((o) => o.$1 == a).$2;
String _goalLabel(Goal g) => goalOptions.firstWhere((o) => o.$1 == g).$2;

String _leadLabel(int m) => switch (m) {
  0 => 'Tam',
  60 => '1 sa',
  _ => '$m dk',
};

String _familyLabel(ThemeFamily f) => f == ThemeFamily.mono ? 'Mono' : 'Canlı';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with WidgetsBindingObserver {
  PermissionState? _permission;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshPermission());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Kullanıcı telefon ayarlarından izni değiştirip dönmüş olabilir.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refreshPermission());
  }

  Future<void> _refreshPermission() async {
    try {
      final p = await ref.read(notificationServiceProvider).permission();
      if (mounted) setState(() => _permission = p);
    } catch (_) {
      if (mounted) setState(() => _permission = null);
    }
  }

  Future<void> _toggleNotifications(Profile p, bool enabled) async {
    final ok = await saveProfile(
      context,
      ref,
      (x) => x.copyWith(
        notificationSettings: NotificationSettings(
          enabled: enabled,
          taskLeadMinutes: x.notificationSettings.taskLeadMinutes,
        ),
      ),
    );
    if (!ok || !enabled) return;
    try {
      final result = await ref.read(notificationServiceProvider).requestPermission();
      if (mounted) setState(() => _permission = result);
    } catch (_) {
      if (mounted) setState(() => _permission = null);
    }
  }

  void _testNotification() {
    // 5 sn sonra gösterilir; beklenmez. Yalnızca uygulama açıkken çalışır.
    unawaited(
      ref.read(notificationServiceProvider).showTest().catchError((_) {
        if (mounted) showSnack(context, 'Deneme bildirimi gösterilemedi.');
      }),
    );
    showSnack(
      context,
      'Deneme bildirimi 5 saniye içinde gelecek. Uygulamayı açık tut, telefonu kilitleme.',
    );
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final result = await ref.read(exportServiceProvider).exportJson();
      if (mounted && result.fromLocal) {
        showSnack(
          context,
          'İnternet yok; cihazdaki verilerin aktarıldı. Sunucudaki en son kayıtlar eksik olabilir.',
        );
      }
    } catch (_) {
      if (mounted) showSnack(context, 'Veriler dışa aktarılamadı. Lütfen tekrar dene.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış yap'),
        content: const Text('Bu cihazdaki oturumun kapatılacak. Verilerin hesabında saklı kalır.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Çıkış yap')),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on AuthFailure catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = mf(context);
    final p = ref.watch(profileProvider).value;
    final email = ref.watch(currentUserEmailProvider);
    final theme = ref.watch(themeControllerProvider);
    final hasPassword = ref.watch(hasPasswordIdentityProvider);
    final notif = p?.notificationSettings ?? defaultNotificationSettings;
    final unit = p?.units ?? WeightUnit.kg;

    final bodyParts = [
      if (p?.heightCm != null) '${_trim(p!.heightCm!)} cm',
      if (p?.weightKg != null) formatWeight(p!.weightKg!, unit),
      if (p?.activityLevel != null) _activityLabel(p!.activityLevel!),
    ];
    final goalParts = [
      if (p != null) p.calorieTargetIsManual ? 'Elle belirlendi' : 'Otomatik hesaplandı',
      if (p?.goal != null) _goalLabel(p!.goal!),
    ];
    final permissionDenied = notif.enabled && _permission == PermissionState.denied;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            const ProfileHeader(),
            ProfileSection(
              title: 'Vücut ve hedef',
              children: [
                if (p == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: LinearProgressIndicator(),
                  )
                else ...[
                  SettingsRow(
                    icon: Icons.accessibility_new,
                    title: 'Fiziksel bilgiler',
                    subtitle: bodyParts.join(' · '),
                    onTap: () => context.push('/profil/vucut'),
                  ),
                  SettingsRow(
                    icon: Icons.sports_gymnastics,
                    title: 'Antrenman tarzım',
                    subtitle: p.trainingStyle == null
                        ? 'Seçilmedi'
                        : [
                            styleTitle(p.trainingStyle!),
                            if (p.trainingLevel != null) levelLabels[p.trainingLevel]!,
                          ].join(' · '),
                    onTap: () => context.push('/profil/tarz'),
                  ),
                  SettingsRow(
                    icon: Icons.local_fire_department,
                    title: 'Günlük kalori hedefi',
                    subtitle: goalParts.join(' · '),
                    value: p.calorieTarget == null ? '-' : '${formatInt(p.calorieTarget!)} kcal',
                    onTap: () => context.push('/profil/vucut'),
                  ),
                ],
              ],
            ),
            ProfileSection(
              title: 'Görünüm',
              children: [
                SettingsRow(
                  icon: Icons.palette,
                  title: 'Tema galerisi',
                  subtitle:
                      '${_familyLabel(theme.family)} · ${theme.accent.label} · '
                      '${switch (theme.mode) {
                        ThemeModeChoice.system => 'Sistem',
                        ThemeModeChoice.light => 'Açık',
                        ThemeModeChoice.dark => 'Koyu',
                      }}',
                  onTap: () => context.push('/profil/tema'),
                ),
              ],
            ),
            ProfileSection(
              title: 'Tercihler',
              children: [
                const _Caption('Ağırlık birimi'),
                SegmentedButton<WeightUnit>(
                  key: const Key('units'),
                  segments: const [
                    ButtonSegment(value: WeightUnit.kg, label: Text('Kilogram (kg)')),
                    ButtonSegment(value: WeightUnit.lb, label: Text('Pound (lb)')),
                  ],
                  selected: {unit},
                  onSelectionChanged: p == null
                      ? null
                      : (s) => saveProfile(context, ref, (x) => x.copyWith(units: s.first)),
                ),
                const _Caption('Hafta başlangıcı'),
                SegmentedButton<WeekStartsOn>(
                  key: const Key('week-start'),
                  segments: const [
                    ButtonSegment(value: WeekStartsOn.monday, label: Text('Pazartesi')),
                    ButtonSegment(value: WeekStartsOn.sunday, label: Text('Pazar')),
                  ],
                  selected: {p?.weekStartsOn ?? WeekStartsOn.monday},
                  onSelectionChanged: p == null
                      ? null
                      : (s) => saveProfile(context, ref, (x) => x.copyWith(weekStartsOn: s.first)),
                ),
                const SizedBox(height: 8),
                const SettingsRow(
                  icon: Icons.language,
                  title: 'Dil',
                  value: 'Türkçe',
                  subtitle: 'Şimdilik yalnızca Türkçe',
                ),
                SettingsRow(
                  icon: Icons.public,
                  title: 'Saat dilimi',
                  value: p?.timezone ?? '-',
                  onTap: p == null ? null : () => context.push('/profil/saat-dilimi'),
                ),
              ],
            ),
            ProfileSection(
              title: 'Bildirimler',
              children: [
                SwitchListTile(
                  key: const Key('notifications-switch'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Görev hatırlatmaları',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: permissionDenied
                      ? Text(
                          'Telefon ayarlarında bildirim izni kapalı. Hatırlatma almak için '
                          'telefonunun ayarlarından MissionFit bildirimlerine izin ver.',
                          style: TextStyle(color: t.warning),
                        )
                      : null,
                  value: notif.enabled,
                  onChanged: p == null ? null : (v) => _toggleNotifications(p, v),
                ),
                const _Caption('Görevden ne kadar önce'),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final m in leadMinuteOptions)
                      ChoiceChip(
                        key: Key('lead-$m'),
                        label: Text(_leadLabel(m)),
                        selected: notif.taskLeadMinutes == m,
                        onSelected: p == null || !notif.enabled
                            ? null
                            : (_) => saveProfile(
                                context,
                                ref,
                                (x) => x.copyWith(
                                  notificationSettings: NotificationSettings(
                                    enabled: x.notificationSettings.enabled,
                                    taskLeadMinutes: m,
                                  ),
                                ),
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SettingsRow(
                  icon: Icons.notifications_active,
                  title: 'Deneme bildirimi',
                  subtitle: '5 saniye sonra gelir; uygulama açıkken çalışır',
                  onTap: _testNotification,
                ),
              ],
            ),
            ProfileSection(
              title: 'Hesap',
              children: [
                if (email != null)
                  SettingsRow(icon: Icons.mail_outline, title: 'E-posta', subtitle: email),
                if (hasPassword)
                  SettingsRow(
                    icon: Icons.key,
                    title: 'Şifre değiştir',
                    onTap: () => context.push('/profil/sifre'),
                  ),
                SettingsRow(icon: Icons.logout, title: 'Çıkış yap', onTap: _confirmSignOut),
              ],
            ),
            ProfileSection(
              title: 'Veri ve gizlilik',
              children: [
                SettingsRow(
                  icon: Icons.description,
                  title: kvkkTitle,
                  onTap: () => showKvkkDialog(context),
                ),
                SettingsRow(
                  icon: Icons.download,
                  title: 'Verilerimi dışa aktar',
                  subtitle: 'Tüm verilerin JSON dosyası olarak',
                  loading: _exporting,
                  onTap: _export,
                ),
                SettingsRow(
                  icon: Icons.delete_forever,
                  title: 'Hesabı sil',
                  danger: true,
                  onTap: () => context.push('/profil/hesap-sil'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              healthDisclaimer,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              modelAttribution,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

String _trim(double v) =>
    (v == v.truncateToDouble() ? v.toInt().toString() : v.toString()).replaceAll('.', ',');

class _Caption extends StatelessWidget {
  const _Caption(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Text(text, style: TextStyle(color: mf(context).textMuted, fontSize: 13)),
  );
}
