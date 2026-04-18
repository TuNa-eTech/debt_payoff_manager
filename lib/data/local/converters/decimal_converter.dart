import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Converts [Decimal] ↔ [String] for Drift storage.
///
/// Stores decimal values as their string representation
/// to preserve exact precision (e.g., "0.1899" for 18.99% APR).
///
/// Reference: data-schema.md §2 Type Converters
class DecimalConverter extends TypeConverter<Decimal, String> {
  const DecimalConverter();

  @override
  Decimal fromSql(String fromDb) => Decimal.parse(fromDb);

  @override
  String toSql(Decimal value) => value.toString();
}
