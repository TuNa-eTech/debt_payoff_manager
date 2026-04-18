import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../../../domain/repositories/debt_repository.dart';
import '../../../../engine/interest_calculator.dart';
import '../../../../engine/validators.dart';
import '../../cubit/debts_cubit.dart';
import '../widgets/debt_detail_hero_card.dart';
import '../widgets/debt_info_row.dart';
import '../widgets/debt_options_sheet.dart';

class DebtDetailPage extends StatelessWidget {
  const DebtDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final debtRepository = getIt.get<DebtRepository>();
    return StreamBuilder<Debt?>(
      stream: debtRepository.watchDebtById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final debt = snapshot.data;
        if (debt == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết khoản nợ')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Text(
                  'Khoản nợ này không còn tồn tại hoặc đã bị xóa.',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          key: AppTestKeys.debtDetail(debt.id),
          appBar: AppBar(
            title: const Text('Chi tiết khoản nợ'),
            actions: [
              IconButton(
                key: AppTestKeys.debtDetailEdit,
                icon: const Icon(LucideIcons.pencil),
                onPressed: () => context.go(AppRoutes.editDebtPath(debt.id)),
              ),
              IconButton(
                key: AppTestKeys.debtDetailMore,
                icon: const Icon(LucideIcons.moreVertical),
                onPressed: () => _openOptions(context, debt),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePaddingH,
              vertical: AppDimensions.pagePaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DebtDetailHeroCard(debt: debt),
                const SizedBox(height: AppDimensions.sectionGap),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.mdSurfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        child: Row(
                          children: [
                            Text(
                              'Thông tin khoản nợ',
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: AppColors.mdOutlineVariant),
                      DebtInfoRow(
                        icon: LucideIcons.badgeDollarSign,
                        label: 'Số gốc ban đầu',
                        value: AppFormatters.formatCents(
                          debt.originalPrincipal,
                        ),
                      ),
                      Container(height: 1, color: AppColors.mdOutlineVariant),
                      DebtInfoRow(
                        icon: LucideIcons.percent,
                        label: 'APR',
                        value: AppFormatters.formatApr(
                          double.parse(debt.apr.toString()),
                        ),
                      ),
                      Container(height: 1, color: AppColors.mdOutlineVariant),
                      DebtInfoRow(
                        icon: LucideIcons.calendarDays,
                        label: 'Ngày đến hạn',
                        value: 'Ngày ${debt.dueDayOfMonth} mỗi tháng',
                      ),
                      Container(height: 1, color: AppColors.mdOutlineVariant),
                      DebtInfoRow(
                        icon: LucideIcons.wallet,
                        label: 'Minimum payment',
                        value: AppFormatters.formatCents(debt.minimumPayment),
                      ),
                      Container(height: 1, color: AppColors.mdOutlineVariant),
                      DebtInfoRow(
                        icon: LucideIcons.activity,
                        label: 'Cách tính lãi',
                        value: debt.interestMethod.label,
                      ),
                    ],
                  ),
                ),
                if (_buildWarnings(debt).isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.sectionGap),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: AppColors.mdPrimaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lưu ý dữ liệu',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.mdOnPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._buildWarnings(debt).map(
                          (warning) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '• $warning',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mdOnPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.sectionGap),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.mdSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: AppColors.mdOutlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theo dõi thanh toán',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhật ký thanh toán và lịch sử giao dịch chưa được bật ở UI hiện tại. Màn này chỉ hiển thị dữ liệu khoản nợ thật để tránh gây hiểu lầm bằng số liệu giả.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _buildWarnings(Debt debt) {
    final monthlyInterest = InterestCalculator.computeMonthlyInterest(
      balanceCents: debt.currentBalance,
      apr: debt.apr,
      method: debt.interestMethod,
    );
    return FinancialValidators.generateWarnings(
      currentBalanceCents: debt.currentBalance,
      originalPrincipalCents: debt.originalPrincipal,
      apr: debt.apr,
      minimumPaymentCents: debt.minimumPayment,
      monthlyInterestCents: monthlyInterest,
    );
  }

  Future<void> _openOptions(BuildContext context, Debt debt) {
    return DebtOptionsSheet.show(
      context,
      debt: debt,
      onEdit: () => context.go(AppRoutes.editDebtPath(debt.id)),
      onArchiveToggle: debt.status == DebtStatus.paidOff
          ? () => _archiveDebt(context, debt)
          : debt.status == DebtStatus.archived
          ? () => _unarchiveDebt(context, debt)
          : null,
      onDelete: () => _deleteDebt(context, debt),
    );
  }

  Future<void> _archiveDebt(BuildContext context, Debt debt) async {
    final debtsCubit = context.read<DebtsCubit>();
    final confirmed = await _confirmAction(
      context,
      title: 'Lưu trữ khoản nợ?',
      message:
          'Khoản nợ đã trả xong này sẽ được chuyển sang danh sách lưu trữ.',
      confirmLabel: 'Lưu trữ',
    );
    if (!confirmed || !context.mounted) return;

    await debtsCubit.archiveDebt(debt);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu trữ khoản nợ.'),
        action: SnackBarAction(
          key: AppTestKeys.snackbarUndo,
          label: 'Hoàn tác',
          onPressed: () {
            debtsCubit.updateDebt(
              debt.copyWith(updatedAt: DateTime.now().toUtc()),
            );
          },
        ),
      ),
    );
  }

  Future<void> _unarchiveDebt(BuildContext context, Debt debt) async {
    await context.read<DebtsCubit>().unarchiveDebt(debt);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đưa khoản nợ trở lại danh sách đã trả.'),
      ),
    );
  }

  Future<void> _deleteDebt(BuildContext context, Debt debt) async {
    final debtsCubit = context.read<DebtsCubit>();
    final confirmed = await _confirmAction(
      context,
      title: 'Xóa khoản nợ?',
      message:
          'Khoản nợ sẽ bị ẩn khỏi app, nhưng bạn vẫn có thể khôi phục ngay sau khi xóa.',
      confirmLabel: 'Xóa',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    await debtsCubit.deleteDebt(debt);
    if (!context.mounted) return;
    context.go(AppRoutes.debts);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Đã xóa khoản nợ.'),
        action: SnackBarAction(
          key: AppTestKeys.snackbarUndo,
          label: 'Hoàn tác',
          onPressed: () => debtsCubit.restoreDebt(debt),
        ),
      ),
    );
  }

  Future<bool> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              key: AppTestKeys.dialogConfirmPrimary,
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: isDestructive
                    ? AppColors.mdError
                    : AppColors.mdPrimary,
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
