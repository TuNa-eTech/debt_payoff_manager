/// Runtime configuration for the Firebase sync layer.
///
/// This is intentionally not wired into app startup yet. Phase 7 keeps
/// Firebase optional until the user upgrades from Trust Level 0 to Level 1.
class FirebaseSyncConfig {
  const FirebaseSyncConfig({
    required this.useEmulators,
    this.firestoreHost = 'localhost',
    this.firestorePort = 8080,
    this.authHost = 'localhost',
    this.authPort = 9099,
    this.functionsHost = 'localhost',
    this.functionsPort = 5001,
  });

  factory FirebaseSyncConfig.fromEnvironment() {
    return const FirebaseSyncConfig(
      useEmulators: bool.fromEnvironment('USE_FIREBASE_EMULATORS'),
      firestoreHost: String.fromEnvironment(
        'FIRESTORE_EMULATOR_HOST',
        defaultValue: 'localhost',
      ),
      firestorePort: int.fromEnvironment(
        'FIRESTORE_EMULATOR_PORT',
        defaultValue: 8080,
      ),
      authHost: String.fromEnvironment(
        'FIREBASE_AUTH_EMULATOR_HOST',
        defaultValue: 'localhost',
      ),
      authPort: int.fromEnvironment(
        'FIREBASE_AUTH_EMULATOR_PORT',
        defaultValue: 9099,
      ),
      functionsHost: String.fromEnvironment(
        'FIREBASE_FUNCTIONS_EMULATOR_HOST',
        defaultValue: 'localhost',
      ),
      functionsPort: int.fromEnvironment(
        'FIREBASE_FUNCTIONS_EMULATOR_PORT',
        defaultValue: 5001,
      ),
    );
  }

  final bool useEmulators;
  final String firestoreHost;
  final int firestorePort;
  final String authHost;
  final int authPort;
  final String functionsHost;
  final int functionsPort;
}
