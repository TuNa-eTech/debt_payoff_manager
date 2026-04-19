import 'package:firebase_analytics/firebase_analytics.dart';

abstract interface class AppAnalytics {
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  });
}

class NoopAppAnalytics implements AppAnalytics {
  const NoopAppAnalytics();

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {}
}

class FirebaseAppAnalytics implements AppAnalytics {
  FirebaseAppAnalytics({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    try {
      final sanitized = _sanitizeParameters(parameters);
      await _analytics.logEvent(
        name: name,
        parameters: sanitized.isEmpty ? null : sanitized,
      );
    } catch (_) {
      // Analytics should never block user flows.
    }
  }

  Map<String, Object> _sanitizeParameters(Map<String, Object?> parameters) {
    final sanitized = <String, Object>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }

      if (value is String || value is num) {
        sanitized[entry.key] = value;
        continue;
      }

      if (value is bool) {
        sanitized[entry.key] = value ? 1 : 0;
        continue;
      }

      sanitized[entry.key] = value.toString();
    }
    return sanitized;
  }
}
