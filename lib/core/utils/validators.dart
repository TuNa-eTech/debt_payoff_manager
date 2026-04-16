import 'package:decimal/decimal.dart';

import '../constants/app_constants.dart';
import '../constants/financial_constants.dart';

/// Input validation helpers.
///
/// Reference: financial-engine-spec.md §11 (Validation & Sanity Checks)
class Validators {
  Validators._();

  /// Validate debt name: non-empty, max 60 chars.
  static String? validateDebtName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Debt name is required';
    }
    if (value.length > AppConstants.maxDebtNameLength) {
      return 'Name must be ${AppConstants.maxDebtNameLength} characters or less';
    }
    return null;
  }

  /// Validate balance: must be positive.
  static String? validateBalance(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Balance is required';
    }
    final amount = Decimal.tryParse(value);
    if (amount == null || amount <= Decimal.zero) {
      return 'Enter a valid positive amount';
    }
    return null;
  }

  /// Validate APR: 0% ≤ APR ≤ 100%.
  ///
  /// Per spec §1: "Validate range: 0% ≤ APR ≤ 100%.
  /// APR > 36% cảnh báo (usury). APR = 0% cho phép (promo rate)"
  static String? validateApr(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'APR is required';
    }
    final apr = Decimal.tryParse(value);
    if (apr == null) return 'Enter a valid number';
    if (apr < Decimal.zero) return 'APR cannot be negative';

    // Convert from user input (percent) to decimal
    final aprDecimal = (apr / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 10);
    if (aprDecimal > FinancialConstants.maxApr) {
      return 'APR cannot exceed 100%';
    }
    return null;
  }

  /// Check if APR triggers usury warning (> 36%).
  static bool isUsuryWarning(Decimal aprDecimal) {
    return aprDecimal > FinancialConstants.usuryWarningThreshold;
  }

  /// Validate minimum payment: must be >= 0.
  static String? validateMinPayment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Minimum payment is required';
    }
    final amount = Decimal.tryParse(value);
    if (amount == null || amount < Decimal.zero) {
      return 'Enter a valid amount';
    }
    return null;
  }

  /// Validate payment note: max 200 chars.
  static String? validatePaymentNote(String? value) {
    if (value != null && value.length > AppConstants.maxPaymentNoteLength) {
      return 'Note must be ${AppConstants.maxPaymentNoteLength} characters or less';
    }
    return null;
  }

  /// Validate extra monthly amount: must be >= 0.
  static String? validateExtraAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final amount = Decimal.tryParse(value);
    if (amount == null || amount < Decimal.zero) {
      return 'Enter a valid amount';
    }
    return null;
  }
}
