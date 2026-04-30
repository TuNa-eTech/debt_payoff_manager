import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/data/local/database.dart';
import 'package:debt_payoff_manager/data/repositories/debt_repository_impl.dart';
import 'package:debt_payoff_manager/data/repositories/interest_rate_history_repository_impl.dart';
import 'package:debt_payoff_manager/domain/entities/interest_rate_history.dart';

import 'repository_test_helpers.dart';

void main() {
  late AppDatabase db;
  late InterestRateHistoryRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = InterestRateHistoryRepositoryImpl(db: db);
    await DebtRepositoryImpl(db: db).addDebt(makeRepoDebt(id: 'card'));
  });

  tearDown(() async {
    await db.close();
  });

  test('getByDebtId returns most recent rates first', () async {
    await repository.addRateHistory(
      InterestRateHistory(
        id: 'old-rate',
        debtId: 'card',
        apr: Decimal.parse('0.12'),
        effectiveFrom: DateTime.utc(2026, 1, 1),
        effectiveTo: DateTime.utc(2026, 6, 30),
      ),
    );
    await repository.addRateHistory(
      InterestRateHistory(
        id: 'new-rate',
        debtId: 'card',
        apr: Decimal.parse('0.19'),
        effectiveFrom: DateTime.utc(2026, 7, 1),
      ),
    );

    final rates = await repository.getByDebtId('card');

    expect(rates.map((rate) => rate.id), ['new-rate', 'old-rate']);
  });

  test('rejects overlapping rate periods', () async {
    await repository.addRateHistory(
      InterestRateHistory(
        id: 'promo-rate',
        debtId: 'card',
        apr: Decimal.parse('0.05'),
        effectiveFrom: DateTime.utc(2026, 1, 1),
        effectiveTo: DateTime.utc(2026, 6, 30),
      ),
    );

    expect(
      () => repository.addRateHistory(
        InterestRateHistory(
          id: 'overlap-rate',
          debtId: 'card',
          apr: Decimal.parse('0.18'),
          effectiveFrom: DateTime.utc(2026, 6, 1),
          effectiveTo: DateTime.utc(2026, 12, 31),
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
