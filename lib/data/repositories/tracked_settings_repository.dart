import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../local/stores/sync_state_store.dart';
import 'settings_repository_impl.dart';

class TrackedSettingsRepository implements SettingsRepository {
  TrackedSettingsRepository({
    required SettingsRepositoryImpl base,
    required SyncStateStore syncStateStore,
  }) : _base = base,
       _syncStateStore = syncStateStore;

  final SettingsRepositoryImpl _base;
  final SyncStateStore _syncStateStore;

  @override
  Future<UserSettings> getSettings() => _base.getSettings();

  @override
  Future<void> updateSettings(UserSettings settings) async {
    await _base.updateSettings(settings);
    await _syncStateStore.markDirty('settings');
  }

  @override
  Stream<UserSettings> watchSettings() => _base.watchSettings();
}
