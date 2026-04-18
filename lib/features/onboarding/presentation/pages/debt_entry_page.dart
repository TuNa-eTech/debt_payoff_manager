import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/repositories/debt_repository.dart';
import '../../../debts/cubit/debt_form_cubit.dart';
import '../../../debts/presentation/pages/add_debt_page.dart';
import '../../cubit/onboarding_cubit.dart';
import '../../cubit/onboarding_state.dart';

class DebtEntryPage extends StatelessWidget {
  const DebtEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DebtFormCubit.create(
        debtRepository: getIt.get<DebtRepository>(),
        mode: DebtFormMode.onboarding,
      ),
      child: Builder(
        builder: (context) {
          return DebtFormScaffold(
            mode: DebtFormMode.onboarding,
            title: 'Thêm khoản nợ đầu tiên',
            primaryActionLabel: 'Lưu khoản nợ',
            progressLabel: 'Bước 1/4',
            progressValue: 0.25,
            onCancel: () {
              context.read<OnboardingCubit>().goToStep(OnboardingStep.welcome);
              context.pop();
            },
            onSaved: (context, debt) async {
              await context.read<OnboardingCubit>().goToStep(
                    OnboardingStep.addDebt,
                  );
              if (!context.mounted) return;
              context.go(AppRoutes.addAnotherDebt);
            },
          );
        },
      ),
    );
  }
}
