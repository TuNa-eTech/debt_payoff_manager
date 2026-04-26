import 'package:equatable/equatable.dart';

/// A what-if scenario — groups debts, payments, plan, and milestones
/// under a named context.
///
/// The default scenario has id = 'main' and isMain = true.
class Scenario extends Equatable {
  const Scenario({
    required this.id,
    required this.name,
    this.isMain = false,
    required this.createdAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final bool isMain;
  final DateTime createdAt;
  final DateTime? deletedAt;

  Scenario copyWith({
    String? id,
    String? name,
    bool? isMain,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return Scenario(
      id: id ?? this.id,
      name: name ?? this.name,
      isMain: isMain ?? this.isMain,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, isMain, createdAt, deletedAt];
}
