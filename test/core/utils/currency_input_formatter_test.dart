import 'package:debt_payoff_manager/core/utils/currency_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _val(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

String _format(String oldText, String newText) {
  final formatter = CurrencyInputFormatter();
  final result = formatter.formatEditUpdate(_val(oldText), _val(newText));
  return result.text;
}

void main() {
  group('CurrencyInputFormatter', () {
    group('formatEditUpdate — basic formatting', () {
      test('empty string stays empty', () {
        expect(_format('', ''), '');
      });

      test('single digit stays as-is', () {
        expect(_format('', '5'), '5');
      });

      test('three digits stay without comma', () {
        expect(_format('', '999'), '999');
      });

      test('four digits get a thousands comma', () {
        expect(_format('', '1000'), '1,000');
      });

      test('seven digits get two commas', () {
        expect(_format('', '1000000'), '1,000,000');
      });

      test('value with existing comma is re-formatted', () {
        expect(_format('1,00', '1,000'), '1,000');
      });
    });

    group('formatEditUpdate — decimal handling', () {
      test('trailing dot is preserved', () {
        expect(_format('100', '100.'), '100.');
      });

      test('one decimal digit', () {
        expect(_format('100.', '100.5'), '100.5');
      });

      test('two decimal digits', () {
        expect(_format('100.5', '100.50'), '100.50');
      });

      test('third decimal digit is truncated', () {
        expect(_format('100.50', '100.505'), '100.50');
      });

      test('1234.56 formatted correctly', () {
        expect(_format('', '1234.56'), '1,234.56');
      });

      test('large amount with decimals', () {
        expect(_format('', '1500000.99'), '1,500,000.99');
      });
    });

    group('formatEditUpdate — stripping non-numeric chars', () {
      test('dollar sign stripped', () {
        expect(_format('', r'$1500'), '1,500');
      });

      test('multiple commas re-formatted', () {
        // Simulates pasting "1,5,0,0"
        expect(_format('', '1,5,0,0'), '1,500');
      });
    });

    group('CurrencyInputFormatter.strip', () {
      test('strips commas from formatted value', () {
        expect(CurrencyInputFormatter.strip('1,500.00'), '1500.00');
      });

      test('strips commas from large value', () {
        expect(CurrencyInputFormatter.strip('1,000,000.50'), '1000000.50');
      });

      test('value without commas is unchanged', () {
        expect(CurrencyInputFormatter.strip('250.00'), '250.00');
      });

      test('trims whitespace', () {
        expect(CurrencyInputFormatter.strip('  500.00  '), '500.00');
      });

      test('empty string returns empty', () {
        expect(CurrencyInputFormatter.strip(''), '');
      });
    });
  });
}
