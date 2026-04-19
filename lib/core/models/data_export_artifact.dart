import 'package:equatable/equatable.dart';

enum DataExportArtifactKind { csvBundle, localBackup }

class DataExportArtifact extends Equatable {
  const DataExportArtifact({
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.kind,
  });

  final String path;
  final String fileName;
  final String mimeType;
  final DataExportArtifactKind kind;

  @override
  List<Object?> get props => [path, fileName, mimeType, kind];
}
