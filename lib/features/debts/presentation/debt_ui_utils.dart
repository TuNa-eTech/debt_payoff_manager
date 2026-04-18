import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/debt.dart';
import '../../../domain/enums/debt_status.dart';
import '../../../domain/enums/debt_type.dart';

IconData debtTypeIcon(DebtType type) {
  switch (type) {
    case DebtType.creditCard:
      return LucideIcons.creditCard;
    case DebtType.studentLoan:
      return LucideIcons.graduationCap;
    case DebtType.carLoan:
      return LucideIcons.car;
    case DebtType.mortgage:
      return LucideIcons.home;
    case DebtType.personal:
      return LucideIcons.wallet;
    case DebtType.medical:
      return LucideIcons.heartPulse;
    case DebtType.other:
      return LucideIcons.circleEllipsis;
  }
}

Color debtTypeColor(DebtType type) {
  switch (type) {
    case DebtType.creditCard:
      return const Color(0xFF1B6B4A);
    case DebtType.studentLoan:
      return const Color(0xFF3F5AA6);
    case DebtType.carLoan:
      return const Color(0xFF8A4B14);
    case DebtType.mortgage:
      return const Color(0xFF5A3E9A);
    case DebtType.personal:
      return const Color(0xFF00677F);
    case DebtType.medical:
      return const Color(0xFFBA1A1A);
    case DebtType.other:
      return const Color(0xFF5C5F5B);
  }
}

String debtStatusLabel(DebtStatus status) {
  switch (status) {
    case DebtStatus.active:
      return 'Đang theo dõi';
    case DebtStatus.paidOff:
      return 'Đã trả xong';
    case DebtStatus.archived:
      return 'Đã lưu trữ';
    case DebtStatus.paused:
      return 'Tạm dừng';
  }
}

String debtSubtitle(Debt debt) {
  final aprText = AppFormatters.formatApr(double.parse(debt.apr.toString()));
  switch (debt.status) {
    case DebtStatus.active:
      return 'APR $aprText · Hạn ngày ${debt.dueDayOfMonth}';
    case DebtStatus.paused:
      return 'Tạm dừng đến ${_formatLocalDate(debt.pausedUntil)}';
    case DebtStatus.paidOff:
      return 'Đã trả xong';
    case DebtStatus.archived:
      return 'Đã lưu trữ';
  }
}

double debtProgress(Debt debt) {
  if (debt.originalPrincipal <= 0) return 0;
  final progress =
      1 - (debt.currentBalance / debt.originalPrincipal.toDouble());
  return progress.clamp(0.0, 1.0);
}

String debtBalanceText(Debt debt) =>
    AppFormatters.formatCents(debt.currentBalance);

String debtOriginalPrincipalText(Debt debt) =>
    AppFormatters.formatCents(debt.originalPrincipal);

String _formatLocalDate(DateTime? value) {
  if (value == null) return 'chưa đặt';
  return AppFormatters.formatDate(value);
}
