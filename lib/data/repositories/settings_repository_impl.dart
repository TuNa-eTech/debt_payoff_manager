import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../local/database.dart';
import '../mappers/user_settings_mapper.dart';

/// Concrete implementation of [SettingsRepository] using Drift (SQLite).
///
/// UserSettings is a singleton (id='singleton'), seeded on DB creation.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<UserSettings> getSettings() async {
    final query = _db.select(_db.userSettingsTable)
      ..where((s) => s.id.equals('singleton'));

    final row = await query.getSingle();
    return row.toDomain();
  }

  @override
  Future<void> updateSettings(UserSettings settings) async {
    final updated = settings.copyWith(updatedAt: DateTime.now().toUtc());
    await (_db.update(_db.userSettingsTable)
          ..where((s) => s.id.equals('singleton')))
        .write(updated.toCompanion());
  }

  @override
  Stream<UserSettings> watchSettings() {
    final query = _db.select(_db.userSettingsTable)
      ..where((s) => s.id.equals('singleton'));

    return query.watchSingle().map((row) => row.toDomain());
  }
}
