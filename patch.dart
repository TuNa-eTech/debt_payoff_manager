import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel('dexterous.com/flutter/local_notifications').setMockMethodCallHandler((call) async {
    return null;
  });
}
