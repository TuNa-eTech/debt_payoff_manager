import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/core/models/recast_delta.dart';

void main() {
  group('RecastDelta', () {
    test('treats unchanged recast summaries as not meaningful', () {
      final delta = RecastDelta(
        previousDebtFreeDate: DateTime(2028, 3),
        newDebtFreeDate: DateTime(2028, 3),
        previousTotalInterestProjected: 99410,
        newTotalInterestProjected: 99410,
        previousTotalInterestSaved: 94282,
        newTotalInterestSaved: 94282,
      );

      expect(delta.isFirstRun, isFalse);
      expect(delta.hasDebtFreeDateChange, isFalse);
      expect(delta.hasProjectedInterestChange, isFalse);
      expect(delta.hasSavedInterestChange, isFalse);
      expect(delta.hasMeaningfulChange, isFalse);
    });

    test('treats interest-only recasts as meaningful', () {
      final delta = RecastDelta(
        previousDebtFreeDate: DateTime(2028, 3),
        newDebtFreeDate: DateTime(2028, 3),
        previousTotalInterestProjected: 99410,
        newTotalInterestProjected: 96153,
        previousTotalInterestSaved: 94282,
        newTotalInterestSaved: 124951,
      );

      expect(delta.hasDebtFreeDateChange, isFalse);
      expect(delta.hasProjectedInterestChange, isTrue);
      expect(delta.hasSavedInterestChange, isTrue);
      expect(delta.projectedInterestDelta, -3257);
      expect(delta.savedInterestDelta, 30669);
      expect(delta.hasMeaningfulChange, isTrue);
    });
  });
}
