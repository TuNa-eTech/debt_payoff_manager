import 'package:debt_payoff_manager/data/local/converters/datetime_converters.dart';
import 'package:debt_payoff_manager/data/local/converters/decimal_converter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecimalConverter', () {
    const converter = DecimalConverter();

    test('round-trip preserves value', () {
      final original = Decimal.parse('0.1899');
      final sql = converter.toSql(original);
      final restored = converter.fromSql(sql);
      expect(restored, original);
    });

    test('handles zero', () {
      final zero = Decimal.zero;
      expect(converter.fromSql(converter.toSql(zero)), zero);
    });

    test('handles high precision', () {
      final val = Decimal.parse('0.123456789');
      expect(converter.fromSql(converter.toSql(val)), val);
    });
  });

  group('UtcDateTimeConverter', () {
    const converter = UtcDateTimeConverter();

    test('round-trip preserves UTC', () {
      final original = DateTime.utc(2026, 4, 18, 10, 30, 45);
      final sql = converter.toSql(original);
      final restored = converter.fromSql(sql);
      expect(restored, original);
      expect(restored.isUtc, true);
    });

    test('converts local to UTC on save', () {
      final local = DateTime(2026, 4, 18, 10, 30);
      final sql = converter.toSql(local);
      expect(sql, contains('Z')); // UTC marker
    });
  });

  group('LocalDateConverter', () {
    const converter = LocalDateConverter();

    test('stores as YYYY-MM-DD', () {
      final date = DateTime(2026, 4, 18);
      final sql = converter.toSql(date);
      expect(sql, '2026-04-18');
    });

    test('round-trip preserves calendar date', () {
      final original = DateTime(2026, 1, 15);
      final sql = converter.toSql(original);
      final restored = converter.fromSql(sql);
      expect(restored.year, 2026);
      expect(restored.month, 1);
      expect(restored.day, 15);
    });
  });
}
