import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../extensions/context_extensions.dart';
import '../i18n/app_locale.dart';
import '../utils/formatters.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Formats and displays a monetary amount with the correct typography.
///
/// Example:
/// ```dart
/// MoneyText(amount: 4800.0)                          // $4,800.00
/// MoneyText.large(amount: 18400.0)                   // large money display
/// MoneyText(amount: -120.0, showSign: true)          // -$120.00 in red
/// MoneyText(amount: 200.0, isPositive: true)         // +$200.00 in green
/// ```
class MoneyText extends StatelessWidget {
  const MoneyText({
    super.key,
    required this.amount,
    this.currency,
    this.locale,
    this.style,
    this.color,
    this.showSign = false,
    this.isPositive,
    this.compact = false,
  }) : _size = _MoneySize.medium;

  const MoneyText._sized({
    super.key,
    required this.amount,
    this.currency,
    this.color,
    this.showSign = false,
    this.isPositive,
    this.compact = false,
    required _MoneySize size,
  }) : _size = size,
       locale = null,
       style = null;

  factory MoneyText.large({
    Key? key,
    required double amount,
    String? currency,
    Color? color,
    bool showSign = false,
    bool? isPositive,
    bool compact = false,
  }) => MoneyText._sized(
    key: key,
    amount: amount,
    currency: currency,
    color: color,
    showSign: showSign,
    isPositive: isPositive,
    compact: compact,
    size: _MoneySize.large,
  );

  factory MoneyText.small({
    Key? key,
    required double amount,
    String? currency,
    Color? color,
    bool showSign = false,
    bool? isPositive,
    bool compact = false,
  }) => MoneyText._sized(
    key: key,
    amount: amount,
    currency: currency,
    color: color,
    showSign: showSign,
    isPositive: isPositive,
    compact: compact,
    size: _MoneySize.small,
  );

  final double amount;
  final String? currency;
  final String? locale;
  final TextStyle? style;
  final Color? color;
  final bool showSign;
  final bool? isPositive;
  final bool compact;
  final _MoneySize _size;

  @override
  Widget build(BuildContext context) {
    final userSettings = context.userSettings;
    final effectiveCurrency = currency ?? userSettings?.currencyCode ?? 'USD';
    final effectiveLocale = locale ?? userSettings?.localeCode ?? 'en_US';

    final effectiveColor = color ?? _semanticColor();
    final baseStyle = _baseStyle();
    final formatted = _format(effectiveCurrency, effectiveLocale);

    return Text(
      formatted,
      style: (style ?? baseStyle).copyWith(color: effectiveColor),
    );
  }

  String _format(String effectiveCurrency, String effectiveLocale) {
    final NumberFormat fmt = compact
        ? NumberFormat.compactCurrency(
            symbol: AppFormatters.currencySymbolFor(effectiveCurrency),
            locale: AppLocale.intlFormatTag(effectiveLocale),
          )
        : NumberFormat.currency(
            symbol: AppFormatters.currencySymbolFor(effectiveCurrency),
            locale: AppLocale.intlFormatTag(effectiveLocale),
            decimalDigits: effectiveCurrency.toUpperCase() == 'VND' ? 0 : 2,
          );

    final str = fmt.format(amount.abs());
    if (showSign) {
      return amount >= 0 ? '+$str' : '-$str';
    }
    if (amount < 0) return '-$str';
    return str;
  }

  Color? _semanticColor() {
    if (isPositive == true) return AppColors.paidGreen;
    if (isPositive == false) return AppColors.debtRed;
    return null;
  }

  TextStyle _baseStyle() {
    return switch (_size) {
      _MoneySize.large => AppTextStyles.moneyLarge,
      _MoneySize.medium => AppTextStyles.moneyMedium,
      _MoneySize.small => AppTextStyles.moneySmall,
    };
  }
}

enum _MoneySize { large, medium, small }
