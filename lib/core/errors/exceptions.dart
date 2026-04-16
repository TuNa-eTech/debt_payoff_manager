// Custom exceptions for infrastructure-level errors.
//
// These are caught at the repository layer and converted to [Failure] objects.
// Never let these propagate to the presentation layer.

class DatabaseException implements Exception {
  const DatabaseException([this.message = 'Database operation failed']);

  final String message;

  @override
  String toString() => 'DatabaseException: $message';
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache operation failed']);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class SerializationException implements Exception {
  const SerializationException([this.message = 'Serialization failed']);

  final String message;

  @override
  String toString() => 'SerializationException: $message';
}
