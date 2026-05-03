import 'package:uuid/uuid.dart';

import '../../domain/entities/debt.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/scenario.dart';
import '../../domain/entities/scenario_assumption.dart';
import '../../domain/enums/debt_status.dart';
import '../../domain/enums/scenario_assumption_type.dart';
import '../../domain/enums/strategy.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../domain/repositories/scenario_assumption_repository.dart';
import '../../domain/repositories/scenario_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../engine/strategy_sorter.dart';
import '../models/scenario_lab_models.dart';
import '../utils/formatters.dart';
import 'plan_recast_service.dart';

class ScenarioLabService {
  ScenarioLabService({
    required SettingsRepository settingsRepository,
    required ScenarioRepository scenarioRepository,
    required ScenarioAssumptionRepository scenarioAssumptionRepository,
    required DebtRepository debtRepository,
    required PlanRepository planRepository,
    required PlanRecastService planRecastService,
  }) : _settingsRepository = settingsRepository,
       _scenarioRepository = scenarioRepository,
       _scenarioAssumptionRepository = scenarioAssumptionRepository,
       _debtRepository = debtRepository,
       _planRepository = planRepository,
       _planRecastService = planRecastService;

  final SettingsRepository _settingsRepository;
  final ScenarioRepository _scenarioRepository;
  final ScenarioAssumptionRepository _scenarioAssumptionRepository;
  final DebtRepository _debtRepository;
  final PlanRepository _planRepository;
  final PlanRecastService _planRecastService;
  final Uuid _uuid = const Uuid();

  Future<ScenarioLabPreview> previewExtraMonthly({
    required int deltaExtraMonthlyCents,
    String? name,
  }) async {
    if (deltaExtraMonthlyCents <= 0) {
      throw ArgumentError('deltaExtraMonthlyCents must be > 0');
    }
    final input = await _loadInput();
    final previewPlan = input.plan.copyWith(
      id: _uuid.v4(),
      extraMonthlyAmount:
          input.plan.extraMonthlyAmount + deltaExtraMonthlyCents,
      projectedDebtFreeDate: null,
      totalInterestProjected: null,
      totalInterestSaved: null,
      lastRecastAt: null,
    );
    final summary = _extraMonthlySummary(
      deltaExtraMonthlyCents,
      input.currencyCode,
      input.localeCode,
    );
    return _buildPreview(
      template: ScenarioLabTemplate.extraMonthly,
      name: _defaultName(name, summary),
      summary: summary,
      input: input,
      previewPlan: previewPlan,
      assumptionParams: <String, Object?>{
        'deltaExtraMonthlyCents': deltaExtraMonthlyCents,
        'previousExtraMonthlyCents': input.plan.extraMonthlyAmount,
        'newExtraMonthlyCents': previewPlan.extraMonthlyAmount,
      },
    );
  }

  Future<ScenarioLabPreview> previewStrategyChange({
    required Strategy strategy,
    String? name,
  }) async {
    final input = await _loadInput();
    final previewPlan = input.plan.copyWith(
      id: _uuid.v4(),
      strategy: strategy,
      projectedDebtFreeDate: null,
      totalInterestProjected: null,
      totalInterestSaved: null,
      lastRecastAt: null,
    );
    final summary = 'Switch to ${_strategyLabel(strategy)}';
    return _buildPreview(
      template: ScenarioLabTemplate.strategyChange,
      name: _defaultName(name, summary),
      summary: summary,
      input: input,
      previewPlan: previewPlan,
      assumptionParams: <String, Object?>{
        'previousStrategy': input.plan.strategy.name,
        'newStrategy': strategy.name,
      },
    );
  }

  Future<SavedScenarioResult> savePreview(ScenarioLabPreview preview) async {
    final now = DateTime.now().toUtc();
    final scenarioId = _uuid.v4();
    final scenario = Scenario(
      id: scenarioId,
      name: preview.name,
      createdAt: now,
    );

    await _scenarioRepository.addScenario(scenario);

    final input = await _loadInput();
    for (final debt in input.debts) {
      await _debtRepository.addDebt(
        debt.copyWith(
          id: _uuid.v4(),
          scenarioId: scenarioId,
          createdAt: now,
          updatedAt: now,
          deletedAt: null,
        ),
      );
    }

    final savedPlan = await _planRepository.savePlan(
      preview.previewPlan.copyWith(
        id: _uuid.v4(),
        scenarioId: scenarioId,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      ),
    );

    final assumption = await _scenarioAssumptionRepository.addAssumption(
      ScenarioAssumption(
        id: _uuid.v4(),
        scenarioId: scenarioId,
        type: _assumptionTypeFor(preview.template),
        summary: preview.summary,
        params: preview.assumptionParams,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final recast = await _planRecastService.recast(scenarioId: scenarioId);

    return SavedScenarioResult(
      scenario: scenario,
      plan: recast?.plan ?? savedPlan,
      assumption: assumption,
      preview: preview,
    );
  }

  Future<void> activateScenario(String scenarioId) async {
    final settings = await _settingsRepository.getSettings();
    await _settingsRepository.updateSettings(
      settings.copyWith(activeScenarioId: scenarioId),
    );
  }

  Future<_ScenarioLabInput> _loadInput({String? scenarioId}) async {
    final settings = await _settingsRepository.getSettings();
    final effectiveScenarioId = scenarioId ?? settings.activeScenarioId;
    final plan = await _planRepository.getCurrentPlan(
      scenarioId: effectiveScenarioId,
    );
    if (plan == null) {
      throw StateError(
        'No active plan found for scenario $effectiveScenarioId.',
      );
    }
    final debts = await _debtRepository.getAllDebts(
      scenarioId: effectiveScenarioId,
    );
    return _ScenarioLabInput(
      scenarioId: effectiveScenarioId,
      currencyCode: settings.currencyCode,
      localeCode: settings.localeCode,
      debts: debts,
      plan: plan,
    );
  }

  Future<ScenarioLabPreview> _buildPreview({
    required ScenarioLabTemplate template,
    required String name,
    required String summary,
    required _ScenarioLabInput input,
    required Plan previewPlan,
    required Map<String, Object?> assumptionParams,
  }) async {
    final currentPreview = await _planRecastService.previewPlan(
      plan: input.plan,
      debts: input.debts,
    );
    final preview = await _planRecastService.previewPlan(
      plan: previewPlan,
      debts: input.debts,
    );
    return ScenarioLabPreview(
      template: template,
      name: name,
      summary: summary,
      currentPlan: input.plan,
      previewPlan: previewPlan,
      sourceScenarioId: input.scenarioId,
      currentPreview: currentPreview,
      preview: preview,
      currentMonthlyCommitment: _monthlyCommitment(input.debts, input.plan),
      previewMonthlyCommitment: _monthlyCommitment(input.debts, previewPlan),
      firstTargetDebt: _firstTargetDebt(input.debts, previewPlan),
      assumptionParams: assumptionParams,
    );
  }

  int _monthlyCommitment(List<Debt> debts, Plan plan) {
    final minimums = debts
        .where(
          (debt) =>
              debt.status != DebtStatus.archived && debt.currentBalance > 0,
        )
        .fold<int>(0, (sum, debt) => sum + debt.minimumPayment);
    return minimums + plan.extraMonthlyAmount;
  }

  Debt? _firstTargetDebt(List<Debt> debts, Plan plan) {
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

  ScenarioAssumptionType _assumptionTypeFor(ScenarioLabTemplate template) {
    switch (template) {
      case ScenarioLabTemplate.extraMonthly:
        return ScenarioAssumptionType.extraMonthly;
      case ScenarioLabTemplate.strategyChange:
        return ScenarioAssumptionType.strategyChange;
    }
  }

  String _extraMonthlySummary(
    int deltaExtraMonthlyCents,
    String currencyCode,
    String localeCode,
  ) {
    final amount = AppFormatters.formatCents(
      deltaExtraMonthlyCents,
      currencyCode: currencyCode,
      localeCode: localeCode,
    );
    return 'Extra $amount/month';
  }

  String _strategyLabel(Strategy strategy) {
    switch (strategy) {
      case Strategy.snowball:
        return 'Snowball';
      case Strategy.avalanche:
        return 'Avalanche';
      case Strategy.custom:
        return 'Custom';
    }
  }

  String _defaultName(String? name, String fallback) {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return fallback;
  }
}

class _ScenarioLabInput {
  const _ScenarioLabInput({
    required this.scenarioId,
    required this.currencyCode,
    required this.localeCode,
    required this.debts,
    required this.plan,
  });

  final String scenarioId;
  final String currencyCode;
  final String localeCode;
  final List<Debt> debts;
  final Plan plan;
}
