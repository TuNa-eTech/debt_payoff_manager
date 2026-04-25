import 'package:debt_payoff_manager/sync/conflict_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LastWriteWinsConflictResolver', () {
    const resolver = LastWriteWinsConflictResolver();

    test('applies remote when remote updatedAt is newer', () {
      final decision = resolver.resolve(
        SyncConflictInput(
          localUpdatedAt: DateTime.utc(2026, 4, 24),
          remoteUpdatedAt: DateTime.utc(2026, 4, 25),
        ),
      );

      expect(decision, SyncConflictDecision.applyRemote);
    });

    test('keeps local when local updatedAt is newer', () {
      final decision = resolver.resolve(
        SyncConflictInput(
          localUpdatedAt: DateTime.utc(2026, 4, 26),
          remoteUpdatedAt: DateTime.utc(2026, 4, 25),
        ),
      );

      expect(decision, SyncConflictDecision.keepLocal);
    });

    test('treats newer delete timestamp as the winning write', () {
      final decision = resolver.resolve(
        SyncConflictInput(
          localUpdatedAt: DateTime.utc(2026, 4, 24),
          remoteUpdatedAt: DateTime.utc(2026, 4, 23),
          remoteDeletedAt: DateTime.utc(2026, 4, 25),
        ),
      );

      expect(decision, SyncConflictDecision.applyRemote);
    });

    test('returns noChange when clocks match', () {
      final decision = resolver.resolve(
        SyncConflictInput(
          localUpdatedAt: DateTime.utc(2026, 4, 25),
          remoteUpdatedAt: DateTime.utc(2026, 4, 25),
        ),
      );

      expect(decision, SyncConflictDecision.noChange);
    });
  });
}
