import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:debt_payoff_manager/core/constants/app_test_keys.dart';
import 'package:debt_payoff_manager/core/di/injection.dart';
import 'package:debt_payoff_manager/core/services/data_management_service.dart';
import 'package:debt_payoff_manager/core/services/plan_recast_service.dart';
import 'package:debt_payoff_manager/core/services/report_generator_service.dart';
import 'package:debt_payoff_manager/core/services/share_launcher.dart';
import 'package:debt_payoff_manager/data/local/stores/timeline_cache_store.dart';
import 'package:debt_payoff_manager/domain/entities/timeline_projection.dart';
import 'package:debt_payoff_manager/domain/repositories/debt_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/plan_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_cubit.dart';
import 'package:debt_payoff_manager/features/debts/cubit/debts_state.dart';
import 'package:debt_payoff_manager/features/plan/cubit/plan_timeline_cubit.dart';
import 'package:debt_payoff_manager/features/plan/cubit/plan_timeline_state.dart';
import 'package:debt_payoff_manager/features/reports/presentation/pages/reports_preview_page.dart';
import 'package:debt_payoff_manager/features/settings/cubit/settings_cubit.dart';
import 'package:debt_payoff_manager/l10n/app_localizations.dart';

import '../../../data/repositories/repository_test_helpers.dart';

class _MockDebtRepository extends Mock implements DebtRepository {}

class _MockPlanRepository extends Mock implements PlanRepository {}

class _MockTimelineCacheStore extends Mock implements TimelineCacheStore {}

class _MockPlanRecastService extends Mock implements PlanRecastService {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

class _MockReportGeneratorService extends Mock
    implements ReportGeneratorService {}

class _MockDataManagementService extends Mock
    implements DataManagementService {}

class _MockShareLauncher extends Mock implements ShareLauncher {}

class _TestDebtsCubit extends DebtsCubit {
  _TestDebtsCubit() : super(debtRepository: _MockDebtRepository());

  void seed(DebtsState nextState) => emit(nextState);
}

class _TestPlanTimelineCubit extends PlanTimelineCubit {
  _TestPlanTimelineCubit()
    : super(
        debtRepository: _MockDebtRepository(),
        planRepository: _MockPlanRepository(),
        timelineCacheStore: _MockTimelineCacheStore(),
        planRecastService: _MockPlanRecastService(),
      );

  void seed(PlanTimelineState nextState) => emit(nextState);
}

void main() {
  testWidgets('reports preview changes range correctly', (
    tester,
  ) async {
    final settingsRepository = _MockSettingsRepository();
    final debtsCubit = _TestDebtsCubit()
      ..seed(
        DebtsState(
          isLoading: false,
          debts: [makeRepoDebt(id: 'report-debt', name: 'Report debt')],
        ),
      );
    final planTimelineCubit = _TestPlanTimelineCubit()
      ..seed(
        PlanTimelineState(
          isLoading: false,
          debts: [makeRepoDebt(id: 'report-debt', name: 'Report debt')],
          plan: makeRepoPlan(id: 'report-plan'),
          projection: _projection(),
        ),
      );
    when(() => settingsRepository.watchSettings()).thenAnswer((_) {
      return Stream.value(makeRepoSettings());
    });

    final settingsCubit = SettingsCubit(settingsRepository: settingsRepository);

    addTearDown(() async {
      await settingsCubit.close();
      await debtsCubit.close();
      await planTimelineCubit.close();
      await getIt.reset();
    });

    await getIt.reset();
    getIt
      ..registerSingleton<SettingsRepository>(settingsRepository)
      ..registerSingleton<ReportGeneratorService>(_MockReportGeneratorService())
      ..registerSingleton<DataManagementService>(_MockDataManagementService())
      ..registerSingleton<ShareLauncher>(_MockShareLauncher());

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<DebtsCubit>.value(value: debtsCubit),
            BlocProvider<PlanTimelineCubit>.value(value: planTimelineCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: const ReportsPreviewPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsWidgets);

    await tester.tap(
      find.byKey(
        AppTestKeys.reportsPreviewRange(ReportTimeRange.monthly.fileStem),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsWidgets);
  });
}

TimelineProjection _projection() {
  return TimelineProjection(
    planId: 'report-plan',
    generatedAt: DateTime.utc(2026, 1, 1),
    months: const [
      MonthProjection(
        monthIndex: 0,
        yearMonth: '2026-01',
        entries: [],
        totalPaymentThisMonth: 10000,
        totalInterestThisMonth: 1200,
        totalBalanceEndOfMonth: 90000,
      ),
    ],
  );
}
