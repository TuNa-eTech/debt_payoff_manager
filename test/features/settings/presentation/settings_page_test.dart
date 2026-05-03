import 'dart:async';

import 'package:debt_payoff_manager/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:debt_payoff_manager/core/di/injection.dart';
import 'package:debt_payoff_manager/core/services/backup_file_picker.dart';
import 'package:debt_payoff_manager/core/services/data_management_service.dart';
import 'package:debt_payoff_manager/core/services/share_launcher.dart';
import 'package:debt_payoff_manager/domain/entities/plan.dart';
import 'package:debt_payoff_manager/domain/entities/user_settings.dart';
import 'package:debt_payoff_manager/domain/repositories/plan_repository.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';
import 'package:debt_payoff_manager/features/pricing/domain/entitlement_service.dart';
import 'package:debt_payoff_manager/features/pricing/domain/premium_models.dart';
import 'package:debt_payoff_manager/features/settings/presentation/pages/settings_page.dart';
import 'package:debt_payoff_manager/l10n/app_localizations.dart';

import '../../../data/repositories/repository_test_helpers.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

class _MockPlanRepository extends Mock implements PlanRepository {}

class _MockBackupFilePicker extends Mock implements BackupFilePicker {}

class _MockDataManagementService extends Mock
    implements DataManagementService {}

class _MockShareLauncher extends Mock implements ShareLauncher {}

class _FakeEntitlementService implements EntitlementService {
  const _FakeEntitlementService();

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  bool isPremiumActive(UserSettings? settings) =>
      settings != null &&
      settings.isPremium &&
      (settings.premiumExpiresAt == null ||
          settings.premiumExpiresAt!.isAfter(DateTime.now().toUtc()));

  @override
  Future<EntitlementSnapshot> refreshEntitlement() async =>
      const EntitlementSnapshot.free();

  @override
  Future<EntitlementSnapshot> validatePurchase(
    PremiumPurchase purchase,
  ) async => const EntitlementSnapshot.free();

  @override
  Stream<PremiumEntitlementEvent> watchEvents() => const Stream.empty();
}

void main() {
  testWidgets('settings page keeps settings and plan streams across rebuilds', (
    tester,
  ) async {
    final settingsRepository = _MockSettingsRepository();
    final planRepository = _MockPlanRepository();
    final settingsStream = StreamController<dynamic>.broadcast();
    final planStream = StreamController<dynamic>.broadcast();
    var settingsWatchCalls = 0;
    var planWatchCalls = 0;

    addTearDown(() async {
      await settingsStream.close();
      await planStream.close();
      await getIt.reset();
    });

    await getIt.reset();
    getIt
      ..registerSingleton<SettingsRepository>(settingsRepository)
      ..registerSingleton<PlanRepository>(planRepository)
      ..registerSingleton<BackupFilePicker>(_MockBackupFilePicker())
      ..registerSingleton<DataManagementService>(_MockDataManagementService())
      ..registerSingleton<ShareLauncher>(_MockShareLauncher())
      ..registerSingleton<EntitlementService>(const _FakeEntitlementService());
    when(() => settingsRepository.watchSettings()).thenAnswer((_) {
      settingsWatchCalls += 1;
      return settingsStream.stream.cast<UserSettings>();
    });
    when(() => planRepository.watchCurrentPlan()).thenAnswer((_) {
      planWatchCalls += 1;
      return planStream.stream.cast<Plan?>();
    });

    await tester.pumpWidget(_settingsTestApp());
    settingsStream.add(makeRepoSettings());
    planStream.add(makeRepoPlan(extraMonthlyAmount: 10000));
    await tester.pump();

    expect(find.text('Settings'), findsOneWidget);
    expect(settingsWatchCalls, 1);
    expect(planWatchCalls, 1);

    await tester.pumpWidget(_settingsTestApp());
    await tester.pump();

    expect(find.text('Settings'), findsOneWidget);
    expect(settingsWatchCalls, 1);
    expect(planWatchCalls, 1);
  });
}

Widget _settingsTestApp() {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider(
      create: (context) =>
          SettingsCubit(settingsRepository: getIt<SettingsRepository>()),
      child: const SettingsPage(),
    ),
  );
}
