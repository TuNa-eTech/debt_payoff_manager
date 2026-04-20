import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/i18n/app_locale.dart';
import 'package:debt_payoff_manager/data/local/database.dart';

void main() {
  group('AppDatabase locale seeding', () {
    test('fresh install defaults to English locale code', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final settings = await _singletonSettings(db);

      expect(settings.localeCode, AppLocale.englishLocaleCode);
    });

    test('fresh install uses the configured seed locale code', () async {
      final db = AppDatabase(
        NativeDatabase.memory(),
        initialLocaleCode: AppLocale.vietnameseLocaleCode,
      );
      addTearDown(db.close);

      final settings = await _singletonSettings(db);

      expect(settings.localeCode, AppLocale.vietnameseLocaleCode);
    });

    test('factory reset reseeds the configured initial locale code', () async {
      final db = AppDatabase(
        NativeDatabase.memory(),
        initialLocaleCode: AppLocale.vietnameseLocaleCode,
      );
      addTearDown(db.close);

      await (db.update(
        db.userSettingsTable,
      )..where((row) => row.id.equals('singleton'))).write(
        const UserSettingsTableCompanion(
          localeCode: Value(AppLocale.englishLocaleCode),
          onboardingStep: Value(3),
          onboardingCompleted: Value(true),
        ),
      );

      await db.resetToFactoryState();

      final settings = await _singletonSettings(db);

      expect(settings.localeCode, AppLocale.vietnameseLocaleCode);
      expect(settings.onboardingStep, 0);
      expect(settings.onboardingCompleted, isFalse);
    });
  });
}

Future<UserSettingsRow> _singletonSettings(AppDatabase db) {
  return (db.select(
    db.userSettingsTable,
  )..where((row) => row.id.equals('singleton'))).getSingle();
}
