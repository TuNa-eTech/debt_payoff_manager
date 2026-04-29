import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/payment.dart';
import '../../../../domain/enums/payment_type.dart';
import '../../../../domain/repositories/debt_repository.dart';
import '../../../../domain/repositories/payment_repository.dart';
import '../widgets/debt_payment_item.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key, required this.id});

  final String id;

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final DebtRepository _debtRepository = getIt.get<DebtRepository>();
  final PaymentRepository _paymentRepository = getIt.get<PaymentRepository>();
  late Stream<Debt?> _debtStream;
  late Stream<List<Payment>> _paymentsStream;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _debtStream = _debtRepository.watchDebtById(widget.id);
    _paymentsStream = _paymentRepository.watchPaymentsForDebt(widget.id);
  }

  @override
  void didUpdateWidget(covariant PaymentHistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _debtStream = _debtRepository.watchDebtById(widget.id);
      _paymentsStream = _paymentRepository.watchPaymentsForDebt(widget.id);
      _selectedMonth = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Debt?>(
      stream: _debtStream,
      builder: (context, debtSnapshot) {
        final debt = debtSnapshot.data;
        if (debtSnapshot.connectionState == ConnectionState.waiting &&
            debt == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return StreamBuilder<List<Payment>>(
          stream: _paymentsStream,
          builder: (context, paymentsSnapshot) {
            final payments = paymentsSnapshot.data ?? const <Payment>[];
            final months = _availableMonths(payments);
            if (_selectedMonth == null && months.isNotEmpty) {
              _selectedMonth = months.first;
            }

            final visiblePayments = _selectedMonth == null
                ? payments
                : payments
                      .where(
                        (payment) => payment.date.yearMonth == _selectedMonth,
                      )
                      .toList();

            return Scaffold(
              appBar: AppBar(title: Text(context.l10n.paymentHistoryTitle)),
              body: debt == null
                  ? Center(child: Text(context.l10n.logPaymentNotFound))
                  : SafeArea(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.pagePaddingH,
                          vertical: AppDimensions.pagePaddingV,
                        ),
                        children: [
                          AppCard(
                            color: AppColors.mdSurfaceContainerLow,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  debt.name,
                                  style: AppTextStyles.titleMedium,
                                ),
                                const SizedBox(height: AppDimensions.xs),
                                Text(
                                  context.l10n.paymentHistorySubtitle(
                                    payments.length,
                                    AppFormatters.formatCents(
                                      debt.currentBalance,
                                    ),
                                  ),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.mdOnSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sectionGap),
                          if (months.isNotEmpty) ...[
                            Text(
                              context.l10n.paymentHistoryByMonth,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.mdOnSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            Wrap(
                              spacing: AppDimensions.sm,
                              runSpacing: AppDimensions.sm,
                              children: months
                                  .map(
                                    (month) => AppChip.filter(
                                      key: AppTestKeys.paymentHistoryMonthChip(
                                        month,
                                      ),
                                      label: _formatYearMonth(month),
                                      selected: _selectedMonth == month,
                                      onTap: () => setState(
                                        () => _selectedMonth = month,
                                      ),
                                      icon: LucideIcons.calendarDays,
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                            const SizedBox(height: AppDimensions.sectionGap),
                          ],
                          if (visiblePayments.isEmpty)
                            EmptyState(
                              title: context.l10n.paymentHistoryNoPayments,
                              subtitle:
                                  context.l10n.paymentHistoryNoPaymentsSubtitle,
                              icon: LucideIcons.history,
                            )
                          else
                            ...visiblePayments.map(
                              (payment) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppDimensions.sm,
                                ),
                                child: DebtPaymentItem(
                                  icon: _iconForPaymentType(payment.type),
                                  iconColor: _iconColorForPaymentType(
                                    payment.type,
                                  ),
                                  iconBgColor: _iconBgColorForPaymentType(
                                    payment.type,
                                  ),
                                  title: _titleForPaymentType(
                                    context,
                                    payment.type,
                                  ),
                                  note: payment.note,
                                  date: AppFormatters.formatDate(payment.date),
                                  amount: AppFormatters.formatCents(
                                    payment.amount,
                                  ),
                                  amountColor: _amountColorForPaymentType(
                                    payment.type,
                                  ),
                                  type: payment.source.label,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  List<String> _availableMonths(List<Payment> payments) {
    final months = {
      for (final payment in payments) payment.date.yearMonth,
    }.toList()..sort((a, b) => b.compareTo(a));
    return months;
  }

  static IconData _iconForPaymentType(PaymentType type) {
    switch (type) {
      case PaymentType.minimum:
        return LucideIcons.wallet;
      case PaymentType.extra:
        return LucideIcons.zap;
      case PaymentType.lumpSum:
        return LucideIcons.badgeDollarSign;
      case PaymentType.fee:
        return LucideIcons.receipt;
      case PaymentType.refund:
        return LucideIcons.rotateCcw;
      case PaymentType.charge:
        return LucideIcons.plusCircle;
    }
  }

  static Color _iconColorForPaymentType(PaymentType type) {
    if (type == PaymentType.extra || type == PaymentType.lumpSum) {
      return AppColors.mdPrimary;
    }
    if (type == PaymentType.charge || type == PaymentType.fee) {
      return AppColors.mdError;
    }
    return AppColors.mdOnPrimaryContainer;
  }

  static Color _iconBgColorForPaymentType(PaymentType type) {
    if (type == PaymentType.charge || type == PaymentType.fee) {
      return AppColors.mdErrorContainer;
    }
    return AppColors.mdPrimaryContainer;
  }

  static Color _amountColorForPaymentType(PaymentType type) {
    if (type == PaymentType.charge || type == PaymentType.fee) {
      return AppColors.mdError;
    }
    return AppColors.mdOnSurface;
  }

  static String _titleForPaymentType(BuildContext context, PaymentType type) {
    switch (type) {
      case PaymentType.minimum:
        return context.l10n.paymentTypeMinimumLabel;
      case PaymentType.extra:
        return context.l10n.paymentTypeExtraLabel;
      case PaymentType.lumpSum:
        return context.l10n.paymentTypeLumpSumLabel;
      case PaymentType.fee:
        return context.l10n.paymentTypeFeeLabel;
      case PaymentType.refund:
        return context.l10n.paymentTypeRefundLabel;
      case PaymentType.charge:
        return context.l10n.paymentTypeChargeLabel;
    }
  }

  static String _formatYearMonth(String value) {
    final parts = value.split('-');
    return AppFormatters.formatShortMonthYear(
      DateTime(int.parse(parts[0]), int.parse(parts[1])),
    );
  }
}
