import 'dart:async';

import 'package:debt_payoff_manager/domain/entities/user_settings.dart';
import 'package:debt_payoff_manager/domain/repositories/settings_repository.dart';
import 'package:debt_payoff_manager/features/sharing/cubit/sharing_cubit.dart';
import 'package:debt_payoff_manager/features/sharing/data/sharing_service.dart';
import 'package:debt_payoff_manager/features/sharing/domain/sharing_models.dart';
import 'package:debt_payoff_manager/sync/sync_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeSharingService sharingService;
  late _FakeSettingsRepository settingsRepository;
  late _FakeSyncAuthService authService;
  late SharingCubit cubit;

  setUp(() {
    sharingService = _FakeSharingService();
    settingsRepository = _FakeSettingsRepository();
    authService = _FakeSyncAuthService();
    cubit = SharingCubit(
      sharingService: sharingService,
      settingsRepository: settingsRepository,
      authService: authService,
    );
  });

  tearDown(() async {
    await cubit.close();
    await sharingService.dispose();
  });

  test(
    'createInvite stores invite result and upgrades trust level to sharing',
    () async {
      await cubit.start();

      await cubit.createInvite(
        partnerEmail: 'partner@example.com',
        mode: SharingPermissionMode.collaborative,
      );

      expect(settingsRepository.settings.trustLevel, 2);
      expect(sharingService.createdInviteEmail, 'partner@example.com');
      expect(
        sharingService.createdInviteMode,
        SharingPermissionMode.collaborative,
      );
      expect(
        cubit.state.lastInviteResult?.inviteUrl.toString(),
        contains('token'),
      );
    },
  );

  test(
    'revokePartner downgrades to cloud backup when last partner is removed',
    () async {
      await cubit.start();
      sharingService.ownerController.add(
        _sharedPlan(partnerUids: const ['partner-uid']),
      );
      await pumpEventQueue();

      await cubit.revokePartner('partner-uid');

      expect(sharingService.revokedPartnerUid, 'partner-uid');
      expect(settingsRepository.settings.trustLevel, 1);
    },
  );

  test(
    'revokePartner keeps sharing trust level when other partners remain',
    () async {
      settingsRepository.settings = settingsRepository.settings.copyWith(
        trustLevel: 2,
      );
      await cubit.start();
      sharingService.ownerController.add(
        _sharedPlan(partnerUids: const ['partner-1', 'partner-2']),
      );
      await pumpEventQueue();

      await cubit.revokePartner('partner-1');

      expect(sharingService.revokedPartnerUid, 'partner-1');
      expect(settingsRepository.settings.trustLevel, 2);
    },
  );

  test(
    'start exposes accepted partner plans for shared-plan UAT entry',
    () async {
      final partnerPlan = _sharedPlan(
        ownerUid: 'household-owner',
        scenarioId: 'main',
        partnerUids: const ['owner-uid'],
        mode: SharingPermissionMode.collaborative,
      );

      await cubit.start();
      sharingService.partnerController.add([partnerPlan]);
      await pumpEventQueue();

      expect(cubit.state.partnerPlans, [partnerPlan]);
      expect(
        cubit.state.partnerPlans.single.mode,
        SharingPermissionMode.collaborative,
      );
    },
  );
}

SharedPlan _sharedPlan({
  String ownerUid = 'owner-uid',
  String scenarioId = 'main',
  SharingPermissionMode mode = SharingPermissionMode.readonly,
  List<String> partnerUids = const [],
}) {
  final now = DateTime.utc(2026, 5, 1);
  return SharedPlan(
    id: '${ownerUid}_$scenarioId',
    ownerUid: ownerUid,
    scenarioId: scenarioId,
    mode: mode,
    partnerUids: partnerUids,
    pendingInvites: const [],
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeSharingService implements SharingService {
  final ownerController = StreamController<SharedPlan?>.broadcast();
  final partnerController = StreamController<List<SharedPlan>>.broadcast();

  String? createdInviteEmail;
  SharingPermissionMode? createdInviteMode;
  String? revokedPartnerUid;

  Future<void> dispose() async {
    await ownerController.close();
    await partnerController.close();
  }

  @override
  Future<AcceptSharingInviteResult> acceptInvite(String token) async {
    return const AcceptSharingInviteResult(
      shareId: 'owner-uid_main',
      ownerUid: 'owner-uid',
      scenarioId: 'main',
      mode: SharingPermissionMode.readonly,
    );
  }

  @override
  Future<SharingInviteResult> createInvite({
    required String scenarioId,
    required String partnerEmail,
    required SharingPermissionMode mode,
  }) async {
    createdInviteEmail = partnerEmail;
    createdInviteMode = mode;
    return SharingInviteResult(
      shareId: 'owner-uid_$scenarioId',
      inviteUrl: Uri.parse('https://debtpayoff.app/invite?token=abc'),
      expiresAt: DateTime.utc(2026, 5, 8),
    );
  }

  @override
  Future<void> leaveSharedPlan(String shareId) async {}

  @override
  Future<void> logSharedPayment({
    required String shareId,
    required String debtId,
    required int amountCents,
    required DateTime date,
    String? note,
  }) async {}

  @override
  Future<void> revokePartner({
    required String shareId,
    required String partnerUid,
  }) async {
    revokedPartnerUid = partnerUid;
  }

  @override
  Stream<SharedPlan?> watchOwnerPlan({
    required String ownerUid,
    required String scenarioId,
  }) {
    return ownerController.stream;
  }

  @override
  Stream<List<SharedPlan>> watchPartnerPlans({required String partnerUid}) {
    return partnerController.stream;
  }

  @override
  Stream<SharedPlanSnapshot> watchSharedPlanSnapshot(SharedPlan plan) {
    return Stream.value(SharedPlanSnapshot(sharedPlan: plan, debts: const []));
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  UserSettings settings = UserSettings(
    trustLevel: 1,
    firebaseUid: 'owner-uid',
    createdAt: DateTime.utc(2026, 5, 1),
    updatedAt: DateTime.utc(2026, 5, 1),
  );

  @override
  Future<UserSettings> getSettings() async => settings;

  @override
  Future<void> updateSettings(UserSettings settings) async {
    this.settings = settings;
  }

  @override
  Stream<UserSettings> watchSettings() {
    return Stream.value(settings);
  }
}

class _FakeSyncAuthService implements SyncAuthService {
  @override
  Future<SyncAuthAccount?> currentAccount() async {
    return const SyncAuthAccount(
      uid: 'owner-uid',
      providerId: 'google.com',
      email: 'owner@example.com',
    );
  }

  @override
  Future<SyncAuthAccount> signInWithApple() async {
    return (await currentAccount())!;
  }

  @override
  Future<SyncAuthAccount> signInWithGoogle() async {
    return (await currentAccount())!;
  }

  @override
  Future<void> signOut() async {}
}
