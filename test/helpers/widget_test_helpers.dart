import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterRouterHelpers on WidgetTester {
  Future<void> pumpRouterIdle({
    Duration step = const Duration(milliseconds: 16),
    int maxPumps = 60,
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      await pump(step);
      if (!binding.hasScheduledFrame) {
        await pump();
        if (!binding.hasScheduledFrame) {
          return;
        }
      }
    }

    throw TestFailure('pumpRouterIdle timed out after $maxPumps pumps.');
  }

  Future<void> pumpUntilVisible(
    Finder finder, {
    Duration step = const Duration(milliseconds: 16),
    int maxPumps = 120,
  }) async {
    if (any(finder)) {
      return;
    }

    for (var i = 0; i < maxPumps; i++) {
      await pump(step);
      if (any(finder)) {
        return;
      }
    }

    throw TestFailure('pumpUntilVisible timed out waiting for finder: $finder');
  }
}
