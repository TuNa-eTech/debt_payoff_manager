import 'dart:io';

import 'package:path/path.dart' as p;

import 'i18n_arb_store.dart';
import 'i18n_flutter_locator.dart';
import 'i18n_process_runner.dart';
import 'i18n_pubspec_editor.dart';

class I18nToolException implements Exception {
  const I18nToolException(this.message);

  final String message;

  @override
  String toString() => 'I18nToolException: $message';
}

class I18nMutationResult {
  const I18nMutationResult({
    required this.message,
    required this.changedFiles,
    required this.generated,
  });

  final String message;
  final List<String> changedFiles;
  final bool generated;
}

class I18nProjectService {
  I18nProjectService({
    I18nPubspecEditor? pubspecEditor,
    I18nArbStore? arbStore,
    I18nFlutterLocator? flutterLocator,
    I18nProcessRunner? processRunner,
  }) : _pubspecEditor = pubspecEditor ?? const I18nPubspecEditor(),
       _arbStore = arbStore ?? const I18nArbStore(),
       _flutterLocator = flutterLocator ?? const I18nFlutterLocator(),
       _processRunner = processRunner ?? const SystemI18nProcessRunner();

  static const _appName = 'Debt Payoff X';
  static const _appNameDescription = 'Application name shown in localized UI.';
  static const _enLocale = 'en';
  static const _viLocale = 'vi';
  static const _l10nYaml = '''
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
preferred-supported-locales:
  - en
  - vi
untranslated-messages-file: build/untranslated-messages.json
''';

  final I18nPubspecEditor _pubspecEditor;
  final I18nArbStore _arbStore;
  final I18nFlutterLocator _flutterLocator;
  final I18nProcessRunner _processRunner;

  Future<I18nMutationResult> initProject({
    required Directory root,
    required bool force,
    required bool runGenerate,
  }) async {
    final pubspecFile = _requireProjectRoot(root);
    final l10nFile = File(p.join(root.path, 'l10n.yaml'));
    final enArbFile = File(p.join(root.path, 'lib', 'l10n', 'app_en.arb'));
    final viArbFile = File(p.join(root.path, 'lib', 'l10n', 'app_vi.arb'));
    final transaction = _I18nFileTransaction(root);

    await transaction.captureAll([pubspecFile, l10nFile, enArbFile, viArbFile]);

    final changedFiles = <String>{};

    try {
      final pubspecContent = await pubspecFile.readAsString();
      final pubspecEdit = _pubspecEditor.ensureI18nSupport(pubspecContent);
      if (pubspecEdit.changed) {
        await transaction.writeText(pubspecFile, pubspecEdit.content);
        changedFiles.add(_relativePath(root, pubspecFile));
      }

      final l10nChange = await _ensureL10nYaml(
        file: l10nFile,
        force: force,
        transaction: transaction,
      );
      if (l10nChange.changed) {
        changedFiles.add(_relativePath(root, l10nFile));
      }

      final enChange = await _ensureArbFile(
        file: enArbFile,
        locale: _enLocale,
        force: force,
        transaction: transaction,
      );
      if (enChange.changed) {
        changedFiles.add(_relativePath(root, enArbFile));
      }

      final viChange = await _ensureArbFile(
        file: viArbFile,
        locale: _viLocale,
        force: force,
        transaction: transaction,
      );
      if (viChange.changed) {
        changedFiles.add(_relativePath(root, viArbFile));
      }

      if (runGenerate) {
        await _runFlutter(root, ['pub', 'get']);
        await _runFlutter(root, ['gen-l10n']);
      }

      final sortedFiles = changedFiles.toList()..sort();
      final changed = sortedFiles.isNotEmpty;

      return I18nMutationResult(
        message: changed
            ? 'Initialized i18n scaffold.'
            : 'i18n scaffold already initialized.',
        changedFiles: List<String>.unmodifiable(sortedFiles),
        generated: runGenerate,
      );
    } on Object catch (error) {
      await transaction.rollback();
      throw _wrapError(error);
    }
  }

  Future<I18nMutationResult> addStaticKey({
    required Directory root,
    required String key,
    required String en,
    required String vi,
    required String desc,
    required bool overwrite,
    required bool runGenerate,
  }) async {
    _requireProjectRoot(root);
    final normalizedKey = _normalizeStaticKey(key);
    _validateStaticValue('English text', en);
    _validateStaticValue('Vietnamese text', vi);
    _validateStaticValue('Description', desc);

    final l10nFile = File(p.join(root.path, 'l10n.yaml'));
    final enArbFile = File(p.join(root.path, 'lib', 'l10n', 'app_en.arb'));
    final viArbFile = File(p.join(root.path, 'lib', 'l10n', 'app_vi.arb'));
    if (!l10nFile.existsSync() ||
        !enArbFile.existsSync() ||
        !viArbFile.existsSync()) {
      throw const I18nToolException(
        'i18n scaffold is incomplete. Run init before adding keys.',
      );
    }

    final transaction = _I18nFileTransaction(root);
    await transaction.captureAll([enArbFile, viArbFile]);

    try {
      final enDocument = await _arbStore.load(
        enArbFile,
        expectedLocale: _enLocale,
      );
      final viDocument = await _arbStore.load(
        viArbFile,
        expectedLocale: _viLocale,
      );

      final keyExists =
          enDocument.containsKey(normalizedKey) ||
          viDocument.containsKey(normalizedKey);
      if (keyExists && !overwrite) {
        throw I18nToolException(
          'Key "$normalizedKey" already exists. Re-run with overwrite enabled to update it.',
        );
      }

      var changed = false;
      final changedFiles = <String>{};

      changed =
          enDocument.ensureStaticMessage(
            key: normalizedKey,
            value: en,
            description: desc,
            overwrite: overwrite,
          ) ||
          changed;
      changed =
          viDocument.ensureStaticMessage(
            key: normalizedKey,
            value: vi,
            description: desc,
            overwrite: overwrite,
          ) ||
          changed;

      final nextEnContent = enDocument.encodeCanonical();
      final currentEnContent = await enArbFile.readAsString();
      if (_normalizeText(currentEnContent) != _normalizeText(nextEnContent)) {
        await transaction.writeText(enArbFile, nextEnContent);
        changedFiles.add(_relativePath(root, enArbFile));
        changed = true;
      }

      final nextViContent = viDocument.encodeCanonical();
      final currentViContent = await viArbFile.readAsString();
      if (_normalizeText(currentViContent) != _normalizeText(nextViContent)) {
        await transaction.writeText(viArbFile, nextViContent);
        changedFiles.add(_relativePath(root, viArbFile));
        changed = true;
      }

      if (runGenerate && changed) {
        await _runFlutter(root, ['gen-l10n']);
      }

      final sortedFiles = changedFiles.toList()..sort();

      return I18nMutationResult(
        message: changed
            ? 'Added localization key "$normalizedKey".'
            : 'Localization key "$normalizedKey" already matches the requested values.',
        changedFiles: List<String>.unmodifiable(sortedFiles),
        generated: runGenerate && changed,
      );
    } on Object catch (error) {
      await transaction.rollback();
      throw _wrapError(error);
    }
  }

  File _requireProjectRoot(Directory root) {
    final pubspecFile = File(p.join(root.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw I18nToolException(
        'No pubspec.yaml found in "${root.path}". Run the helper from a Flutter project root.',
      );
    }
    return pubspecFile;
  }

  Future<_FileChange> _ensureL10nYaml({
    required File file,
    required bool force,
    required _I18nFileTransaction transaction,
  }) async {
    final expectedContent = _normalizeText(_l10nYaml);
    if (!file.existsSync()) {
      await transaction.writeText(file, expectedContent);
      return const _FileChange(changed: true);
    }

    final currentContent = _normalizeText(await file.readAsString());
    if (currentContent == expectedContent) {
      return const _FileChange(changed: false);
    }
    if (!force) {
      throw I18nToolException(
        'l10n.yaml already exists with different content. Re-run with force enabled to overwrite it.',
      );
    }

    await transaction.writeText(file, expectedContent);
    return const _FileChange(changed: true);
  }

  Future<_FileChange> _ensureArbFile({
    required File file,
    required String locale,
    required bool force,
    required _I18nFileTransaction transaction,
  }) async {
    final seeded = I18nArbDocument.seeded(
      locale: locale,
      appName: _appName,
      description: _appNameDescription,
    );
    final seededContent = seeded.encodeCanonical();

    if (!file.existsSync()) {
      await transaction.writeText(file, seededContent);
      return const _FileChange(changed: true);
    }

    try {
      final document = await _arbStore.load(file, expectedLocale: locale);
      document.ensureStaticMessage(
        key: 'appName',
        value: _appName,
        description: _appNameDescription,
        overwrite: false,
      );
      final nextContent = document.encodeCanonical();
      final currentContent = await file.readAsString();
      if (_normalizeText(currentContent) == _normalizeText(nextContent)) {
        return const _FileChange(changed: false);
      }

      await transaction.writeText(file, nextContent);
      return const _FileChange(changed: true);
    } on Exception {
      if (!force) {
        rethrow;
      }

      await transaction.writeText(file, seededContent);
      return const _FileChange(changed: true);
    }
  }

  Future<void> _runFlutter(Directory root, List<String> arguments) async {
    final executable = _flutterLocator.resolve(root);
    final result = await _processRunner.run(
      executable: executable,
      arguments: arguments,
      workingDirectory: root.path,
    );
    if (result.exitCode == 0) {
      return;
    }

    final output = [
      result.stdout.trim(),
      result.stderr.trim(),
    ].where((part) => part.isNotEmpty).join('\n');
    final outputSuffix = output.isEmpty ? '' : '\n$output';
    throw I18nToolException(
      'Failed to run "${[executable, ...arguments].join(' ')}".$outputSuffix',
    );
  }

  String _normalizeStaticKey(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      throw const I18nToolException('Key must not be empty.');
    }
    if (trimmed != key) {
      throw I18nToolException(
        'Key "$key" must not contain leading or trailing whitespace.',
      );
    }
    if (!RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(trimmed)) {
      throw I18nToolException(
        'Key "$key" must use lowerCamelCase and contain only letters and digits.',
      );
    }
    return trimmed;
  }

  void _validateStaticValue(String label, String value) {
    if (value.trim().isEmpty) {
      throw I18nToolException('$label must not be empty.');
    }
    if (value.contains('{') || value.contains('}')) {
      throw I18nToolException(
        '$label must not include ICU placeholders or braces in this helper version.',
      );
    }
  }

  String _relativePath(Directory root, File file) {
    return p.relative(file.path, from: root.path);
  }

  String _normalizeText(String value) {
    final normalized = value.replaceAll('\r\n', '\n');
    return normalized.endsWith('\n') ? normalized : '$normalized\n';
  }

  I18nToolException _wrapError(Object error) {
    if (error is I18nToolException) {
      return error;
    }
    if (error is FormatException ||
        error is ProcessException ||
        error is StateError) {
      return I18nToolException(error.toString());
    }
    return I18nToolException('Unexpected i18n mutation error: $error');
  }
}

final I18nProjectService _defaultI18nProjectService = I18nProjectService();

Future<I18nMutationResult> initProject({
  required Directory root,
  required bool force,
  required bool runGenerate,
}) {
  return _defaultI18nProjectService.initProject(
    root: root,
    force: force,
    runGenerate: runGenerate,
  );
}

Future<I18nMutationResult> addStaticKey({
  required Directory root,
  required String key,
  required String en,
  required String vi,
  required String desc,
  required bool overwrite,
  required bool runGenerate,
}) {
  return _defaultI18nProjectService.addStaticKey(
    root: root,
    key: key,
    en: en,
    vi: vi,
    desc: desc,
    overwrite: overwrite,
    runGenerate: runGenerate,
  );
}

class _FileChange {
  const _FileChange({required this.changed});

  final bool changed;
}

class _I18nFileTransaction {
  _I18nFileTransaction(this.root);

  final Directory root;
  final Map<String, String?> _snapshots = <String, String?>{};
  final Set<String> _createdDirectories = <String>{};

  Future<void> captureAll(List<File> files) async {
    for (final file in files) {
      await capture(file);
    }
  }

  Future<void> capture(File file) async {
    if (_snapshots.containsKey(file.path)) {
      return;
    }
    if (await file.exists()) {
      _snapshots[file.path] = await file.readAsString();
      return;
    }
    _snapshots[file.path] = null;
  }

  Future<void> writeText(File file, String content) async {
    final missingDirectories = _collectMissingDirectories(file.parent);
    if (missingDirectories.isNotEmpty) {
      await file.parent.create(recursive: true);
      _createdDirectories.addAll(
        missingDirectories.map((directory) => directory.path),
      );
    }

    final tempFile = File(
      '${file.path}.tmp.${DateTime.now().microsecondsSinceEpoch}',
    );
    await tempFile.writeAsString(content, flush: true);

    try {
      if (Platform.isWindows && await file.exists()) {
        await file.delete();
      }
      await tempFile.rename(file.path);
    } catch (_) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      rethrow;
    }
  }

  Future<void> rollback() async {
    final entries = _snapshots.entries.toList().reversed;
    for (final entry in entries) {
      final file = File(entry.key);
      final originalContent = entry.value;
      if (originalContent == null) {
        if (await file.exists()) {
          await file.delete();
        }
        continue;
      }
      await writeText(file, originalContent);
    }

    final directories = _createdDirectories.toList()
      ..sort((left, right) => right.length.compareTo(left.length));
    for (final path in directories) {
      final directory = Directory(path);
      if (!await directory.exists()) {
        continue;
      }
      if (p.equals(directory.path, root.path)) {
        continue;
      }
      if (directory.listSync().isEmpty) {
        await directory.delete();
      }
    }
  }

  List<Directory> _collectMissingDirectories(Directory directory) {
    final missing = <Directory>[];
    var current = directory;
    while (!current.existsSync() && !p.equals(current.path, root.path)) {
      missing.add(current);
      final parent = current.parent;
      if (p.equals(parent.path, current.path)) {
        break;
      }
      current = parent;
    }
    return missing.reversed.toList();
  }
}
