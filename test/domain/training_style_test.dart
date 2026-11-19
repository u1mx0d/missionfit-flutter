import 'package:flutter_test/flutter_test.dart';
import 'package:missionfit/domain/training_style.dart';

void main() {
  const c = TrainingStyle.calisthenics;
  const f = TrainingStyle.functional;
  const b = TrainingStyle.bodybuilding;

  group('StyleSelection.tap', () {
    test('boştan ilk dokunuş ana tarz olur', () {
      final s = const StyleSelection().tap(c);
      expect(s.main, c);
      expect(s.sides, isEmpty);
    });

    test('sonraki dokunuş yan tarz ekler', () {
      final s = const StyleSelection().tap(c).tap(f);
      expect(s.main, c);
      expect(s.sides, [f]);
    });

    test('ana kaldırılınca ilk yan tarz ana olur', () {
      final s = const StyleSelection().tap(c).tap(f).tap(c);
      expect(s.main, f);
      expect(s.sides, isEmpty);
    });

    test('tek ana tekrar dokunulunca boşalır', () {
      final s = const StyleSelection().tap(f).tap(f);
      expect(s.main, isNull);
      expect(s.sides, isEmpty);
    });

    test('yan tarza tekrar dokunmak kaldırır', () {
      final s = const StyleSelection().tap(c).tap(f).tap(b).tap(f);
      expect(s.main, c);
      expect(s.sides, [b]);
    });
  });

  group('StyleSelection.makeMain', () {
    test('yan tarz ana olur, eski ana yan listenin başına geçer', () {
      final s = const StyleSelection().tap(c).tap(f).tap(b).makeMain(b);
      expect(s.main, b);
      expect(s.sides, [c, f]);
    });

    test('seçili olmayan tarz için değişmez', () {
      final s = const StyleSelection().tap(c).makeMain(f);
      expect(s.main, c);
      expect(s.sides, isEmpty);
    });
  });

  group('goalOptionsFor', () {
    test('önce ana, sonra yan tarzın yeni hareketleri; tekrar yok', () {
      final out = goalOptionsFor(const StyleSelection(main: c, sides: [f]));
      expect(out, [...goalMovesByStyle[c]!, 'rope_climb', 'box_jump', 'kb_swing', 'get_up']);
      expect(out.where((k) => k == 'first_pullup').length, 1);
    });

    test('keep listede olmayanı sona ekler', () {
      final out = goalOptionsFor(const StyleSelection(main: c), keep: ['bench_up']);
      expect(out.last, 'bench_up');
      expect(out.length, goalMovesByStyle[c]!.length + 1);
    });

    test('keep zaten listede olanı çoğaltmaz', () {
      final out = goalOptionsFor(const StyleSelection(main: c), keep: ['planche']);
      expect(out, goalMovesByStyle[c]);
    });

    test('ana yoksa yalnız keep döner', () {
      expect(goalOptionsFor(const StyleSelection(), keep: ['run_5k']), ['run_5k']);
    });
  });

  group('validateStyle', () {
    test('ana yok', () {
      expect(validateStyle(const StyleSelection(), TrainingLevel.beginner), 'Ana tarzını seç.');
    });
    test('seviye yok', () {
      expect(validateStyle(const StyleSelection(main: c), null), 'Seviyeni seç.');
    });
    test('geçerli', () {
      expect(validateStyle(const StyleSelection(main: c), TrainingLevel.advanced), isNull);
    });
  });

  test('her hedef hareketin Türkçe etiketi var', () {
    final keys = goalMovesByStyle.values.expand((l) => l).toSet();
    for (final k in keys) {
      expect(goalMoveLabels[k], isNotNull, reason: k);
    }
    expect(goalMoveLabels.keys.toSet(), keys);
  });

  test('sunucu dizgisi enum adıdır', () {
    expect(TrainingStyle.calisthenics.name, 'calisthenics');
    expect(TrainingLevel.beginner.name, 'beginner');
    expect(FocusArea.mobility.name, 'mobility');
  });
}
