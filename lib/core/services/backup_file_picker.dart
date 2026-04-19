import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/picked_backup_bundle.dart';

abstract class BackupFilePicker {
  Future<PickedBackupBundle?> pickBackupBundle();
}

class FilePickerBackupFilePicker implements BackupFilePicker {
  FilePickerBackupFilePicker({
    Future<Directory> Function()? temporaryDirectoryProvider,
  }) : _temporaryDirectoryProvider =
           temporaryDirectoryProvider ?? getTemporaryDirectory;

  final Future<Directory> Function() _temporaryDirectoryProvider;

  @override
  Future<PickedBackupBundle?> pickBackupBundle() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final picked = result.files.single;
    if (picked.path case final filePath?) {
      return PickedBackupBundle(path: filePath, fileName: picked.name);
    }

    final bytes = picked.bytes;
    if (bytes == null) {
      throw StateError('Không thể đọc file backup đã chọn.');
    }

    final directory = await _temporaryDirectoryProvider();
    await directory.create(recursive: true);

    final fileName = picked.name.isEmpty
        ? 'debt_payoff_backup_import.zip'
        : picked.name;
    final tempPath = path.join(directory.path, fileName);
    await File(tempPath).writeAsBytes(bytes, flush: true);

    return PickedBackupBundle(path: tempPath, fileName: fileName);
  }
}
