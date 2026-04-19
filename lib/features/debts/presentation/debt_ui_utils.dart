import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
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
      return AppColors.mdPrimary;
    case DebtType.studentLoan:
      return AppColors.mdTertiary;
    case DebtType.carLoan:
      return AppColors.interestAmber;
    case DebtType.mortgage:
      return AppColors.mdSecondary;
    case DebtType.personal:
      return AppColors.info;
    case DebtType.medical:
      return AppColors.mdError;
    case DebtType.other:
      return AppColors.mdOnSurfaceVariant;
  }
}

String debtTypeDisplayName(DebtType type) {
  switch (type) {
    case DebtType.creditCard:
      return 'Thẻ tín dụng';
    case DebtType.studentLoan:
      return 'Vay học tập';
    case DebtType.carLoan:
      return 'Vay mua xe';
    case DebtType.mortgage:
      return 'Thế chấp';
    case DebtType.personal:
      return 'Vay cá nhân';
    case DebtType.medical:
      return 'Nợ y tế';
    case DebtType.other:
      return 'Khoản nợ khác';
  }
}

String debtStatusLabel(DebtStatus status, {Debt? debt, DateTime? now}) {
  if (debt != null && isDebtOverdue(debt, now: now)) {
    return 'Quá hạn';
  }

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

String debtSubtitle(Debt debt, {DateTime? now}) {
  final aprText = AppFormatters.formatApr(double.parse(debt.apr.toString()));
  final overdueDays = debtOverdueDays(debt, now: now);
  switch (debt.status) {
    case DebtStatus.active:
      if (overdueDays > 0) {
        final overdueLabel = overdueDays == 1
            ? 'Quá hạn 1 ngày'
            : 'Quá hạn $overdueDays ngày';
        return '$overdueLabel · APR $aprText · Hạn ngày ${debt.dueDayOfMonth}';
      }
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

bool isDebtOverdue(Debt debt, {DateTime? now}) {
  return debtOverdueDays(debt, now: now) > 0;
}

int debtOverdueDays(Debt debt, {DateTime? now}) {
  if (debt.status != DebtStatus.active || debt.currentBalance <= 0) {
    return 0;
  }

  final referenceDate = _dateOnly((now ?? DateTime.now()).toLocal());
  final firstDueDate = _dateOnly(debt.firstDueDate.toLocal());
  if (referenceDate.isBefore(firstDueDate)) {
    return 0;
  }

  final dueDate = DateTime(
    referenceDate.year,
    referenceDate.month,
    _clampDay(referenceDate.year, referenceDate.month, debt.dueDayOfMonth),
  );

  if (!referenceDate.isAfter(dueDate)) {
    return 0;
  }

  return referenceDate.difference(dueDate).inDays;
}

String _formatLocalDate(DateTime? value) {
  if (value == null) return 'chưa đặt';
  return AppFormatters.formatDate(value);
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

int _clampDay(int year, int month, int desiredDay) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return desiredDay.clamp(1, lastDay);
}
