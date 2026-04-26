import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract interface class DeviceIdService {
  Future<String> getDeviceId();
}

class SharedPrefsDeviceIdService implements DeviceIdService {
  SharedPrefsDeviceIdService({Future<SharedPreferences>? sharedPreferences})
    : _sharedPreferences =
          sharedPreferences ?? SharedPreferences.getInstance();

  static const _deviceIdKey = 'sync.device_id';

  final Future<SharedPreferences> _sharedPreferences;

  @override
  Future<String> getDeviceId() async {
    final prefs = await _sharedPreferences;
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final id = const Uuid().v4();
    await prefs.setString(_deviceIdKey, id);
    return id;
  }
}
