import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/date_extensions.dart';
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
  const PaymentHistoryPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final DebtRepository _debtRepository = getIt.get<DebtRepository>();
  final PaymentRepository _paymentRepository = getIt.get<PaymentRepository>();
  String? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Debt?>(
      stream: _debtRepository.watchDebtById(widget.id),
      builder: (context, debtSnapshot) {
        final debt = debtSnapshot.data;
        if (debtSnapshot.connectionState == ConnectionState.waiting && debt == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return StreamBuilder<List<Payment>>(
          stream: _paymentRepository.watchPaymentsForDebt(widget.id),
          builder: (context, paymentsSnapshot) {
            final payments = paymentsSnapshot.data ?? const <Payment>[];
            final months = _availableMonths(payments);
            if (_selectedMonth == null && months.isNotEmpty) {
              _selectedMonth = months.first;
            }

            final visiblePayments = _selectedMonth == null
                ? payments
                : payments.where((payment) => payment.date.yearMonth == _selectedMonth).toList();

            return Scaffold(
              appBar: AppBar(title: const Text('Lịch sử thanh toán')),
              body: debt == null
                  ? const Center(
                      child: Text('Khoản nợ này không còn tồn tại hoặc đã bị xóa.'),
                    )
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
                                Text(debt.name, style: AppTextStyles.titleMedium),
                                const SizedBox(height: AppDimensions.xs),
                                Text(
                                  '${payments.length} payment đã log · Current balance ${AppFormatters.formatCents(debt.currentBalance)}',
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
                              'Theo tháng',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.mdOnSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            Wrap(
                              spacing: AppDimensions.sm,
                              runSpacing: AppDimensions.sm,
                              children: months.map(
                                (month) => AppChip.filter(
                                  key: AppTestKeys.paymentHistoryMonthChip(month),
                                  label: _formatYearMonth(month),
                                  selected: _selectedMonth == month,
                                  onTap: () => setState(() => _selectedMonth = month),
                                  icon: LucideIcons.calendarDays,
                                ),
                              ).toList(growable: false),
                            ),
                            const SizedBox(height: AppDimensions.sectionGap),
                          ],
                          if (visiblePayments.isEmpty)
                            const EmptyState(
                              title: 'Chưa có payment cho bộ lọc này',
                              subtitle:
                                  'Log payment từ debt detail hoặc Monthly Action View để thấy lịch sử thật.',
                              icon: LucideIcons.history,
                            )
                          else ...visiblePayments.map(
                            (payment) => Padding(
                              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                              child: DebtPaymentItem(
                                icon: _iconForPaymentType(payment.type),
                                iconColor: _iconColorForPaymentType(payment.type),
                                iconBgColor: AppColors.mdPrimaryContainer,
                                title: _titleForPaymentType(payment.type),
                                date: AppFormatters.formatDate(payment.date),
                                amount: AppFormatters.formatCents(payment.amount),
                                amountColor: AppColors.mdOnSurface,
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
    }.toList()
      ..sort((a, b) => b.compareTo(a));
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
    return AppColors.mdOnPrimaryContainer;
  }

  static String _titleForPaymentType(PaymentType type) {
    switch (type) {
      case PaymentType.minimum:
        return 'Minimum payment';
      case PaymentType.extra:
        return 'Extra payment';
      case PaymentType.lumpSum:
        return 'Lump-sum payment';
      case PaymentType.fee:
        return 'Fee adjustment';
      case PaymentType.refund:
        return 'Refund';
      case PaymentType.charge:
        return 'Charge';
    }
  }

  static String _formatYearMonth(String value) {
    final parts = value.split('-');
    return AppFormatters.formatShortMonthYear(
      DateTime(int.parse(parts[0]), int.parse(parts[1])),
    );
  }
}
