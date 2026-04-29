import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../../../domain/repositories/debt_repository.dart';
import '../../../../engine/interest_calculator.dart';
import '../../../../engine/validators.dart';
import '../../cubit/debts_cubit.dart';
import '../widgets/add_charge_sheet.dart';
import '../widgets/debt_detail_hero_card.dart';
import '../widgets/debt_info_row.dart';
import '../widgets/debt_options_sheet.dart';

class DebtDetailPage extends StatefulWidget {
  const DebtDetailPage({super.key, required this.id});

  final String id;

  @override
  State<DebtDetailPage> createState() => _DebtDetailPageState();
}

class _DebtDetailPageState extends State<DebtDetailPage> {
  late final DebtRepository _debtRepository;
  late Stream<Debt?> _debtStream;

  @override
  void initState() {
    super.initState();
    _debtRepository = getIt.get<DebtRepository>();
    _debtStream = _debtRepository.watchDebtById(widget.id);
  }

  @override
  void didUpdateWidget(covariant DebtDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _debtStream = _debtRepository.watchDebtById(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Debt?>(
      stream: _debtStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final debt = snapshot.data;
        if (debt == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.debtDetailTitle)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Text(
                  context.l10n.logPaymentNotFound,
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
            title: Text(context.l10n.debtDetailTitle),
            actions: [
              IconButton(
                key: AppTestKeys.debtDetailEdit,
                icon: const Icon(LucideIcons.pencil),
                onPressed: () => context.push(AppRoutes.editDebtPath(debt.id)),
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
                              context.l10n.debtDetailInfo,
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
                        label: context.l10n.debtDetailInitialPrincipal,
                        value: AppFormatters.formatCents(
                          debt.originalPrincipal,
                        ),
                      ),
                      Container(height: 1, color: AppColors.mdOutlineVariant),
                      DebtInfoRow(
                        icon: LucideIcons.percent,
                        label: context.l10n.debtDetailApr,
                        value: AppFormatters.formatApr(
                          double.parse(debt.apr.toString()),
                        ),
                      ),
                      Container(height: 1, color: AppColors.mdOutlineVariant),
                      DebtInfoRow(
                        icon: LucideIcons.calendarDays,
                        label: context.l10n.debtDetailDueDate,
                        value: context.l10n.homeDueDay(debt.dueDayOfMonth),
                      ),
                      Container(height: 1, color: AppColors.mdOutlineVariant),
                      DebtInfoRow(
                        icon: LucideIcons.wallet,
                        label: context.l10n.debtDetailMinimumPayment,
                        value: AppFormatters.formatCents(debt.minimumPayment),
                      ),
                      Container(height: 1, color: AppColors.mdOutlineVariant),
                      DebtInfoRow(
                        icon: LucideIcons.activity,
                        label: context.l10n.debtDetailInterestCalc,
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
                          context.l10n.debtDetailWarnings,
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
                        context.l10n.debtDetailTracking,
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.debtDetailTrackingHelper,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.filled(
                              key: AppTestKeys.debtDetailLogPayment,
                              label: context.l10n.debtDetailLogPayment,
                              icon: LucideIcons.plus,
                              onPressed: () => context.push(
                                AppRoutes.logPaymentPath(debt.id),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Expanded(
                            child: AppButton.outlined(
                              key: AppTestKeys.debtDetailPaymentHistory,
                              label: context.l10n.debtDetailViewHistory,
                              icon: LucideIcons.history,
                              onPressed: () => context.push(
                                AppRoutes.paymentHistoryPath(debt.id),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.text(
                              label: context.l10n.debtDetailRateHistory,
                              icon: LucideIcons.percent,
                              onPressed: () => context.push(
                                AppRoutes.rateHistoryPath(debt.id),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Expanded(
                            child: AppButton.text(
                              key: AppTestKeys.debtDetailAddCharge,
                              label: context.l10n.debtDetailAddCharge,
                              icon: LucideIcons.creditCard,
                              onPressed: () => AddChargeSheet.show(
                                context,
                                debt: debt,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),
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
      onEdit: () => context.push(AppRoutes.editDebtPath(debt.id)),
      onArchiveToggle: debt.status == DebtStatus.paidOff
          ? () => _archiveDebt(context, debt)
          : debt.status == DebtStatus.archived
          ? () => _unarchiveDebt(context, debt)
          : null,
      onPause: debt.status == DebtStatus.active
          ? () => _showPauseDialog(context, debt)
          : null,
      onResume: debt.status == DebtStatus.paused
          ? () => _resumeDebt(context, debt)
          : null,
      onDelete: () => _deleteDebt(context, debt),
    );
  }

  Future<void> _showPauseDialog(BuildContext context, Debt debt) async {
    int? selectedMonths;
    await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text(context.l10n.debtOptionsPause),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.debtPauseSelectDuration),
                const SizedBox(height: 16),
                DropdownMenu<int>(
                  initialSelection: 1,
                  onSelected: (value) {
                    setDialogState(() => selectedMonths = value);
                  },
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: 1, label: context.l10n.debtPause1Month),
                    DropdownMenuEntry(value: 2, label: context.l10n.debtPause2Months),
                    DropdownMenuEntry(value: 3, label: context.l10n.debtPause3Months),
                    DropdownMenuEntry(value: 6, label: context.l10n.debtPause6Months),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () {
                  if (selectedMonths != null) Navigator.pop(ctx, selectedMonths);
                },
                child: Text(context.l10n.commonConfirm),
              ),
            ],
          );
        },
      ),
    );

    if (selectedMonths == null || !context.mounted) return;

    final pausedUntil = DateTime.now().add(Duration(days: 30 * selectedMonths!));
    await context.read<DebtsCubit>().pauseDebt(debt, pausedUntil);
    
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.debtPausedMsg(AppFormatters.formatDate(pausedUntil)),
        ),
      ),
    );
  }

  Future<void> _resumeDebt(BuildContext context, Debt debt) async {
    await context.read<DebtsCubit>().resumeDebt(debt);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.debtResumedMsg)),
    );
  }

  Future<void> _archiveDebt(BuildContext context, Debt debt) async {
    final debtsCubit = context.read<DebtsCubit>();
    final confirmed = await _confirmAction(
      context,
      title: context.l10n.debtDetailArchiveTitle,
      message: context.l10n.debtDetailArchiveMessage,
      confirmLabel: context.l10n.debtDetailArchiveConfirm,
    );
    if (!confirmed || !context.mounted) return;

    await debtsCubit.archiveDebt(debt);
    if (!context.mounted) return;
    _showUndoSnackBar(
      messenger: ScaffoldMessenger.of(context),
      message: context.l10n.debtDetailArchivedMsg,
      undoLabel: context.l10n.commonUndo,
      onUndo: () {
        debtsCubit.updateDebt(debt.copyWith(updatedAt: DateTime.now().toUtc()));
      },
    );
  }

  Future<void> _unarchiveDebt(BuildContext context, Debt debt) async {
    await context.read<DebtsCubit>().unarchiveDebt(debt);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.debtDetailUnarchivedMsg)),
    );
  }

  Future<void> _deleteDebt(BuildContext context, Debt debt) async {
    final debtsCubit = context.read<DebtsCubit>();
    final confirmed = await _confirmAction(
      context,
      title: context.l10n.debtDetailDeleteTitle,
      message: context.l10n.debtDetailDeleteMessage,
      confirmLabel: context.l10n.debtDetailDeleteConfirm,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.debtDetailDeletedMsg;
    final undoLabel = context.l10n.commonUndo;
    await debtsCubit.deleteDebt(debt);
    if (!context.mounted) return;
    context.go(AppRoutes.debts);
    _showUndoSnackBar(
      messenger: messenger,
      message: message,
      undoLabel: undoLabel,
      onUndo: () => debtsCubit.restoreDebt(debt),
    );
  }

  void _showUndoSnackBar({
    required String message,
    required String undoLabel,
    required VoidCallback onUndo,
    required ScaffoldMessengerState messenger,
  }) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Row(
          children: [
            Expanded(child: Text(message)),
            TextButton(
              key: AppTestKeys.snackbarUndo,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mdInversePrimary,
              ),
              onPressed: () {
                messenger.hideCurrentSnackBar();
                onUndo();
              },
              child: Text(undoLabel),
            ),
          ],
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
              child: Text(context.l10n.commonCancel),
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
