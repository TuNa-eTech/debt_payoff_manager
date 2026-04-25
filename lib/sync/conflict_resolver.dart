enum SyncConflictDecision { keepLocal, applyRemote, noChange }

class SyncConflictInput {
  const SyncConflictInput({
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
    this.localDeletedAt,
    this.remoteDeletedAt,
  });

  final DateTime? localUpdatedAt;
  final DateTime? remoteUpdatedAt;
  final DateTime? localDeletedAt;
  final DateTime? remoteDeletedAt;
}

class LastWriteWinsConflictResolver {
  const LastWriteWinsConflictResolver();

  SyncConflictDecision resolve(SyncConflictInput input) {
    final localClock = _effectiveClock(
      updatedAt: input.localUpdatedAt,
      deletedAt: input.localDeletedAt,
    );
    final remoteClock = _effectiveClock(
      updatedAt: input.remoteUpdatedAt,
      deletedAt: input.remoteDeletedAt,
    );

    if (localClock == null && remoteClock == null) {
      return SyncConflictDecision.noChange;
    }
    if (localClock == null) return SyncConflictDecision.applyRemote;
    if (remoteClock == null) return SyncConflictDecision.keepLocal;
    if (remoteClock.isAfter(localClock)) {
      return SyncConflictDecision.applyRemote;
    }
    if (localClock.isAfter(remoteClock)) {
      return SyncConflictDecision.keepLocal;
    }
    return SyncConflictDecision.noChange;
  }

  DateTime? _effectiveClock({DateTime? updatedAt, DateTime? deletedAt}) {
    if (updatedAt == null) return deletedAt?.toUtc();
    if (deletedAt == null) return updatedAt.toUtc();

    final normalizedUpdatedAt = updatedAt.toUtc();
    final normalizedDeletedAt = deletedAt.toUtc();
    return normalizedDeletedAt.isAfter(normalizedUpdatedAt)
        ? normalizedDeletedAt
        : normalizedUpdatedAt;
  }
}
