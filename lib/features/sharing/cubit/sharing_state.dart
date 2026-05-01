part of 'sharing_cubit.dart';

class SharingState extends Equatable {
  const SharingState({
    this.isLoading = false,
    this.isBusy = false,
    this.account,
    this.ownerPlan,
    this.partnerPlans = const [],
    this.lastInviteResult,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isBusy;
  final SyncAuthAccount? account;
  final SharedPlan? ownerPlan;
  final List<SharedPlan> partnerPlans;
  final SharingInviteResult? lastInviteResult;
  final String? errorMessage;

  bool get isSignedIn => account != null;

  SharingState copyWith({
    bool? isLoading,
    bool? isBusy,
    SyncAuthAccount? account,
    SharedPlan? ownerPlan,
    List<SharedPlan>? partnerPlans,
    SharingInviteResult? lastInviteResult,
    String? errorMessage,
    bool clearError = false,
    bool clearLastInviteResult = false,
  }) {
    return SharingState(
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      account: account ?? this.account,
      ownerPlan: ownerPlan ?? this.ownerPlan,
      partnerPlans: partnerPlans ?? this.partnerPlans,
      lastInviteResult: clearLastInviteResult
          ? null
          : lastInviteResult ?? this.lastInviteResult,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isBusy,
    account,
    ownerPlan,
    partnerPlans,
    lastInviteResult,
    errorMessage,
  ];
}
