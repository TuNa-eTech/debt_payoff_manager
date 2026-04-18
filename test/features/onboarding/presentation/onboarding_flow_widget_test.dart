import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:debt_payoff_manager/domain/repositories/debt_repository.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_cubit.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_state.dart';
import 'package:debt_payoff_manager/features/onboarding/presentation/pages/add_another_debt_page.dart';

import '../../../data/repositories/repository_test_helpers.dart';

class _MockDebtRepository extends Mock implements DebtRepository {}

class _TestDebtsCubit extends DebtsCubit {
  _TestDebtsCubit() : super(debtRepository: _MockDebtRepository());

  void seed(DebtsState nextState) => emit(nextState);
}

void main() {
  testWidgets('add another debt page renders live saved debts', (tester) async {
    final cubit = _TestDebtsCubit()
      ..seed(
        DebtsState(
          isLoading: false,
          debts: [
            makeRepoDebt(id: 'visa', name: 'Visa', currentBalance: 120000),
          ],
        ),
      );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DebtsCubit>.value(
          value: cubit,
          child: const AddAnotherDebtPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Visa'), findsOneWidget);
    expect(find.text('Sang bước chọn chiến lược'), findsOneWidget);
  });
}
