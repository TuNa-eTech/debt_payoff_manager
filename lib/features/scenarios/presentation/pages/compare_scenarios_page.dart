import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/plan_recast_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/plan.dart';
import '../../../../domain/entities/scenario.dart';
import '../../../../domain/entities/scenario_assumption.dart';
import '../../../../domain/entities/user_settings.dart';
import '../../../../domain/enums/debt_status.dart';
import '../../../../domain/repositories/debt_repository.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../../domain/repositories/scenario_assumption_repository.dart';
import '../../../../domain/repositories/scenario_repository.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../../engine/strategy_sorter.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _ScenarioSnapshot {
  const _ScenarioSnapshot({
    required this.scenario,
    required this.debtCount,
    required this.totalBalance,
    required this.monthlyCommitment,
    required this.assumptions,
    this.plan,
    this.firstTargetDebt,
  });

  final Scenario scenario;
  final int debtCount;
  final int totalBalance; // cents
  final int monthlyCommitment; // cents
  final List<ScenarioAssumption> assumptions;
  final Plan? plan;
  final Debt? firstTargetDebt;

  DateTime? get debtFreeDate => plan?.projectedDebtFreeDate;
  int? get projectedInterest => plan?.totalInterestProjected;
  int? get savedVsMinimum => plan?.totalInterestSaved;
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class CompareScenariosPage extends StatefulWidget {
  const CompareScenariosPage({super.key});

  @override
  State<CompareScenariosPage> createState() => _CompareScenariosPageState();
}

class _CompareScenariosPageState extends State<CompareScenariosPage> {
  late final ScenarioRepository _scenarioRepo = getIt<ScenarioRepository>();
  late final DebtRepository _debtRepo = getIt<DebtRepository>();
  late final PlanRepository _planRepo = getIt<PlanRepository>();
  late final SettingsRepository _settingsRepo = getIt<SettingsRepository>();
  late final ScenarioAssumptionRepository _assumptionRepo =
      getIt<ScenarioAssumptionRepository>();
  late final PlanRecastService? _planRecastService =
      getIt.isRegistered<PlanRecastService>()
      ? getIt<PlanRecastService>()
      : null;

  List<Scenario> _scenarios = [];
  Scenario? _selectedA;
  Scenario? _selectedB;
  _ScenarioSnapshot? _snapA;
  _ScenarioSnapshot? _snapB;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    final list = await _scenarioRepo.getAllScenarios();
    final settings = await _settingsRepo.getSettings();
    if (!mounted) return;
    if (list.isEmpty) {
      setState(() => _scenarios = list);
      return;
    }

    final baseline = _findScenarioOrFirst(list, settings.activeScenarioId);
    final comparison = await _preferredComparisonScenario(list, baseline.id);
    if (!mounted) return;
    setState(() {
      _scenarios = list;
      _selectedA = baseline;
      _selectedB = comparison;
    });
    await _loadSnapshot('a', baseline);
    if (comparison != null) await _loadSnapshot('b', comparison);
  }

  Scenario _findScenarioOrFirst(List<Scenario> scenarios, String id) {
    for (final scenario in scenarios) {
      if (scenario.id == id) return scenario;
    }
    return scenarios.first;
  }

  Future<Scenario?> _preferredComparisonScenario(
    List<Scenario> scenarios,
    String baselineId,
  ) async {
    for (final scenario in scenarios.reversed) {
      if (scenario.id == baselineId) continue;
      final assumptions = await _assumptionRepo.getByScenario(scenario.id);
      if (assumptions.isNotEmpty) return scenario;
    }

    for (final scenario in scenarios) {
      if (scenario.id != baselineId) return scenario;
    }
    return null;
  }

  Future<void> _loadSnapshot(String slot, Scenario scenario) async {
    setState(() => _loading = true);
    try {
      final debts = await _debtRepo.getAllDebts(scenarioId: scenario.id);
      final assumptions = await _assumptionRepo.getByScenario(scenario.id);
      var plan = await _planRepo.getCurrentPlan(scenarioId: scenario.id);
      if (_isStale(plan)) {
        final recast = await _planRecastService?.recast(
          scenarioId: scenario.id,
        );
        plan = recast?.plan ?? plan;
      }
      final totalBalance = debts.fold(0, (sum, d) => sum + d.currentBalance);
      final snap = _ScenarioSnapshot(
        scenario: scenario,
        debtCount: debts.length,
        totalBalance: totalBalance,
        monthlyCommitment: _monthlyCommitment(debts, plan),
        assumptions: assumptions,
        plan: plan,
        firstTargetDebt: _firstTargetDebt(debts, plan),
      );
      if (!mounted) return;
      setState(() {
        if (slot == 'a') _snapA = snap;
        if (slot == 'b') _snapB = snap;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isStale(Plan? plan) {
    return plan != null &&
        (plan.projectedDebtFreeDate == null ||
            plan.totalInterestProjected == null ||
            plan.totalInterestSaved == null);
  }

  int _monthlyCommitment(List<Debt> debts, Plan? plan) {
    final minimums = debts
        .where(
          (debt) =>
              debt.status != DebtStatus.archived && debt.currentBalance > 0,
        )
        .fold<int>(0, (sum, debt) => sum + debt.minimumPayment);
    return minimums + (plan?.extraMonthlyAmount ?? 0);
  }

  Debt? _firstTargetDebt(List<Debt> debts, Plan? plan) {
    if (plan == null) return null;
    final activeDebts = debts
        .where(
          (debt) =>
              debt.status != DebtStatus.archived &&
              debt.currentBalance > 0 &&
              !debt.excludeFromStrategy,
        )
        .toList(growable: false);
    if (activeDebts.isEmpty) return null;
    return StrategySorter.sort(
      activeDebts,
      plan.strategy,
      plan.customOrder,
    ).first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.userSettings;
    if (settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.mdSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.scenariosCompareTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.md,
            AppDimensions.pagePaddingH,
            AppDimensions.xxl,
          ),
          children: [
            // Scenario selectors
            Row(
              children: [
                Expanded(
                  child: _ScenarioSelector(
                    label: l10n.scenariosCompareSelectA,
                    scenarios: _scenarios,
                    selected: _selectedA,
                    exclude: _selectedB,
                    onChanged: (s) {
                      setState(() => _selectedA = s);
                      if (s != null) _loadSnapshot('a', s);
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: _ScenarioSelector(
                    label: l10n.scenariosCompareSelectB,
                    scenarios: _scenarios,
                    selected: _selectedB,
                    exclude: _selectedA,
                    onChanged: (s) {
                      setState(() => _selectedB = s);
                      if (s != null) _loadSnapshot('b', s);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_snapA == null || _snapB == null)
              _buildPickPrompt(context)
            else
              _buildComparison(context, _snapA!, _snapB!, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildPickPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppDimensions.xxl),
          Icon(
            LucideIcons.gitCompare,
            size: 56,
            color: AppColors.mdOnSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            context.l10n.scenariosComparePickPrompt,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mdOnSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComparison(
    BuildContext context,
    _ScenarioSnapshot a,
    _ScenarioSnapshot b,
    UserSettings? settings,
  ) {
    final l10n = context.l10n;
    final currencyCode = settings?.currencyCode ?? 'USD';
    final localeCode = settings?.localeCode ?? 'en';

    // Determine winners
    final aFasterByMonths = _monthsBetween(a.debtFreeDate, b.debtFreeDate);
    final bFasterByMonths = _monthsBetween(b.debtFreeDate, a.debtFreeDate);
    final aCheaperBy =
        (a.projectedInterest != null && b.projectedInterest != null)
        ? b.projectedInterest! - a.projectedInterest!
        : null;
    final bCheaperBy =
        (a.projectedInterest != null && b.projectedInterest != null)
        ? a.projectedInterest! - b.projectedInterest!
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row: name + badges
        _CompareHeaderRow(
          labelA: a.scenario.name,
          labelB: b.scenario.name,
          badgeA: aFasterByMonths != null && aFasterByMonths > 0
              ? l10n.scenariosCompareFaster(aFasterByMonths)
              : null,
          badgeB: bFasterByMonths != null && bFasterByMonths > 0
              ? l10n.scenariosCompareFaster(bFasterByMonths)
              : null,
        ),
        const SizedBox(height: AppDimensions.md),
        _AssumptionComparisonRow(snapA: a, snapB: b),
        const SizedBox(height: AppDimensions.md),

        // Metric rows
        _CompareMetricRow(
          rowLabel: l10n.scenariosCompareTotalDebts,
          icon: LucideIcons.creditCard,
          valueA: '${a.debtCount}',
          valueB: '${b.debtCount}',
          highlightA: a.debtCount <= b.debtCount,
          highlightB: b.debtCount <= a.debtCount,
        ),
        const SizedBox(height: AppDimensions.sm),
        _CompareMetricRow(
          rowLabel: l10n.scenariosCompareMonthlyCommitment,
          icon: LucideIcons.walletCards,
          valueA: AppFormatters.formatCents(
            a.monthlyCommitment,
            currencyCode: currencyCode,
            localeCode: localeCode,
          ),
          valueB: AppFormatters.formatCents(
            b.monthlyCommitment,
            currencyCode: currencyCode,
            localeCode: localeCode,
          ),
          highlightA: a.monthlyCommitment <= b.monthlyCommitment,
          highlightB: b.monthlyCommitment <= a.monthlyCommitment,
        ),
        const SizedBox(height: AppDimensions.sm),
        _CompareMetricRow(
          rowLabel: l10n.scenariosCompareFirstTarget,
          icon: LucideIcons.target,
          valueA: a.firstTargetDebt?.name ?? l10n.scenarioLabNoTargetDebt,
          valueB: b.firstTargetDebt?.name ?? l10n.scenarioLabNoTargetDebt,
        ),
        const SizedBox(height: AppDimensions.sm),
        _CompareMetricRow(
          rowLabel: l10n.scenariosCompareTotalBalance,
          icon: LucideIcons.dollarSign,
          valueA: AppFormatters.formatCents(
            a.totalBalance,
            currencyCode: currencyCode,
            localeCode: localeCode,
          ),
          valueB: AppFormatters.formatCents(
            b.totalBalance,
            currencyCode: currencyCode,
            localeCode: localeCode,
          ),
          highlightA: a.totalBalance <= b.totalBalance,
          highlightB: b.totalBalance <= a.totalBalance,
        ),
        const SizedBox(height: AppDimensions.sm),
        _CompareMetricRow(
          rowLabel: l10n.scenariosCompareDebtFreeDate,
          icon: LucideIcons.calendarCheck2,
          valueA: a.debtFreeDate != null
              ? AppFormatters.formatDate(
                  a.debtFreeDate!,
                  localeCode: localeCode,
                )
              : (a.plan == null
                    ? l10n.scenariosCompareNoPlan
                    : l10n.scenariosCompareNotAvailable),
          valueB: b.debtFreeDate != null
              ? AppFormatters.formatDate(
                  b.debtFreeDate!,
                  localeCode: localeCode,
                )
              : (b.plan == null
                    ? l10n.scenariosCompareNoPlan
                    : l10n.scenariosCompareNotAvailable),
          highlightA: aFasterByMonths != null && aFasterByMonths > 0,
          highlightB: bFasterByMonths != null && bFasterByMonths > 0,
          badgeA: aFasterByMonths != null && aFasterByMonths > 0
              ? l10n.scenariosCompareFaster(aFasterByMonths)
              : null,
          badgeB: bFasterByMonths != null && bFasterByMonths > 0
              ? l10n.scenariosCompareFaster(bFasterByMonths)
              : null,
        ),
        const SizedBox(height: AppDimensions.sm),
        _CompareMetricRow(
          rowLabel: l10n.scenariosCompareProjectedInterest,
          icon: LucideIcons.trendingDown,
          valueA: a.projectedInterest != null
              ? AppFormatters.formatCents(
                  a.projectedInterest!,
                  currencyCode: currencyCode,
                  localeCode: localeCode,
                )
              : l10n.scenariosCompareNotAvailable,
          valueB: b.projectedInterest != null
              ? AppFormatters.formatCents(
                  b.projectedInterest!,
                  currencyCode: currencyCode,
                  localeCode: localeCode,
                )
              : l10n.scenariosCompareNotAvailable,
          highlightA: aCheaperBy != null && aCheaperBy > 0,
          highlightB: bCheaperBy != null && bCheaperBy > 0,
          badgeA: aCheaperBy != null && aCheaperBy > 0
              ? l10n.scenariosCompareCheaper(
                  AppFormatters.formatCents(
                    aCheaperBy,
                    currencyCode: currencyCode,
                    localeCode: localeCode,
                  ),
                )
              : null,
          badgeB: bCheaperBy != null && bCheaperBy > 0
              ? l10n.scenariosCompareCheaper(
                  AppFormatters.formatCents(
                    bCheaperBy,
                    currencyCode: currencyCode,
                    localeCode: localeCode,
                  ),
                )
              : null,
        ),
        const SizedBox(height: AppDimensions.sm),
        _CompareMetricRow(
          rowLabel: l10n.scenariosCompareSavedVsMinimum,
          icon: LucideIcons.piggyBank,
          valueA: a.savedVsMinimum != null
              ? AppFormatters.formatCents(
                  a.savedVsMinimum!,
                  currencyCode: currencyCode,
                  localeCode: localeCode,
                )
              : l10n.scenariosCompareNotAvailable,
          valueB: b.savedVsMinimum != null
              ? AppFormatters.formatCents(
                  b.savedVsMinimum!,
                  currencyCode: currencyCode,
                  localeCode: localeCode,
                )
              : l10n.scenariosCompareNotAvailable,
          highlightA:
              a.savedVsMinimum != null &&
              b.savedVsMinimum != null &&
              a.savedVsMinimum! >= b.savedVsMinimum!,
          highlightB:
              a.savedVsMinimum != null &&
              b.savedVsMinimum != null &&
              b.savedVsMinimum! >= a.savedVsMinimum!,
        ),
        const SizedBox(height: AppDimensions.lg),
        _DeltaBanner(
          snapA: a,
          snapB: b,
          fasterMonthsA: aFasterByMonths,
          fasterMonthsB: bFasterByMonths,
          cheaperByA: aCheaperBy,
          cheaperByB: bCheaperBy,
          currencyCode: currencyCode,
          localeCode: localeCode,
        ),
      ],
    );
  }

  /// Returns positive months if [earlier] is before [later], else null.
  int? _monthsBetween(DateTime? earlier, DateTime? later) {
    if (earlier == null || later == null) return null;
    if (!earlier.isBefore(later)) return null;
    final diff =
        (later.year - earlier.year) * 12 + (later.month - earlier.month);
    return diff > 0 ? diff : null;
  }
}

// ---------------------------------------------------------------------------
// Assumptions
// ---------------------------------------------------------------------------

class _AssumptionComparisonRow extends StatelessWidget {
  const _AssumptionComparisonRow({required this.snapA, required this.snapB});

  final _ScenarioSnapshot snapA;
  final _ScenarioSnapshot snapB;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      color: AppColors.mdSurfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.listChecks,
                size: 16,
                color: AppColors.mdOnSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.scenariosAssumptionsTitle,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.mdOnSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _AssumptionCell(snapshot: snapA)),
              const SizedBox(width: AppDimensions.md),
              Expanded(child: _AssumptionCell(snapshot: snapB)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssumptionCell extends StatelessWidget {
  const _AssumptionCell({required this.snapshot});

  final _ScenarioSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final assumptions = snapshot.assumptions;
    if (assumptions.isEmpty) {
      return Text(
        snapshot.scenario.isMain
            ? context.l10n.scenariosMainBadge
            : context.l10n.scenariosCompareNotAvailable,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.mdOnSurfaceVariant,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final assumption in assumptions.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.xs),
            child: AppChip.status(label: assumption.summary),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Selector widget
// ---------------------------------------------------------------------------

class _ScenarioSelector extends StatelessWidget {
  const _ScenarioSelector({
    required this.label,
    required this.scenarios,
    required this.selected,
    required this.onChanged,
    this.exclude,
  });

  final String label;
  final List<Scenario> scenarios;
  final Scenario? selected;
  final Scenario? exclude;
  final ValueChanged<Scenario?> onChanged;

  @override
  Widget build(BuildContext context) {
    final available = scenarios.where((s) => s.id != exclude?.id).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mdOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        DropdownButtonFormField<String>(
          initialValue:
              (selected != null && available.any((s) => s.id == selected!.id))
              ? selected!.id
              : null,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(),
          ),
          items: available
              .map(
                (s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(
                    s.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              )
              .toList(),
          onChanged: (id) {
            onChanged(available.firstWhere((s) => s.id == id));
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header row
// ---------------------------------------------------------------------------

class _CompareHeaderRow extends StatelessWidget {
  const _CompareHeaderRow({
    required this.labelA,
    required this.labelB,
    this.badgeA,
    this.badgeB,
  });

  final String labelA;
  final String labelB;
  final String? badgeA;
  final String? badgeB;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _nameCell(labelA, badgeA, Alignment.centerLeft)),
        const SizedBox(width: AppDimensions.md),
        Expanded(child: _nameCell(labelB, badgeB, Alignment.centerLeft)),
      ],
    );
  }

  Widget _nameCell(String name, String? badge, Alignment align) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: AppTextStyles.titleSmall, maxLines: 2),
        if (badge != null) ...[
          const SizedBox(height: 2),
          _WinnerBadge(label: badge),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Metric row
// ---------------------------------------------------------------------------

class _CompareMetricRow extends StatelessWidget {
  const _CompareMetricRow({
    required this.rowLabel,
    required this.icon,
    required this.valueA,
    required this.valueB,
    this.highlightA = false,
    this.highlightB = false,
    this.badgeA,
    this.badgeB,
  });

  final String rowLabel;
  final IconData icon;
  final String valueA;
  final String valueB;
  final bool highlightA;
  final bool highlightB;
  final String? badgeA;
  final String? badgeB;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.mdSurfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.mdOnSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                rowLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.mdOnSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              Expanded(
                child: _ValueCell(
                  value: valueA,
                  highlight: highlightA,
                  badge: badgeA,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _ValueCell(
                  value: valueB,
                  highlight: highlightB,
                  badge: badgeB,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell({required this.value, this.highlight = false, this.badge});

  final String value;
  final bool highlight;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
            color: highlight ? AppColors.mdPrimary : AppColors.mdOnSurface,
          ),
          maxLines: 2,
        ),
        if (badge != null) ...[
          const SizedBox(height: 2),
          _WinnerBadge(label: badge!),
        ],
      ],
    );
  }
}

class _WinnerBadge extends StatelessWidget {
  const _WinnerBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.mdPrimaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.mdOnPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delta summary banner — shown at bottom of comparison
// ---------------------------------------------------------------------------

class _DeltaBanner extends StatelessWidget {
  const _DeltaBanner({
    required this.snapA,
    required this.snapB,
    required this.fasterMonthsA,
    required this.fasterMonthsB,
    required this.cheaperByA,
    required this.cheaperByB,
    required this.currencyCode,
    required this.localeCode,
  });

  final _ScenarioSnapshot snapA;
  final _ScenarioSnapshot snapB;
  final int? fasterMonthsA;
  final int? fasterMonthsB;
  final int? cheaperByA;
  final int? cheaperByB;
  final String currencyCode;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final aWinsFaster = fasterMonthsA != null && fasterMonthsA! > 0;
    final bWinsFaster = fasterMonthsB != null && fasterMonthsB! > 0;
    final aWinsCheaper = cheaperByA != null && cheaperByA! > 0;
    final bWinsCheaper = cheaperByB != null && cheaperByB! > 0;

    final aScore = (aWinsFaster ? 1 : 0) + (aWinsCheaper ? 1 : 0);
    final bScore = (bWinsFaster ? 1 : 0) + (bWinsCheaper ? 1 : 0);

    final isTie = aScore == bScore;
    final winnerSnap = aScore > bScore ? snapA : snapB;
    final winnerMonths = aScore > bScore ? fasterMonthsA : fasterMonthsB;
    final winnerSaves = aScore > bScore ? cheaperByA : cheaperByB;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: isTie
            ? AppColors.mdSurfaceContainerLow
            : AppColors.mdPrimaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isTie
              ? AppColors.mdOutlineVariant
              : AppColors.mdPrimary.withValues(alpha: 0.4),
        ),
      ),
      child: isTie
          ? Row(
              children: [
                const Icon(LucideIcons.equal, size: 18),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    l10n.scenariosCompareTie,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.trophy,
                      size: 18,
                      color: AppColors.mdPrimary,
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        l10n.scenariosCompareDeltaTitle(
                          winnerSnap.scenario.name,
                        ),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (winnerMonths != null && winnerMonths > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 26),
                      Icon(
                        LucideIcons.calendarClock,
                        size: 14,
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.scenariosCompareDeltaMonths(winnerMonths),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mdOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
                if (winnerSaves != null && winnerSaves > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 26),
                      Icon(
                        LucideIcons.piggyBank,
                        size: 14,
                        color: AppColors.mdOnSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.scenariosCompareDeltaInterest(
                          AppFormatters.formatCents(
                            winnerSaves,
                            currencyCode: currencyCode,
                            localeCode: localeCode,
                          ),
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mdOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
