import 'package:drift/drift.dart';

import '../../domain/entities/scenario.dart';
import '../local/database.dart';

/// Maps between Drift [ScenarioRow] and domain [Scenario] entity.
extension ScenarioRowMapper on ScenarioRow {
  Scenario toDomain() {
    return Scenario(
      id: id,
      name: name,
      isMain: isMain,
      createdAt: createdAt,
      deletedAt: deletedAt,
    );
  }
}

/// Maps from domain [Scenario] to Drift [ScenariosTableCompanion].
extension ScenarioCompanionMapper on Scenario {
  ScenariosTableCompanion toCompanion() {
    return ScenariosTableCompanion(
      id: Value(id),
      name: Value(name),
      isMain: Value(isMain),
      createdAt: Value(createdAt),
      deletedAt: Value(deletedAt),
    );
  }
}
