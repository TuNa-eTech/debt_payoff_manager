import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/settings_repository.dart';
import '../../pricing/domain/entitlement_service.dart';
import '../../../sync/sync_auth_service.dart';
import '../data/sharing_service.dart';
import '../domain/sharing_models.dart';

part 'sharing_state.dart';

class SharingCubit extends Cubit<SharingState> {
  SharingCubit({
    required SharingService sharingService,
    required SettingsRepository settingsRepository,
    required SyncAuthService authService,
    required EntitlementService entitlementService,
  }) : _sharingService = sharingService,
       _settingsRepository = settingsRepository,
       _authService = authService,
       _entitlementService = entitlementService,
       super(const SharingState());

  final SharingService _sharingService;
  final SettingsRepository _settingsRepository;
  final SyncAuthService _authService;
  final EntitlementService _entitlementService;
  StreamSubscription<SharedPlan?>? _ownerPlanSubscription;
  StreamSubscription<List<SharedPlan>>? _partnerPlansSubscription;

  Future<void> start() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final settings = await _settingsRepository.getSettings();
      final account = await _authService.currentAccount();
      if (account == null || settings.firebaseUid == null) {
        emit(
          state.copyWith(
            isLoading: false,
            account: account,
            ownerPlan: null,
            partnerPlans: const [],
          ),
        );
        return;
      }

      await _ownerPlanSubscription?.cancel();
      _ownerPlanSubscription = _sharingService
          .watchOwnerPlan(
            ownerUid: settings.firebaseUid!,
            scenarioId: settings.activeScenarioId,
          )
          .listen(
            (plan) => emit(state.copyWith(ownerPlan: plan)),
            onError: (Object error) =>
                emit(state.copyWith(errorMessage: _message(error))),
          );

      await _partnerPlansSubscription?.cancel();
      _partnerPlansSubscription = _sharingService
          .watchPartnerPlans(partnerUid: account.uid)
          .listen(
            (plans) => emit(state.copyWith(partnerPlans: plans)),
            onError: (Object error) =>
                emit(state.copyWith(errorMessage: _message(error))),
          );

      emit(state.copyWith(isLoading: false, account: account));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _message(error)));
    }
  }

  Future<void> signInWithGoogle() async {
    await _run(() async {
      await _authService.signInWithGoogle();
      await start();
    });
  }

  Future<void> signInWithApple() async {
    await _run(() async {
      await _authService.signInWithApple();
      await start();
    });
  }

  Future<void> createInvite({
    required String partnerEmail,
    required SharingPermissionMode mode,
  }) async {
    await _run(() async {
      final settings = await _settingsRepository.getSettings();
      if (!_entitlementService.isPremiumActive(settings)) {
        throw StateError('Premium access is required.');
      }
      final result = await _sharingService.createInvite(
        scenarioId: settings.activeScenarioId,
        partnerEmail: partnerEmail,
        mode: mode,
      );
      await _settingsRepository.updateSettings(
        settings.copyWith(trustLevel: 2),
      );
      emit(state.copyWith(lastInviteResult: result));
    });
  }

  Future<void> revokePartner(String partnerUid) async {
    final plan = state.ownerPlan;
    if (plan == null) return;
    await _run(() async {
      await _sharingService.revokePartner(
        shareId: plan.id,
        partnerUid: partnerUid,
      );
      if (plan.partnerUids.length <= 1 && plan.pendingInvites.isEmpty) {
        final settings = await _settingsRepository.getSettings();
        await _settingsRepository.updateSettings(
          settings.copyWith(trustLevel: 1),
        );
      }
    });
  }

  void clearInviteResult() {
    emit(state.copyWith(clearLastInviteResult: true));
  }

  Future<void> _run(Future<void> Function() action) async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      await action();
      emit(state.copyWith(isBusy: false));
    } on SyncAuthCancelledException {
      emit(state.copyWith(isBusy: false));
    } catch (error) {
      emit(state.copyWith(isBusy: false, errorMessage: _message(error)));
    }
  }

  String _message(Object error) {
    const prefixes = ['Exception: ', 'Bad state: ', 'Invalid argument(s): '];
    var message = error.toString();
    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        message = message.substring(prefix.length);
      }
    }
    return message;
  }

  @override
  Future<void> close() async {
    await _ownerPlanSubscription?.cancel();
    await _partnerPlansSubscription?.cancel();
    return super.close();
  }
}
