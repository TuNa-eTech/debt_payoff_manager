import 'dart:collection';
import 'dart:convert';
import 'dart:io';

class I18nArbDocument {
  I18nArbDocument._(this._entries);

  factory I18nArbDocument.fromJson(
    String content, {
    required String expectedLocale,
  }) {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('ARB files must decode to a JSON object.');
    }

    final locale = decoded['@@locale'];
    if (locale is! String || locale.isEmpty) {
      throw const FormatException(
        'ARB files must define a non-empty @@locale.',
      );
    }
    if (locale != expectedLocale) {
      throw FormatException(
        'Expected @@locale "$expectedLocale" but found "$locale".',
      );
    }

    return I18nArbDocument._(LinkedHashMap<String, Object?>.from(decoded));
  }

  factory I18nArbDocument.seeded({
    required String locale,
    required String appName,
    required String description,
  }) {
    final document = I18nArbDocument._(
      LinkedHashMap<String, Object?>.from({'@@locale': locale}),
    );
    document.ensureStaticMessage(
      key: 'appName',
      value: appName,
      description: description,
      overwrite: true,
    );
    return document;
  }

  final LinkedHashMap<String, Object?> _entries;

  bool containsKey(String key) => _entries.containsKey(key);

  bool ensureStaticMessage({
    required String key,
    required String value,
    required String description,
    required bool overwrite,
  }) {
    var changed = false;

    if (!_entries.containsKey(key)) {
      _entries[key] = value;
      changed = true;
    } else if (overwrite && _entries[key] != value) {
      _entries[key] = value;
      changed = true;
    }

    final metadataKey = '@$key';
    final existingMetadata = _entries[metadataKey];
    final metadata = _cloneMetadata(existingMetadata);
    if (metadata['description'] != description) {
      metadata['description'] = description;
      changed = true;
    }
    if (!_entries.containsKey(metadataKey) || existingMetadata is! Map) {
      changed = true;
    }
    _entries[metadataKey] = metadata;

    return changed;
  }

  String encodeCanonical() {
    final orderedEntries = <String, Object?>{};
    final locale = _entries['@@locale'];
    if (locale is! String || locale.isEmpty) {
      throw const FormatException('ARB document is missing a valid @@locale.');
    }

    orderedEntries['@@locale'] = locale;

    final globalMetadataKeys =
        _entries.keys
            .where((key) => key.startsWith('@@') && key != '@@locale')
            .toList()
          ..sort();
    for (final key in globalMetadataKeys) {
      orderedEntries[key] = _entries[key];
    }

    final messageKeys =
        _entries.keys
            .where((key) => !key.startsWith('@'))
            .where((key) => key != '@@locale')
            .toList()
          ..sort();
    for (final key in messageKeys) {
      orderedEntries[key] = _entries[key];
      final metadataKey = '@$key';
      if (_entries.containsKey(metadataKey)) {
        orderedEntries[metadataKey] = _entries[metadataKey];
      }
    }

    final danglingMetadataKeys =
        _entries.keys
            .where((key) => key.startsWith('@') && !key.startsWith('@@'))
            .where((key) => !orderedEntries.containsKey(key))
            .toList()
          ..sort();
    for (final key in danglingMetadataKeys) {
      orderedEntries[key] = _entries[key];
    }

    return '${const JsonEncoder.withIndent('  ').convert(orderedEntries)}\n';
  }

  Map<String, Object?> _cloneMetadata(Object? metadata) {
    if (metadata == null) {
      return <String, Object?>{};
    }
    if (metadata is! Map) {
      throw const FormatException('ARB metadata entries must be JSON objects.');
    }
    return LinkedHashMap<String, Object?>.from(
      metadata.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
}

class I18nArbStore {
  const I18nArbStore();

  Future<I18nArbDocument> load(
    File file, {
    required String expectedLocale,
  }) async {
    final content = await file.readAsString();
    return I18nArbDocument.fromJson(content, expectedLocale: expectedLocale);
  }

  Future<String> readCanonical(
    File file, {
    required String expectedLocale,
  }) async {
    final document = await load(file, expectedLocale: expectedLocale);
    return document.encodeCanonical();
  }
}
