import 'package:drift/drift.dart';

/// Converts [DateTime] (UTC) ↔ [String] ISO-8601 for Drift storage.
///
/// Used for point-in-time timestamps: `createdAt`, `updatedAt`, `paidOffAt`.
/// Always stores and restores as UTC.
///
/// Reference: data-schema.md §1 Convention, ADR-008
class UtcDateTimeConverter extends TypeConverter<DateTime, String> {
  const UtcDateTimeConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb).toUtc();

  @override
  String toSql(DateTime value) => value.toUtc().toIso8601String();
}

/// Converts [DateTime] (local calendar day) ↔ [String] "YYYY-MM-DD".
///
/// Used for calendar dates: `firstDueDate`, `pausedUntil`, `effectiveFrom`.
/// Does NOT convert to UTC — preserves the calendar day as-is.
///
/// Reference: data-schema.md §1 Convention, ADR-008
class LocalDateConverter extends TypeConverter<DateTime, String> {
  const LocalDateConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb); // keep local

  @override
  String toSql(DateTime value) =>
      value.toIso8601String().substring(0, 10); // YYYY-MM-DD
}
