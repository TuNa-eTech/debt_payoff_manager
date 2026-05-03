import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../converters/datetime_converters.dart';
import '../converters/enum_converters.dart';

@DataClassName('ScenarioAssumptionRow')
class ScenarioAssumptionsTable extends Table {
  @override
  String get tableName => 'scenario_assumptions';

  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get scenarioId => text()();
  TextColumn get type => text().map(const ScenarioAssumptionTypeConverter())();
  TextColumn get summary => text().withLength(min: 1, max: 240)();
  TextColumn get paramsJson => text().withDefault(const Constant('{}'))();
  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().map(const UtcDateTimeConverter())();
  TextColumn get deletedAt =>
      text().nullable().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
