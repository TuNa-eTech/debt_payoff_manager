import 'dart:convert';
import 'dart:io';

class I18nProcessResult {
  const I18nProcessResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
}

abstract class I18nProcessRunner {
  Future<I18nProcessResult> run({
    required String executable,
    required List<String> arguments,
    required String workingDirectory,
  });
}

class SystemI18nProcessRunner implements I18nProcessRunner {
  const SystemI18nProcessRunner();

  @override
  Future<I18nProcessResult> run({
    required String executable,
    required List<String> arguments,
    required String workingDirectory,
  }) async {
    final result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
      environment: Platform.environment,
      runInShell: true,
    );

    return I18nProcessResult(
      exitCode: result.exitCode,
      stdout: result.stdout as String,
      stderr: result.stderr as String,
    );
  }
}
