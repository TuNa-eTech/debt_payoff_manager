import 'package:equatable/equatable.dart';

class BackupBundlePreview extends Equatable {
  const BackupBundlePreview({
    required this.path,
    required this.fileName,
    required this.bundleVersion,
    required this.schemaVersion,
    required this.exportedAtUtc,
    required this.tableRowCounts,
  });

  final String path;
  final String fileName;
  final int bundleVersion;
  final int schemaVersion;
  final DateTime exportedAtUtc;
  final Map<String, int> tableRowCounts;

  int get totalRows =>
      tableRowCounts.values.fold<int>(0, (sum, value) => sum + value);

  @override
  List<Object?> get props => [
    path,
    fileName,
    bundleVersion,
    schemaVersion,
    exportedAtUtc,
    tableRowCounts,
  ];
}
