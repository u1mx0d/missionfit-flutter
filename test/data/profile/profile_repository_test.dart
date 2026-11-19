import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart' hide Profile;
import 'package:missionfit/data/profile/profile_repository.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/data/sync/outbox_queue.dart';
import 'package:missionfit/data/sync/sync_engine.dart';

import '../sync/fake_remote_gateway.dart';

import 'package:missionfit/domain/calories.dart';
import 'package:missionfit/domain/training_style.dart';
import 'package:missionfit/ui/theme/accents.dart';

class FailingOutbox extends OutboxRepository {
  FailingOutbox(super.db);
  @override
  Future<void> enqueue(OutboxOp op) async => throw StateError('kuyruk hatası');
}

Future<void> seed(AppDatabase db, {String accent = 'yesil', String family = 'canli'}) => db
    .into(db.profiles)
    .insert(
      ProfilesCompanion.insert(
        userId: 'u1',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
        accentColor: Value(accent),
        themeFamily: Value(family),
        activityLevel: const Value('very_active'),
      ),
    );

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('update yerel satırı ve outbox işlemini birlikte yazar', () async {
    await seed(db);
    final outbox = OutboxRepository(db);
    final repo = ProfileRepository(db, outbox);
    await repo.update('u1', (p) => p.copyWith(displayName: 'Ali', accentColor: AccentColor.mor));
    final p = await repo.watch('u1').first;
    expect(p!.displayName, 'Ali');
    expect(p.accentColor, AccentColor.mor);
    expect(p.activityLevel, ActivityLevel.veryActive);
    final ops = await outbox.pending();
    expect(ops, hasLength(1));
    expect(ops.single.type, 'profiles.upsert');
    expect(ops.single.key, 'profiles:u1');
    expect(ops.single.payload['display_name'], 'Ali');
    expect(ops.single.payload['accent_color'], 'mor');
    expect(ops.single.payload['activity_level'], 'very_active');
    expect(ops.single.payload.containsKey('updated_at'), isFalse);
    expect(ops.single.payload.containsKey('displayName'), isFalse);
  });

  test('update sırasında hata olursa ikisi de yazılmaz', () async {
    await seed(db);
    final repo = ProfileRepository(db, FailingOutbox(db));
    await expectLater(repo.update('u1', (p) => p.copyWith(displayName: 'Ali')), throwsStateError);
    expect((await repo.watch('u1').first)!.displayName, isNull);
    expect(await OutboxRepository(db).pending(), isEmpty);
  });

  test('sunucudan accent_color=bilinmeyen gelirse yesil kullanilir', () async {
    await seed(db, accent: 'bilinmeyen', family: 'uzay');
    final p = await ProfileRepository(db, OutboxRepository(db)).watch('u1').first;
    expect(p!.accentColor, AccentColor.yesil);
    expect(p.themeFamily.name, 'canli');
  });

  test('ağ yokken profil yerelden okunur', () async {
    await seed(db);
    // Hiçbir uzak ağ geçidi yok: depo yalnızca yerel veritabanına dayanır.
    final p = await ProfileRepository(db, OutboxRepository(db)).watch('u1').first;
    expect(p, isNotNull);
    expect(p!.userId, 'u1');
  });

  test('yerel satır yoksa ve sunucudan alınamazsa ProfileNotReadyException fırlatır', () async {
    final outbox = OutboxRepository(db);
    final repo = ProfileRepository(db, outbox, fetchRemote: (_) async => null);
    await expectLater(
      repo.update('u1', (p) => p.copyWith(displayName: 'Ali')),
      throwsA(isA<ProfileNotReadyException>()),
    );
    expect(await outbox.pending(), isEmpty);
    expect(await repo.watch('u1').first, isNull);
  });

  test('fetchRemote hata verirse de ProfileNotReadyException fırlatır', () async {
    final repo = ProfileRepository(
      db,
      OutboxRepository(db),
      fetchRemote: (_) async => throw StateError('ağ yok'),
    );
    await expectLater(repo.update('u1', (p) => p), throwsA(isA<ProfileNotReadyException>()));
  });

  test('yerel satır yoksa sunucudan bir kez alınır, uygulanır ve güncellenir', () async {
    final outbox = OutboxRepository(db);
    var calls = 0;
    final repo = ProfileRepository(
      db,
      outbox,
      fetchRemote: (id) async {
        calls++;
        return {
          'user_id': id,
          'display_name': 'Sunucu',
          'accent_color': 'mavi',
          'theme_family': 'mono',
          'activity_level': 'very_active',
          'notification_settings': {'enabled': false, 'task_lead_minutes': 5},
          'onboarding_completed': false,
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-01T00:00:00Z',
        };
      },
    );
    await repo.update('u1', (p) => p.copyWith(onboardingCompleted: true));
    expect(calls, 1);
    final p = (await repo.watch('u1').first)!;
    expect(p.displayName, 'Sunucu');
    expect(p.accentColor, AccentColor.mavi);
    expect(p.activityLevel, ActivityLevel.veryActive);
    expect(p.notificationSettings.enabled, isFalse);
    expect(p.onboardingCompleted, isTrue);
    expect((await outbox.pending()).single.payload['onboarding_completed'], true);
  });

  test('bekleyen profiles.upsert yerel satırı eski sunucu değerine karşı korur', () async {
    await seed(db);
    final outbox = OutboxRepository(db);
    final remote = FakeRemoteGateway();
    remote.put('profiles', {
      'user_id': 'u1',
      'display_name': 'Eski',
      'created_at': '2026-01-01T00:00:00Z',
    });
    await ProfileRepository(db, outbox).update('u1', (p) => p.copyWith(displayName: 'Yeni'));
    await SyncEngine(db, outbox, remote).pull();
    final p = await ProfileRepository(db, outbox).watch('u1').first;
    expect(p!.displayName, 'Yeni');
    expect(await outbox.pending(), hasLength(1));
  });

  group('kimlik alanları', () {
    const base = {'user_id': 'u1', 'username': 'alp', 'avatar_path': 'u1/1.jpg'};

    test('toPayload kullanıcı adı ve avatarı göndermez', () {
      final p = Profile.fromServer(base)!;
      expect(p.toPayload().containsKey('username'), isFalse);
      expect(p.toPayload().containsKey('avatar_path'), isFalse);
    });

    test('fromServer kullanıcı adı ve avatar yolunu okur', () {
      final p = Profile.fromServer(base)!;
      expect(p.username, 'alp');
      expect(p.avatarPath, 'u1/1.jpg');
      final row = p.toRow();
      expect(row['username'], 'alp');
      expect(row['avatar_path'], 'u1/1.jpg');
    });
  });

  group('antrenman tarzı alanları', () {
    test('fromServer bilinmeyen değerleri atar', () {
      final p = Profile.fromServer({
        'user_id': 'u1',
        'training_style': 'calisthenics',
        'side_styles': ['functional', 'yoga'],
        'training_level': 'expert',
        'goal_moves': ['muscle_up', 'bilinmeyen'],
        'focus_areas': ['push', 'x'],
      })!;
      expect(p.trainingStyle, TrainingStyle.calisthenics);
      expect(p.sideStyles, [TrainingStyle.functional]);
      expect(p.trainingLevel, isNull);
      expect(p.goalMoves, ['muscle_up']);
      expect(p.focusAreas, [FocusArea.push]);
    });

    test('fromServer JSON metni de kabul eder, eksikse boş liste', () {
      final p = Profile.fromServer({'user_id': 'u1', 'side_styles': '["strength"]'})!;
      expect(p.sideStyles, [TrainingStyle.strength]);
      expect(p.goalMoves, isEmpty);
      expect(p.trainingStyle, isNull);
    });

    test('toPayload beş alanı içerir, username/avatar_path içermez', () {
      final p = Profile.fromServer({
        'user_id': 'u1',
        'username': 'alp',
        'training_style': 'strength',
        'side_styles': ['general'],
        'training_level': 'advanced',
        'goal_moves': ['bench_up'],
        'focus_areas': ['core', 'legs'],
      })!;
      final m = p.toPayload();
      expect(m['training_style'], 'strength');
      expect(m['side_styles'], ['general']);
      expect(m['training_level'], 'advanced');
      expect(m['goal_moves'], ['bench_up']);
      expect(m['focus_areas'], ['core', 'legs']);
      expect(m.containsKey('username'), isFalse);
      expect(m.containsKey('avatar_path'), isFalse);
    });

    test('fromServer ana tarzı ve tekrarları yan tarzlardan çıkarır', () {
      final p = Profile.fromServer({
        'user_id': 'u1',
        'training_style': 'calisthenics',
        'side_styles': ['calisthenics', 'functional', 'functional'],
      })!;
      expect(p.sideStyles, [TrainingStyle.functional]);
    });

    test('copyWith ana tarzı değiştirince yan tarzlardan çıkarır', () {
      final p = Profile.fromServer({
        'user_id': 'u1',
        'training_style': 'strength',
        'side_styles': ['functional'],
      })!;
      expect(p.copyWith(trainingStyle: TrainingStyle.functional).sideStyles, isEmpty);
    });

    test('toPayload ana tarzı side_styles içinde asla göndermez', () {
      final p = Profile(
        userId: 'u1',
        createdAt: 'x',
        updatedAt: 'x',
        trainingStyle: TrainingStyle.general,
        sideStyles: [TrainingStyle.general, TrainingStyle.strength],
      );
      expect(p.toPayload()['side_styles'], ['strength']);
      expect(p.toCompanion().sideStyles.value, '["strength"]');
    });

    test('boş profil yükü: tarz null, listeler boş', () {
      final m = Profile(userId: 'u1', createdAt: 'x', updatedAt: 'x').toPayload();
      expect(m['training_style'], isNull);
      expect(m['training_level'], isNull);
      expect(m['side_styles'], isEmpty);
      expect(m['goal_moves'], isEmpty);
      expect(m['focus_areas'], isEmpty);
    });

    test('fromRow JSON metnindeki bilinmeyen değeri atar ve normalize eder', () async {
      await seed(db);
      await (db.update(db.profiles)..where((t) => t.userId.equals('u1'))).write(
        const ProfilesCompanion(
          trainingStyle: Value('strength'),
          sideStyles: Value('["strength","yoga","general"]'),
          goalMoves: Value('["bench_up","nope"]'),
          focusAreas: Value('["core","zzz"]'),
        ),
      );
      final p = await ProfileRepository(db, OutboxRepository(db)).watch('u1').first;
      expect(p!.sideStyles, [TrainingStyle.general]);
      expect(p.goalMoves, ['bench_up']);
      expect(p.focusAreas, [FocusArea.core]);
    });

    test('copyWith dokunulmayan yeni alanları korur', () {
      final p = Profile.fromServer({
        'user_id': 'u1',
        'training_style': 'strength',
        'side_styles': ['general'],
        'training_level': 'advanced',
        'goal_moves': ['bench_up'],
        'focus_areas': ['core'],
      })!;
      final q = p.copyWith(displayName: 'Ali');
      expect(q.trainingStyle, TrainingStyle.strength);
      expect(q.sideStyles, [TrainingStyle.general]);
      expect(q.trainingLevel, TrainingLevel.advanced);
      expect(q.goalMoves, ['bench_up']);
      expect(q.focusAreas, [FocusArea.core]);
    });

    test('update outbox a tek kayıt yazar ve yerelde saklar', () async {
      await seed(db);
      final outbox = OutboxRepository(db);
      final repo = ProfileRepository(db, outbox);
      await repo.update(
        'u1',
        (p) => p.copyWith(
          trainingStyle: TrainingStyle.functional,
          sideStyles: [TrainingStyle.strength],
          trainingLevel: TrainingLevel.beginner,
          goalMoves: ['kb_swing'],
          focusAreas: [FocusArea.mobility],
        ),
      );
      final p = await repo.watch('u1').first;
      expect(p!.trainingStyle, TrainingStyle.functional);
      expect(p.sideStyles, [TrainingStyle.strength]);
      expect(p.focusAreas, [FocusArea.mobility]);
      final ops = await outbox.pending();
      expect(ops, hasLength(1));
      expect(ops.single.payload['training_style'], 'functional');
      expect(ops.single.payload['side_styles'], ['strength']);
      expect(ops.single.payload['goal_moves'], ['kb_swing']);
    });
  });
}
