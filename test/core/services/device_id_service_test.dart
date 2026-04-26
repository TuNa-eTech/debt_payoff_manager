import 'package:debt_payoff_manager/core/services/device_id_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('generates a stable UUID and persists it', () async {
    final service = SharedPrefsDeviceIdService();

    final first = await service.getDeviceId();
    final second = await service.getDeviceId();

    expect(first, equals(second));
    expect(first, matches(RegExp(r'^[0-9a-f-]{36}$')));
  });

  test('two separate instances share the persisted ID', () async {
    final a = SharedPrefsDeviceIdService();
    final b = SharedPrefsDeviceIdService();

    final idA = await a.getDeviceId();
    final idB = await b.getDeviceId();

    expect(idA, equals(idB));
  });

  test('returns pre-existing stored value without overwriting', () async {
    SharedPreferences.setMockInitialValues({'sync.device_id': 'preset-id'});
    final service = SharedPrefsDeviceIdService();

    expect(await service.getDeviceId(), 'preset-id');
  });
}
