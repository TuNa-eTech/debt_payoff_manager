import 'package:equatable/equatable.dart';

import '../../domain/entities/debt.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/scenario.dart';
import '../../domain/entities/scenario_assumption.dart';
import '../../domain/enums/strategy.dart';
import 'strategy_preview.dart';

enum ScenarioLabTemplate { extraMonthly, strategyChange }

class ScenarioLabPreview extends Equatable {
  const ScenarioLabPreview({
    required this.template,
    required this.name,
    required this.summary,
    required this.currentPlan,
    required this.previewPlan,
    required this.sourceScenarioId,
    required this.currentPreview,
    required this.preview,
    required this.currentMonthlyCommitment,
    required this.previewMonthlyCommitment,
    required this.firstTargetDebt,
    required this.assumptionParams,
  });

  final ScenarioLabTemplate template;
  final String name;
  final String summary;
  final Plan currentPlan;
  final Plan previewPlan;
  final String sourceScenarioId;
  final StrategyPreview currentPreview;
  final StrategyPreview preview;
  final int currentMonthlyCommitment;
  final int previewMonthlyCommitment;
  final Debt? firstTargetDebt;
  final Map<String, Object?> assumptionParams;

  int? get monthsSaved {
    final currentMonths = currentPreview.projectedMonths;
    final previewMonths = preview.projectedMonths;
    if (currentMonths <= 0 || previewMonths <= 0) return null;
    return currentMonths - previewMonths;
  }

  int get interestSaved {
    return currentPreview.totalInterestProjected -
        preview.totalInterestProjected;
  }

  int get monthlyCommitmentDelta {
    return previewMonthlyCommitment - currentMonthlyCommitment;
  }

  Strategy get previewStrategy => previewPlan.strategy;

  @override
  List<Object?> get props => [
    template,
    name,
    summary,
    currentPlan,
    previewPlan,
    sourceScenarioId,
    currentPreview,
    preview,
    currentMonthlyCommitment,
    previewMonthlyCommitment,
    firstTargetDebt,
    assumptionParams.toString(),
  ];
}

class SavedScenarioResult extends Equatable {
  const SavedScenarioResult({
    required this.scenario,
    required this.plan,
    required this.assumption,
    required this.preview,
  });

  final Scenario scenario;
  final Plan plan;
  final ScenarioAssumption assumption;
  final ScenarioLabPreview preview;

  @override
  List<Object?> get props => [scenario, plan, assumption, preview];
}
