import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/i18n/app_locale.dart';

void main() {
  group('AppLocale', () {
    test('maps supported locale codes to Flutter locales', () {
      expect(
        AppLocale.flutterLocaleForCode(AppLocale.englishLocaleCode),
        AppLocale.english,
      );
      expect(
        AppLocale.flutterLocaleForCode(AppLocale.vietnameseLocaleCode),
        AppLocale.vietnamese,
      );
    });

    test('falls back to English for unknown locale codes', () {
      expect(
        AppLocale.resolveSupportedLocaleCode('fr-FR'),
        AppLocale.englishLocaleCode,
      );
      expect(AppLocale.flutterLocaleForCode('fr-FR'), const Locale('en'));
      expect(AppLocale.intlFormatTag('fr-FR'), 'en_US');
    });

    test('derives seed locale from device locale', () {
      expect(
        AppLocale.localeCodeForDeviceLocale(const Locale('vi', 'VN')),
        AppLocale.vietnameseLocaleCode,
      );
      expect(
        AppLocale.localeCodeForDeviceLocale(const Locale('vi')),
        AppLocale.vietnameseLocaleCode,
      );
      expect(
        AppLocale.localeCodeForDeviceLocale(const Locale('en', 'US')),
        AppLocale.englishLocaleCode,
      );
      expect(
        AppLocale.localeCodeForDeviceLocale(const Locale('ja', 'JP')),
        AppLocale.englishLocaleCode,
      );
    });

    test('returns human readable labels for settings picker', () {
      expect(
        AppLocale.displayNameForLocaleCode(AppLocale.englishLocaleCode),
        'English',
      );
      expect(
        AppLocale.displayNameForLocaleCode(AppLocale.vietnameseLocaleCode),
        'Vietnamese',
      );
      expect(AppLocale.displayNameForLocaleCode('unknown'), 'English');
    });
  });
}
