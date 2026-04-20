import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/i18n/app_locale.dart';
import 'package:debt_payoff_manager/core/utils/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_US');
    await initializeDateFormatting('vi_VN');
  });

  group('AppFormatters', () {
    test('formats USD cents using the English locale', () {
      expect(
        AppFormatters.formatCents(
          123456,
          currencyCode: 'USD',
          localeCode: AppLocale.englishLocaleCode,
        ),
        r'$1,234.56',
      );
    });

    test('formats VND without visible decimals for Vietnamese locale', () {
      final formatted = AppFormatters.formatCents(
        123456,
        currencyCode: 'VND',
        localeCode: AppLocale.vietnameseLocaleCode,
      );

      expect(formatted, contains('₫'));
      expect(formatted, contains('1.235'));
      expect(formatted, isNot(contains(',56')));
    });

    test('formats dates and preview timestamps with locale awareness', () {
      final value = DateTime.utc(2026, 4, 19, 5, 6);

      final englishDate = AppFormatters.formatDate(
        value,
        localeCode: AppLocale.englishLocaleCode,
      );
      final vietnameseDate = AppFormatters.formatDate(
        value,
        localeCode: AppLocale.vietnameseLocaleCode,
      );
      final englishPreview = AppFormatters.formatDateTime(
        value,
        localeCode: AppLocale.englishLocaleCode,
      );
      final vietnamesePreview = AppFormatters.formatDateTime(
        value,
        localeCode: AppLocale.vietnameseLocaleCode,
      );

      expect(englishDate, contains('Apr'));
      expect(vietnameseDate.toLowerCase(), contains('thg'));
      expect(englishPreview, matches(RegExp(r'0?5:06')));
      expect(vietnamesePreview, matches(RegExp(r'0?5:06')));
      expect(englishPreview, isNot(vietnamesePreview));
    });
  });
}
