import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/settings_repository_impl.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepositoryImpl(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SettingsRepositoryImpl', () {
    test('getSettings returns seeded singleton', () async {
      final settings = await repo.getSettings();
      expect(settings.id, 'singleton');
      expect(settings.trustLevel, 0);
      expect(settings.currencyCode, 'USD');
      expect(settings.onboardingStep, 0);
      expect(settings.onboardingCompleted, false);
    });

    test('updateSettings persists changes', () async {
      var settings = await repo.getSettings();
      await repo.updateSettings(
        settings.copyWith(
          trustLevel: 1,
          onboardingStep: 3,
          currencyCode: 'VND',
        ),
      );

      settings = await repo.getSettings();
      expect(settings.trustLevel, 1);
      expect(settings.onboardingStep, 3);
      expect(settings.currencyCode, 'VND');
    });

    test('watchSettings emits on changes', () async {
      final stream = repo.watchSettings();

      // Initial emission
      await expectLater(
        stream,
        emits(predicate<dynamic>((s) => s.currencyCode == 'USD')),
      );

      // Update
      final current = await repo.getSettings();
      await repo.updateSettings(current.copyWith(currencyCode: 'EUR'));

      await expectLater(
        stream,
        emits(predicate<dynamic>((s) => s.currencyCode == 'EUR')),
      );
    });
  });
}
