import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/data/db/database.dart' hide Profile;
import 'package:missionfit/data/profile/profile_repository.dart';
import 'package:missionfit/data/sync/outbox.dart';
import 'package:missionfit/data/sync/outbox_queue.dart';
import 'package:missionfit/domain/calories.dart';
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

  test('yerel satır yoksa update hiçbir şey yazmaz', () async {
    final outbox = OutboxRepository(db);
    await ProfileRepository(db, outbox).update('u1', (p) => p);
    expect(await outbox.pending(), isEmpty);
  });
}
