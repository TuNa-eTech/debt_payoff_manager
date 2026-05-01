import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/i18n/strategy_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/debt_card.dart' as design_system;
import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/plan.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../../debts/presentation/debt_ui_utils.dart';
import '../../../../l10n/app_localizations.dart';

class HomePopulatedView extends StatelessWidget {
  const HomePopulatedView({super.key, required this.debts, required this.plan});

  final List<Debt> debts;
  final Plan? plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trackedDebts =
        debts.where((debt) => debt.status != DebtStatus.archived).toList()
          ..sort((a, b) => b.currentBalance.compareTo(a.currentBalance));
    final totalOriginal = trackedDebts.fold<int>(
      0,
      (sum, debt) => sum + debt.originalPrincipal,
    );
    final totalBalance = trackedDebts.fold<int>(
      0,
      (sum, debt) => sum + debt.currentBalance,
    );
    final totalPaid = (totalOriginal - totalBalance).clamp(0, totalOriginal);
    final progress = totalOriginal == 0 ? 0.0 : totalPaid / totalOriginal;
    final paidOffCount = trackedDebts
        .where((debt) => debt.status == DebtStatus.paidOff)
        .length;
    final pausedCount = trackedDebts
        .where((debt) => debt.status == DebtStatus.paused)
        .length;
    final focusDebts = trackedDebts.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: AppDimensions.pagePaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppHeroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeTotalBalanceLabel,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.mdPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  AppFormatters.formatCents(totalBalance),
                  style: AppTextStyles.moneyLarge.copyWith(
                    color: AppColors.mdOnPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Row(
                  children: [
                    Expanded(
                      child: _HeroStat(
                        label: l10n.homeStrategyLabel,
                        value:
                            plan?.strategy.localizedLabel(l10n) ??
                            l10n.settingsStrategySnowball,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: _HeroStat(
                        label: l10n.homeExtraMonthlyLabel,
                        value: AppFormatters.formatCents(
                          plan?.extraMonthlyAmount ?? 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.homePaidProgress(
                          AppFormatters.formatCents(totalPaid),
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mdOnPrimary.withValues(alpha: 0.82),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.mdPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  color: AppColors.mdPrimaryContainer,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sectionGap),
          AppCard(
            color: AppColors.mdSurfaceContainerLow,
            child: Row(
              children: [
                Expanded(
                  child: _SummaryStat(
                    label: l10n.homeTrackingCountLabel,
                    value:
                        '${trackedDebts.where((debt) => debt.currentBalance > 0).length}',
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _SummaryStat(
                    label: l10n.homePaidOffCountLabel,
                    value: '$paidOffCount',
                    valueColor: AppColors.mdPrimary,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _SummaryStat(
                    label: l10n.homePausedCountLabel,
                    value: '$pausedCount',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sectionGap),
          SectionHeader(
            title: l10n.homeDebtsToTrackTitle,
            subtitle: l10n.homeDebtsToTrackSubtitle,
            trailingLabel: l10n.commonViewAll,
            onTrailingTap: () => context.go(AppRoutes.debts),
          ),
          const SizedBox(height: AppDimensions.md),
          ...focusDebts.map(
            (debt) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.md),
              child: design_system.DebtCard(
                name: debt.name,
                balance: AppFormatters.formatCents(debt.currentBalance),
                apr: AppFormatters.formatApr(double.parse(debt.apr.toString())),
                minPayment: AppFormatters.formatCents(debt.minimumPayment),
                dueDate: debt.status == DebtStatus.paused
                    ? l10n.debtStatusPaused
                    : l10n.debtDueDay(debt.dueDayOfMonth),
                state: debt.status == DebtStatus.paidOff
                    ? design_system.DebtCardState.paid
                    : design_system.DebtCardState.normal,
                debtTypeIcon: debtTypeIcon(debt.type),
                onTap: () => context.push(AppRoutes.debtDetailPath(debt.id)),
              ),
            ),
          ),
          if (focusDebts.isEmpty)
            AppCard(
              color: AppColors.mdSurfaceContainerLow,
              child: Text(
                l10n.homeNoDebtsToTrackMessage,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          const SizedBox(height: AppDimensions.sectionGap),
          AppCard(
            color: AppColors.mdSurfaceContainerLow,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  size: AppDimensions.iconMd,
                  color: AppColors.mdPrimary,
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeTimelineConnectingTitle,
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        l10n.homeTimelineConnectingSubtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mdOnSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      SizedBox(
                        width: 180,
                        child: AppButton.tonal(
                          label: l10n.homeOpenPlanTabButton,
                          icon: LucideIcons.arrowRight,
                          onPressed: () => context.go(AppRoutes.plan),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.mdPrimaryContainer,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.mdOnPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: valueColor ?? AppColors.mdOnSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      color: AppColors.mdOutlineVariant,
    );
  }
}
