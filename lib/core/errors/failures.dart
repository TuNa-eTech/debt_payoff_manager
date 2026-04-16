/// Base failure class for domain-level errors.
///
/// Used instead of throwing exceptions in the domain/application layers.
/// Presentation layer maps these to user-friendly messages.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Failure related to database operations.
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database operation failed']);
}

/// Failure related to input validation.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure related to financial calculation.
class CalculationFailure extends Failure {
  const CalculationFailure(super.message);
}

/// Failure when a requested entity is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Entity not found']);
}

/// Failure related to network/sync operations (future Firestore).
class SyncFailure extends Failure {
  const SyncFailure([super.message = 'Sync operation failed']);
}
