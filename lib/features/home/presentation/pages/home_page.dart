import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../domain/repositories/plan_repository.dart';
import '../../../debts/cubit/debts_cubit.dart';
import '../../../debts/cubit/debts_state.dart';
import '../widgets/home_empty_view.dart';
import '../widgets/home_populated_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final planRepository = getIt.get<PlanRepository>();

    return BlocBuilder<DebtsCubit, DebtsState>(
      builder: (context, state) {
        return StreamBuilder(
          stream: planRepository.watchCurrentPlan(),
          builder: (context, planSnapshot) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Tổng quan'),
              ),
              body: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.debts.isEmpty
                      ? const HomeEmptyView()
                      : HomePopulatedView(
                          debts: state.debts,
                          plan: planSnapshot.data,
                        ),
            );
          },
        );
      },
    );
  }
}
