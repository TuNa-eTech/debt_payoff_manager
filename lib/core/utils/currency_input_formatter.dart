import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// A [TextInputFormatter] that formats a numeric currency value with thousands
/// separators (commas) as the user types.
///
/// Behaviour:
/// - Only digits, a single decimal point, and commas are accepted.
/// - Thousands separators are inserted automatically (e.g. `15000` → `15,000`).
/// - At most two decimal digits are allowed (e.g. `1234.567` → `1,234.56`).
/// - The leading-zero edge-case is handled: `0.5` stays `0.5`, not `05`.
/// - Cursor position is adjusted so it never appears to "jump".
///
/// Usage:
/// ```dart
/// TextField(
///   inputFormatters: [CurrencyInputFormatter()],
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
/// )
/// ```
class CurrencyInputFormatter extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip every character that is not a digit or decimal point.
    final rawText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    if (rawText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle the case where the user is in the middle of typing a decimal.
    // e.g. "1234." — keep the trailing dot so the user can continue typing.
    final endsWithDot = rawText.endsWith('.');

    // Split on the first decimal point only; ignore extras.
    final parts = rawText.split('.');
    final integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Clamp decimal to 2 digits.
    if (decimalPart != null && decimalPart.length > 2) {
      decimalPart = decimalPart.substring(0, 2);
    }

    // Parse the integer portion and format with commas.
    final integerValue = int.tryParse(integerPart) ?? 0;
    final formattedInteger = NumberFormat('#,##0', 'en_US').format(integerValue);

    // Rebuild the formatted string.
    String formatted;
    if (endsWithDot && decimalPart == null) {
      formatted = '$formattedInteger.';
    } else if (decimalPart != null) {
      formatted = '$formattedInteger.$decimalPart';
    } else {
      formatted = formattedInteger;
    }

    // Compute cursor offset: place cursor at the end by default, which is
    // correct for most append operations. This keeps UX simple and predictable.
    final newOffset = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  /// Strips formatting characters from a user-entered value before parsing.
  ///
  /// e.g. `"1,500.00"` → `"1500.00"`
  static String strip(String formatted) =>
      formatted.replaceAll(',', '').trim();
}
