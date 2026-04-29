import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/monthly_summary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';

class MonthlySummaryPage extends StatefulWidget {
  const MonthlySummaryPage({super.key});

  @override
  State<MonthlySummaryPage> createState() => _MonthlySummaryPageState();
}

class _MonthlySummaryPageState extends State<MonthlySummaryPage> {
  late DateTime _month;
  late final MonthlySummaryService _service;
  MonthlySummaryData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _service = getIt<MonthlySummaryService>();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _service.getSummary(_month);
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  void _prevMonth() {
    setState(() => _month = DateTime(_month.year, _month.month - 1));
    _load();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_month.year, _month.month + 1);
    if (nextMonth.isAfter(DateTime(now.year, now.month))) return;
    setState(() => _month = nextMonth);
    _load();
  }

  bool get _canGoNext {
    final now = DateTime.now();
    return _month.isBefore(DateTime(now.year, now.month));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.monthlySummaryTitle),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _MonthNavigator(
            month: _month,
            onPrev: _prevMonth,
            onNext: _canGoNext ? _nextMonth : null,
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final data = _data;
    if (data == null || !data.hasActivity) {
      return _EmptyState();
    }
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: AppDimensions.pagePaddingV,
      ),
      children: [
        _TotalPaidCard(data: data),
        const SizedBox(height: AppDimensions.md),
        if (data.perDebt.isNotEmpty) ...[
          Text(
            context.l10n.monthlySummaryPerDebt,
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.sm),
          ...data.perDebt.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sm),
            child: _DebtSummaryCard(summary: s),
          )),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Month navigator
// ---------------------------------------------------------------------------

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: AppDimensions.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: onPrev,
          ),
          Expanded(
            child: Text(
              AppFormatters.formatMonthYear(month),
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight),
            onPressed: onNext,
            color: onNext != null ? null : AppColors.mdOutline,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Total paid card
// ---------------------------------------------------------------------------

class _TotalPaidCard extends StatelessWidget {
  const _TotalPaidCard({required this.data});
  final MonthlySummaryData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final variance = data.varianceCents;
    final hasVariance = data.plannedExtraCents > 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.monthlySummaryTotalPaid, style: AppTextStyles.labelMedium.copyWith(color: AppColors.mdOnSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            AppFormatters.formatCents(data.totalPaidCents),
            style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          if (hasVariance) ...[
            const SizedBox(height: 4),
            _VarianceChip(variance: variance),
          ],
          const Divider(height: AppDimensions.lg),
          Row(
            children: [
              Expanded(
                child: _BreakdownItem(
                  label: l10n.monthlySummaryPrincipal,
                  amount: data.totalPrincipalCents,
                  color: AppColors.mdPrimary,
                ),
              ),
              Expanded(
                child: _BreakdownItem(
                  label: l10n.monthlySummaryInterest,
                  amount: data.totalInterestCents,
                  color: AppColors.mdError,
                ),
              ),
              if (data.totalChargeCents > 0)
                Expanded(
                  child: _BreakdownItem(
                    label: l10n.monthlySummaryCharges,
                    amount: data.totalChargeCents,
                    color: AppColors.mdErrorContainer,
                    negative: true,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  const _BreakdownItem({
    required this.label,
    required this.amount,
    required this.color,
    this.negative = false,
  });

  final String label;
  final int amount;
  final Color color;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.mdOnSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${negative ? '+' : ''}${AppFormatters.formatCents(amount)}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: negative ? AppColors.mdError : null,
          ),
        ),
      ],
    );
  }
}

class _VarianceChip extends StatelessWidget {
  const _VarianceChip({required this.variance});
  final int variance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPositive = variance >= 0;
    final amtStr = AppFormatters.formatCents(variance.abs());
    final label = isPositive
        ? l10n.monthlySummaryPaidMore(amtStr)
        : l10n.monthlySummaryPaidLess(amtStr);

    return Row(
      children: [
        Icon(
          isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
          size: 14,
          color: isPositive ? AppColors.mdPrimary : AppColors.mdError,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isPositive ? AppColors.mdPrimary : AppColors.mdError,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Per-debt card
// ---------------------------------------------------------------------------

class _DebtSummaryCard extends StatelessWidget {
  const _DebtSummaryCard({required this.summary});
  final DebtMonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduction = summary.balanceBefore - summary.balanceAfter;

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.debt.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                if (reduction > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.monthlySummaryBalanceReduced(AppFormatters.formatCents(reduction)),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdPrimary),
                  ),
                ],
                if (summary.chargeCents > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+${AppFormatters.formatCents(summary.chargeCents)} ${l10n.monthlySummaryCharges.toLowerCase()}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdError),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.formatCents(summary.paidCents),
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'P: ${AppFormatters.formatCents(summary.principalCents)} · I: ${AppFormatters.formatCents(summary.interestCents)}',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.mdOnSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.calendarX2, size: 64, color: AppColors.mdOutline),
            const SizedBox(height: AppDimensions.md),
            Text(l10n.monthlySummaryNoActivity, style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.sm),
            Text(l10n.monthlySummaryNoActivitySub, style: AppTextStyles.bodySmall.copyWith(color: AppColors.mdOnSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
