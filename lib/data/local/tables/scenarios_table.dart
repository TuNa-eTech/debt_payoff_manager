import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../converters/datetime_converters.dart';

/// Scenarios table — metadata for what-if payoff scenarios.
///
/// The 'main' row is always present and isMain = true.
/// User-created scenarios duplicate debt/plan data, not payments.
@DataClassName('ScenarioRow')
class ScenariosTable extends Table {
  @override
  String get tableName => 'scenarios';

  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  BoolColumn get isMain => boolean().withDefault(const Constant(false))();

  TextColumn get createdAt => text().map(const UtcDateTimeConverter())();
  TextColumn get deletedAt =>
      text().nullable().map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
