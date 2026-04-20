import 'dart:io';

import 'i18n_project_service.dart';

typedef InitProjectFn =
    Future<I18nMutationResult> Function({
      required Directory root,
      required bool force,
      required bool runGenerate,
    });

typedef AddStaticKeyFn =
    Future<I18nMutationResult> Function({
      required Directory root,
      required String key,
      required String en,
      required String vi,
      required String desc,
      required bool overwrite,
      required bool runGenerate,
    });

final class I18nProjectActions {
  const I18nProjectActions({
    required this.initProject,
    required this.addStaticKey,
  });

  final InitProjectFn initProject;
  final AddStaticKeyFn addStaticKey;
}

abstract final class I18nCliExitCode {
  static const int success = 0;
  static const int usage = 64;
  static const int unavailable = 69;
  static const int software = 70;
  static const int config = 78;
}

class I18nCliFailureException implements Exception {
  const I18nCliFailureException(this.exitCode, this.message);

  final int exitCode;
  final String message;

  @override
  String toString() => message;
}

final class I18nServiceUnavailableException extends I18nCliFailureException {
  const I18nServiceUnavailableException(String message)
    : super(I18nCliExitCode.unavailable, message);
}

Future<int> runI18nCommand(
  List<String> arguments, {
  required I18nProjectActions actions,
  Directory? root,
  IOSink? stdoutSink,
  IOSink? stderrSink,
}) {
  final runner = I18nCommandRunner(
    actions: actions,
    root: root ?? Directory.current,
    stdoutSink: stdoutSink ?? stdout,
    stderrSink: stderrSink ?? stderr,
  );

  return runner.run(arguments);
}

final class I18nCommandRunner {
  I18nCommandRunner({
    required I18nProjectActions actions,
    required Directory root,
    required IOSink stdoutSink,
    required IOSink stderrSink,
  }) : _actions = actions,
       _root = root,
       _stdout = stdoutSink,
       _stderr = stderrSink;

  final I18nProjectActions _actions;
  final Directory _root;
  final IOSink _stdout;
  final IOSink _stderr;

  Future<int> run(List<String> arguments) async {
    try {
      return await _runInternal(arguments);
    } on _I18nCliUsageException catch (error) {
      _stderr.writeln('Error: ${error.message}');
      _stderr.writeln('');
      _stderr.write(error.helpText);
      return error.exitCode;
    } on I18nCliFailureException catch (error) {
      _stderr.writeln('Error: ${error.message}');
      return error.exitCode;
    } on ArgumentError catch (error) {
      _stderr.writeln('Error: ${error.message ?? error.toString()}');
      return I18nCliExitCode.usage;
    } on FormatException catch (error) {
      _stderr.writeln('Error: ${error.message}');
      return I18nCliExitCode.usage;
    } on FileSystemException catch (error) {
      _stderr.writeln('Error: ${error.message}');
      return I18nCliExitCode.config;
    } on ProcessException catch (error) {
      _stderr.writeln('Error: ${error.message}');
      return I18nCliExitCode.config;
    } on StateError catch (error) {
      _stderr.writeln('Error: $error');
      return I18nCliExitCode.config;
    } catch (error) {
      _stderr.writeln('Unexpected error: $error');
      return I18nCliExitCode.software;
    }
  }

  Future<int> _runInternal(List<String> arguments) async {
    if (arguments.isEmpty) {
      throw _usageError('Missing command.', helpText: _rootHelpText);
    }

    final command = arguments.first;
    final commandArguments = arguments.sublist(1);

    if (_isHelpFlag(command)) {
      _stdout.write(_rootHelpText);
      return I18nCliExitCode.success;
    }

    switch (command) {
      case 'init':
        return _runInit(commandArguments);
      case 'add':
        return _runAdd(commandArguments);
      default:
        throw _usageError(
          'Unknown command "$command".',
          helpText: _rootHelpText,
        );
    }
  }

  Future<int> _runInit(List<String> arguments) async {
    if (_containsHelpFlag(arguments)) {
      _stdout.write(_initHelpText);
      return I18nCliExitCode.success;
    }

    final options = _parseOptions(
      arguments,
      helpText: _initHelpText,
      booleanFlags: const <String>{'force', 'no-gen'},
    );

    if (options.positionals.isNotEmpty) {
      throw _usageError(
        'Unexpected positional arguments for "init": '
        '${_quoteValues(options.positionals)}.',
        helpText: _initHelpText,
      );
    }

    final runGenerate = !options.hasFlag('no-gen');

    final result = await _actions.initProject(
      root: _root,
      force: options.hasFlag('force'),
      runGenerate: runGenerate,
    );

    _stdout.writeln(result.message);
    if (!runGenerate) {
      _stdout.writeln('Skipped Flutter localization generation (--no-gen).');
    } else if (!result.generated) {
      _stdout.writeln(
        'Skipped Flutter localization generation because no files changed.',
      );
    }

    return I18nCliExitCode.success;
  }

  Future<int> _runAdd(List<String> arguments) async {
    if (_containsHelpFlag(arguments)) {
      _stdout.write(_addHelpText);
      return I18nCliExitCode.success;
    }

    final options = _parseOptions(
      arguments,
      helpText: _addHelpText,
      booleanFlags: const <String>{'overwrite', 'no-gen'},
      valueFlags: const <String>{'key', 'en', 'vi', 'desc'},
    );

    if (options.positionals.isNotEmpty) {
      throw _usageError(
        'Unexpected positional arguments for "add": '
        '${_quoteValues(options.positionals)}.',
        helpText: _addHelpText,
      );
    }

    final key = options.requireValue('key', helpText: _addHelpText);
    final english = options.requireValue('en', helpText: _addHelpText);
    final vietnamese = options.requireValue('vi', helpText: _addHelpText);
    final description = options.requireValue('desc', helpText: _addHelpText);
    final runGenerate = !options.hasFlag('no-gen');

    final result = await _actions.addStaticKey(
      root: _root,
      key: key,
      en: english,
      vi: vietnamese,
      desc: description,
      overwrite: options.hasFlag('overwrite'),
      runGenerate: runGenerate,
    );

    _stdout.writeln(result.message);
    if (!runGenerate) {
      _stdout.writeln('Skipped Flutter localization generation (--no-gen).');
    } else if (!result.generated) {
      _stdout.writeln(
        'Skipped Flutter localization generation because no files changed.',
      );
    }

    return I18nCliExitCode.success;
  }

  _ParsedOptions _parseOptions(
    List<String> arguments, {
    required String helpText,
    Set<String> booleanFlags = const <String>{},
    Set<String> valueFlags = const <String>{},
  }) {
    final parsed = _ParsedOptions();

    for (var index = 0; index < arguments.length; index += 1) {
      final argument = arguments[index];

      if (_isHelpFlag(argument)) {
        continue;
      }

      if (!argument.startsWith('-')) {
        parsed.positionals.add(argument);
        continue;
      }

      if (!argument.startsWith('--')) {
        throw _usageError(
          'Unsupported short option "$argument". Use --long-form flags or -h.',
          helpText: helpText,
        );
      }

      final equalsIndex = argument.indexOf('=');
      final name = equalsIndex == -1
          ? argument.substring(2)
          : argument.substring(2, equalsIndex);

      if (name.isEmpty) {
        throw _usageError('Invalid option "$argument".', helpText: helpText);
      }

      final inlineValue = equalsIndex == -1
          ? null
          : argument.substring(equalsIndex + 1);

      if (booleanFlags.contains(name)) {
        if (inlineValue != null) {
          throw _usageError(
            'Option "--$name" does not take a value.',
            helpText: helpText,
          );
        }

        if (!parsed.flags.add(name)) {
          throw _usageError(
            'Option "--$name" was provided more than once.',
            helpText: helpText,
          );
        }

        continue;
      }

      if (valueFlags.contains(name)) {
        if (parsed.values.containsKey(name)) {
          throw _usageError(
            'Option "--$name" was provided more than once.',
            helpText: helpText,
          );
        }

        final value =
            inlineValue ?? _takeOptionValue(arguments, index, name, helpText);
        if (inlineValue == null) {
          index += 1;
        }

        if (value.isEmpty) {
          throw _usageError(
            'Option "--$name" cannot be empty.',
            helpText: helpText,
          );
        }

        parsed.values[name] = value;
        continue;
      }

      throw _usageError('Unknown option "--$name".', helpText: helpText);
    }

    return parsed;
  }

  String _takeOptionValue(
    List<String> arguments,
    int optionIndex,
    String name,
    String helpText,
  ) {
    final nextIndex = optionIndex + 1;
    if (nextIndex >= arguments.length) {
      throw _usageError(
        'Option "--$name" requires a value.',
        helpText: helpText,
      );
    }

    final value = arguments[nextIndex];
    if (value == '-h' || value == '--help' || value.startsWith('--')) {
      throw _usageError(
        'Option "--$name" requires a value.',
        helpText: helpText,
      );
    }

    return value;
  }

  bool _containsHelpFlag(List<String> arguments) {
    return arguments.any(_isHelpFlag);
  }

  bool _isHelpFlag(String value) {
    return value == '-h' || value == '--help';
  }

  String _quoteValues(Iterable<String> values) {
    return values.map((value) => '"$value"').join(', ');
  }

  _I18nCliUsageException _usageError(
    String message, {
    required String helpText,
  }) {
    return _I18nCliUsageException(message, helpText: helpText);
  }
}

final class _ParsedOptions {
  final Set<String> flags = <String>{};
  final Map<String, String> values = <String, String>{};
  final List<String> positionals = <String>[];

  bool hasFlag(String name) => flags.contains(name);

  String requireValue(String name, {required String helpText}) {
    final value = values[name];
    if (value == null) {
      throw _I18nCliUsageException(
        'Missing required option "--$name".',
        helpText: helpText,
      );
    }

    return value;
  }
}

final class _I18nCliUsageException implements Exception {
  const _I18nCliUsageException(this.message, {required this.helpText});

  final String message;
  final String helpText;
  final int exitCode = I18nCliExitCode.usage;

  @override
  String toString() => message;
}

const String _rootHelpText = '''
Usage:
  dart run tool/i18n.dart <command> [options]

Commands:
  init    Bootstrap the i18n scaffold for this Flutter project.
  add     Add a static string to app_en.arb and app_vi.arb.

Global options:
  -h, --help    Show this help message.

Run "dart run tool/i18n.dart <command> --help" for command-specific usage.
''';

const String _initHelpText = '''
Usage:
  dart run tool/i18n.dart init [--force] [--no-gen]

Options:
  --force     Allow the project service to overwrite conflicting scaffold files.
  --no-gen    Skip Flutter localization generation after initialization.
  -h, --help  Show this help message.
''';

const String _addHelpText = '''
Usage:
  dart run tool/i18n.dart add --key <lowerCamelCase> --en <text> --vi <text> --desc <text> [--overwrite] [--no-gen]

Options:
  --key         Translation key to add.
  --en          English string value.
  --vi          Vietnamese string value.
  --desc        Description metadata for the key.
  --overwrite   Update an existing key instead of failing.
  --no-gen      Skip Flutter localization generation after writing ARB files.
  -h, --help    Show this help message.
''';
