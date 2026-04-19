import 'package:equatable/equatable.dart';

class PickedBackupBundle extends Equatable {
  const PickedBackupBundle({required this.path, required this.fileName});

  final String path;
  final String fileName;

  @override
  List<Object?> get props => [path, fileName];
}
