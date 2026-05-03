import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/scenario_assumption.dart';
import '../local/database.dart';

extension ScenarioAssumptionRowMapper on ScenarioAssumptionRow {
  ScenarioAssumption toDomain() {
    return ScenarioAssumption(
      id: id,
      scenarioId: scenarioId,
      type: type,
      summary: summary,
      params: Map<String, Object?>.from(jsonDecode(paramsJson) as Map),
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}

extension ScenarioAssumptionCompanionMapper on ScenarioAssumption {
  ScenarioAssumptionsTableCompanion toCompanion() {
    return ScenarioAssumptionsTableCompanion(
      id: Value(id),
      scenarioId: Value(scenarioId),
      type: Value(type),
      summary: Value(summary),
      paramsJson: Value(jsonEncode(params)),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
    );
  }
}
