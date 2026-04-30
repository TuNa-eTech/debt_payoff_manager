import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/context_extensions.dart';

import '../../../../core/constants/app_test_keys.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/repositories/debt_repository.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../debts/cubit/debts_cubit.dart';
import '../../../debts/cubit/debt_form_cubit.dart';
import '../../../debts/presentation/pages/add_debt_page.dart';
import '../../cubit/onboarding_state.dart';
import '../../services/onboarding_analytics.dart';
import '../onboarding_navigation.dart';
import '../widgets/onboarding_step_tracker.dart';

class DebtEntryPage extends StatelessWidget {
  const DebtEntryPage({super.key});

  Future<void> _handleBack(BuildContext context) async {
    final hasSavedDebts = context.read<DebtsCubit>().state.debts.isNotEmpty;
    if (hasSavedDebts) {
      await navigateToOnboardingStep(
        context,
        step: OnboardingStep.addDebt,
        route: AppRoutes.addAnotherDebt,
      );
      return;
    }

    await navigateToOnboardingStep(
      context,
      step: OnboardingStep.welcome,
      route: AppRoutes.welcome,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DebtFormCubit.create(
        debtRepository: getIt.get<DebtRepository>(),
        settingsRepository: getIt.get<SettingsRepository>(),
        mode: DebtFormMode.onboarding,
      ),
      child: Builder(
        builder: (context) {
          return OnboardingStepTracker(
            screen: OnboardingAnalyticsScreen.debtEntry,
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                _handleBack(context);
              },
              child: DebtFormScaffold(
                mode: DebtFormMode.onboarding,
                title: context.l10n.onboardingDebtEntryTitle,
                primaryActionLabel: context.l10n.onboardingDebtEntrySave,
                progressLabel: context.l10n.onboardingStep1,
                progressValue: 0.25,
                backButtonKey: AppTestKeys.onboardingDebtEntryBack,
                onCancel: () => _handleBack(context),
                onSaved: (context, debt) async {
                  unawaited(
                    getIt<OnboardingAnalytics>().trackDebtSaved(
                      debtCount: context.read<DebtsCubit>().state.debts.length,
                    ),
                  );
                  await navigateToOnboardingStep(
                    context,
                    step: OnboardingStep.addDebt,
                    route: AppRoutes.addAnotherDebt,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
