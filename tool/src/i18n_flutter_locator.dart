import 'dart:io';

import 'package:path/path.dart' as p;

class I18nFlutterLocator {
  const I18nFlutterLocator({Map<String, String>? environment})
    : _environment = environment;

  final Map<String, String>? _environment;

  String resolve(Directory root) {
    final environment = _environment ?? Platform.environment;
    final binaryName = Platform.isWindows ? 'flutter.bat' : 'flutter';
    final bundledFlutter = File(
      p.join(root.path, '.fvm', 'flutter_sdk', 'bin', binaryName),
    );

    if (bundledFlutter.existsSync()) {
      return bundledFlutter.path;
    }

    final pathValue = environment['PATH'];
    if (pathValue != null && pathValue.isNotEmpty) {
      for (final segment in pathValue.split(Platform.pathSeparator)) {
        if (segment.isEmpty) {
          continue;
        }

        final candidate = File(p.join(segment, binaryName));
        if (candidate.existsSync()) {
          return candidate.path;
        }
      }
    }

    return binaryName;
  }
}
