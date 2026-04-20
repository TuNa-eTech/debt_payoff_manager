import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class I18nTestWorkspace {
  I18nTestWorkspace._(this.root, this._sandboxRoot);

  static final String _repoRoot = Directory.current.path;
  static final String _fixturesRoot = p.join(
    _repoRoot,
    'test',
    'tool',
    'fixtures',
  );
  static final String _toolScriptPath = p.join(_repoRoot, 'tool', 'i18n.dart');
  static final String _packageConfigPath = p.join(
    _repoRoot,
    '.dart_tool',
    'package_config.json',
  );
  static final String _repoDartPath = p.join(
    _repoRoot,
    '.fvm',
    'flutter_sdk',
    'bin',
    Platform.isWindows ? 'dart.bat' : 'dart',
  );
  static final String flutterBinaryName = Platform.isWindows
      ? 'flutter.bat'
      : 'flutter';

  final Directory root;
  final Directory _sandboxRoot;

  static bool get hasToolScript => File(_toolScriptPath).existsSync();

  static Future<I18nTestWorkspace> fromFixture(String name) async {
    final fixtureRoot = Directory(p.join(_fixturesRoot, name));
    if (!fixtureRoot.existsSync()) {
      throw StateError('Missing fixture: ${fixtureRoot.path}');
    }

    final sandboxRoot = await Directory.systemTemp.createTemp(
      'i18n-script-test-',
    );
    await _copyDirectory(fixtureRoot, sandboxRoot);
    return I18nTestWorkspace._(sandboxRoot, sandboxRoot);
  }

  File file(String relativePath) => File(p.join(root.path, relativePath));

  Directory directory(String relativePath) =>
      Directory(p.join(root.path, relativePath));

  String readFile(String relativePath) => file(relativePath).readAsStringSync();

  Map<String, dynamic> readJson(String relativePath) =>
      jsonDecode(readFile(relativePath)) as Map<String, dynamic>;

  List<String> readFlutterLogLines() {
    final log = file('.tmp/flutter_invocations.log');
    if (!log.existsSync()) {
      return const [];
    }
    return log
        .readAsLinesSync()
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<I18nCliResult> run(
    List<String> args, {
    bool installPathFlutter = true,
    bool installFvmFlutter = true,
    String? failOnSubstring,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final homeDirectory = directory('.tmp/home')..createSync(recursive: true);
    final pathFlutterBin = directory('.tmp/bin');
    final env = <String, String>{...Platform.environment};

    if (installPathFlutter) {
      await _installFakeFlutter(
        filePath: p.join(pathFlutterBin.path, flutterBinaryName),
        label: 'PATH',
      );
    }

    if (installFvmFlutter) {
      await _installFakeFlutter(
        filePath: p.join(
          root.path,
          '.fvm',
          'flutter_sdk',
          'bin',
          flutterBinaryName,
        ),
        label: 'FVM',
      );
    }

    final currentPath = env['PATH'];
    env['PATH'] = currentPath == null || currentPath.isEmpty
        ? pathFlutterBin.path
        : '${pathFlutterBin.path}${Platform.pathSeparator}$currentPath';
    env['HOME'] = homeDirectory.path;
    env['DART_SUPPRESS_ANALYTICS'] = 'true';
    env['FLUTTER_SUPPRESS_ANALYTICS'] = 'true';
    env['CI'] = 'true';
    env['FAKE_FLUTTER_LOG'] = file('.tmp/flutter_invocations.log').path;
    if (failOnSubstring != null) {
      env['FAKE_FLUTTER_FAIL_ON'] = failOnSubstring;
    }

    final process = await Process.start(
      _dartExecutable,
      <String>[
        '--packages=$_packageConfigPath',
        'run',
        _toolScriptPath,
        ...args,
      ],
      workingDirectory: root.path,
      environment: env,
    );

    final stdoutFuture = process.stdout.transform(utf8.decoder).join();
    final stderrFuture = process.stderr.transform(utf8.decoder).join();

    var exitCode = -1;
    var timedOut = false;
    try {
      exitCode = await process.exitCode.timeout(timeout);
    } on TimeoutException {
      timedOut = true;
      process.kill(ProcessSignal.sigkill);
    }

    return I18nCliResult(
      exitCode: exitCode,
      stdout: await stdoutFuture,
      stderr: await stderrFuture,
      timedOut: timedOut,
    );
  }

  Future<void> dispose() async {
    if (_sandboxRoot.existsSync()) {
      await _sandboxRoot.delete(recursive: true);
    }
  }

  Future<void> _installFakeFlutter({
    required String filePath,
    required String label,
  }) async {
    final script = File(filePath);
    await script.parent.create(recursive: true);
    await script.writeAsString(_fakeFlutterScript(label));
    final chmodResult = await Process.run('/bin/chmod', <String>[
      '+x',
      script.path,
    ]);
    if (chmodResult.exitCode != 0) {
      throw StateError(
        'Unable to mark fake flutter executable: ${chmodResult.stderr}',
      );
    }
  }

  static String _fakeFlutterScript(String label) =>
      '''
#!/bin/sh
set -eu

log_path="\${FAKE_FLUTTER_LOG:?missing FAKE_FLUTTER_LOG}"
mkdir -p "\$(dirname "\$log_path")"
printf '%s|%s\n' "$label" "\$*" >> "\$log_path"

if [ "\${FAKE_FLUTTER_FAIL_ON:-}" != "" ]; then
  case "\$*" in
    *"\$FAKE_FLUTTER_FAIL_ON"*)
      exit 1
      ;;
  esac
fi

if [ "\$#" -gt 0 ] && [ "\$1" = "gen-l10n" ]; then
  mkdir -p build
  printf '{}' > build/untranslated-messages.json
fi

exit 0
''';

  static Future<void> _copyDirectory(
    Directory source,
    Directory destination,
  ) async {
    await for (final entity in source.list(recursive: false)) {
      final childPath = p.join(destination.path, p.basename(entity.path));
      if (entity is Directory) {
        final target = Directory(childPath);
        await target.create(recursive: true);
        await _copyDirectory(entity, target);
      } else if (entity is File) {
        await entity.copy(childPath);
      }
    }
  }

  String get _dartExecutable {
    final repoDart = File(_repoDartPath);
    if (repoDart.existsSync()) {
      return repoDart.path;
    }
    return Platform.resolvedExecutable;
  }
}

class I18nCliResult {
  const I18nCliResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.timedOut,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
  final bool timedOut;

  String get debugSummary =>
      'timedOut: $timedOut\nexitCode: $exitCode\nstdout:\n$stdout\nstderr:\n$stderr';
}
