import 'package:equatable/equatable.dart';

enum SharingPermissionMode {
  readonly('readonly'),
  collaborative('collaborative');

  const SharingPermissionMode(this.wireValue);

  final String wireValue;

  static SharingPermissionMode fromWire(String value) {
    return SharingPermissionMode.values.firstWhere(
      (mode) => mode.wireValue == value,
      orElse: () => SharingPermissionMode.readonly,
    );
  }
}

class SharingInvite extends Equatable {
  const SharingInvite({
    required this.email,
    required this.createdAt,
    required this.expiresAt,
  });

  final String email;
  final DateTime createdAt;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [email, createdAt, expiresAt];
}

class SharedPlan extends Equatable {
  const SharedPlan({
    required this.id,
    required this.ownerUid,
    required this.scenarioId,
    required this.mode,
    required this.partnerUids,
    required this.pendingInvites,
    required this.createdAt,
    required this.updatedAt,
    this.revokedAt,
  });

  final String id;
  final String ownerUid;
  final String scenarioId;
  final SharingPermissionMode mode;
  final List<String> partnerUids;
  final List<SharingInvite> pendingInvites;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? revokedAt;

  bool get isActive => revokedAt == null;
  bool get hasPendingInvites => pendingInvites.isNotEmpty;
  bool get hasPartners => partnerUids.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    ownerUid,
    scenarioId,
    mode,
    partnerUids,
    pendingInvites,
    createdAt,
    updatedAt,
    revokedAt,
  ];
}

class SharingInviteResult extends Equatable {
  const SharingInviteResult({
    required this.shareId,
    required this.inviteUrl,
    required this.expiresAt,
  });

  final String shareId;
  final Uri inviteUrl;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [shareId, inviteUrl, expiresAt];
}

class AcceptSharingInviteResult extends Equatable {
  const AcceptSharingInviteResult({
    required this.shareId,
    required this.ownerUid,
    required this.scenarioId,
    required this.mode,
  });

  final String shareId;
  final String ownerUid;
  final String scenarioId;
  final SharingPermissionMode mode;

  @override
  List<Object?> get props => [shareId, ownerUid, scenarioId, mode];
}

class SharedDebtSnapshot extends Equatable {
  const SharedDebtSnapshot({
    required this.id,
    required this.name,
    required this.currentBalanceCents,
    required this.apr,
    required this.status,
  });

  final String id;
  final String name;
  final int currentBalanceCents;
  final String apr;
  final String status;

  @override
  List<Object?> get props => [id, name, currentBalanceCents, apr, status];
}

class SharedPlanSnapshot extends Equatable {
  const SharedPlanSnapshot({required this.sharedPlan, required this.debts});

  final SharedPlan sharedPlan;
  final List<SharedDebtSnapshot> debts;

  int get totalBalanceCents {
    return debts.fold<int>(
      0,
      (total, debt) => total + debt.currentBalanceCents,
    );
  }

  @override
  List<Object?> get props => [sharedPlan, debts];
}
