import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class I18nPubspecEditResult {
  const I18nPubspecEditResult({required this.content, required this.changed});

  final String content;
  final bool changed;
}

class I18nPubspecEditor {
  const I18nPubspecEditor();

  static const _intlVersion = '^0.20.1';

  I18nPubspecEditResult ensureI18nSupport(String content) {
    var nextContent = content;
    var changed = false;

    nextContent = _ensureMapPath(nextContent, ['dependencies']);
    nextContent = _ensureDependency(
      nextContent,
      key: 'flutter_localizations',
      value: const {'sdk': 'flutter'},
      onChanged: () => changed = true,
    );
    nextContent = _ensureDependency(
      nextContent,
      key: 'intl',
      value: _intlVersion,
      onChanged: () => changed = true,
    );
    nextContent = _ensureFlutterGenerate(
      nextContent,
      onChanged: () {
        changed = true;
      },
    );

    return I18nPubspecEditResult(
      content: _ensureTrailingNewline(nextContent),
      changed: changed,
    );
  }

  String _ensureDependency(
    String content, {
    required String key,
    required Object value,
    required void Function() onChanged,
  }) {
    final parsed = _loadRootMap(content);
    final dependencies = parsed['dependencies'];
    if (dependencies != null && dependencies is! YamlMap) {
      throw const FormatException(
        'pubspec.yaml "dependencies" section must be a map.',
      );
    }
    if (dependencies is YamlMap && dependencies.containsKey(key)) {
      return content;
    }

    final editor = YamlEditor(content);
    editor.update(['dependencies', key], value);
    onChanged();
    return editor.toString();
  }

  String _ensureFlutterGenerate(
    String content, {
    required void Function() onChanged,
  }) {
    var nextContent = _ensureMapPath(content, ['flutter']);
    final parsed = _loadRootMap(nextContent);
    final flutterSection = parsed['flutter'];
    if (flutterSection != null && flutterSection is! YamlMap) {
      throw const FormatException(
        'pubspec.yaml "flutter" section must be a map.',
      );
    }
    if (flutterSection is YamlMap && flutterSection['generate'] == true) {
      return nextContent;
    }

    final editor = YamlEditor(nextContent);
    editor.update(['flutter', 'generate'], true);
    onChanged();
    return editor.toString();
  }

  String _ensureMapPath(String content, List<Object> path) {
    var nextContent = content;
    for (var depth = 0; depth < path.length; depth++) {
      final segmentPath = path.sublist(0, depth + 1);
      final value = _readPath(_loadRootMap(nextContent), segmentPath);
      if (identical(value, _missingValue)) {
        final editor = YamlEditor(nextContent);
        editor.update(segmentPath, <String, Object?>{});
        nextContent = editor.toString();
        continue;
      }
      if (value == null) {
        final editor = YamlEditor(nextContent);
        editor.update(segmentPath, <String, Object?>{});
        nextContent = editor.toString();
        continue;
      }
      if (value is! YamlMap) {
        throw FormatException(
          'pubspec.yaml path "${segmentPath.join('.')}" must be a map.',
        );
      }
    }
    return nextContent;
  }

  YamlMap _loadRootMap(String content) {
    final parsed = loadYaml(content);
    if (parsed is! YamlMap) {
      throw const FormatException(
        'pubspec.yaml must contain a top-level YAML map.',
      );
    }
    return parsed;
  }

  Object? _readPath(YamlMap root, List<Object> path) {
    Object? current = root;
    for (final segment in path) {
      if (current is! YamlMap || !current.containsKey(segment)) {
        return _missingValue;
      }
      current = current[segment];
    }
    return current;
  }

  String _ensureTrailingNewline(String content) {
    return content.endsWith('\n') ? content : '$content\n';
  }
}

const _missingValue = Object();
