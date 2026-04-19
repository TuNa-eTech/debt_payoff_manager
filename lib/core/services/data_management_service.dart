import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../data/local/database.dart';
import '../../domain/enums/debt_status.dart';
import '../../domain/enums/debt_type.dart';
import '../../domain/enums/interest_method.dart';
import '../../domain/enums/milestone_type.dart';
import '../../domain/enums/min_payment_type.dart';
import '../../domain/enums/payment_cadence.dart';
import '../../domain/enums/payment_type.dart';
import '../../domain/enums/strategy.dart';
import '../models/backup_bundle_preview.dart';
import '../models/data_export_artifact.dart';

typedef TemporaryDirectoryProvider = Future<Directory> Function();
typedef NowProvider = DateTime Function();

class DataManagementService {
  DataManagementService({
    required AppDatabase db,
    TemporaryDirectoryProvider? temporaryDirectoryProvider,
    NowProvider? nowProvider,
  }) : _db = db,
       _temporaryDirectoryProvider =
           temporaryDirectoryProvider ?? getTemporaryDirectory,
       _nowProvider = nowProvider ?? DateTime.now;

  final AppDatabase _db;
  final TemporaryDirectoryProvider _temporaryDirectoryProvider;
  final NowProvider _nowProvider;

  static const String _zipMimeType = 'application/zip';
  static const int _bundleVersion = 1;

  static final List<_ExportDescriptor> _exportDescriptors = [
    _ExportDescriptor(
      fileStem: 'debts',
      tableName: 'debts',
      resultSet: _TableRef.debts,
      columns: const [
        _ExportColumn('id'),
        _ExportColumn('scenario_id'),
        _ExportColumn('name'),
        _ExportColumn('type'),
        _ExportColumn('original_principal_cents'),
        _ExportColumn('current_balance_cents'),
        _ExportColumn('apr'),
        _ExportColumn('interest_method'),
        _ExportColumn('minimum_payment_cents'),
        _ExportColumn('minimum_payment_type'),
        _ExportColumn('minimum_payment_percent'),
        _ExportColumn('minimum_payment_floor_cents'),
        _ExportColumn('payment_cadence'),
        _ExportColumn('due_day_of_month'),
        _ExportColumn('first_due_date'),
        _ExportColumn('status'),
        _ExportColumn('paused_until'),
        _ExportColumn('priority'),
        _ExportColumn(
          'exclude_from_strategy',
          valueType: _ExportValueType.boolean,
        ),
        _ExportColumn('created_at'),
        _ExportColumn('updated_at'),
        _ExportColumn('paid_off_at'),
        _ExportColumn('deleted_at'),
      ],
      orderBy: 'scenario_id ASC, updated_at ASC, created_at ASC, id ASC',
      filtersSoftDeleted: true,
    ),
    _ExportDescriptor(
      fileStem: 'payments',
      tableName: 'payments',
      resultSet: _TableRef.payments,
      columns: const [
        _ExportColumn('id'),
        _ExportColumn('scenario_id'),
        _ExportColumn('debt_id'),
        _ExportColumn('amount_cents'),
        _ExportColumn('principal_portion_cents'),
        _ExportColumn('interest_portion_cents'),
        _ExportColumn('fee_portion_cents'),
        _ExportColumn('date'),
        _ExportColumn('type'),
        _ExportColumn('source'),
        _ExportColumn('note'),
        _ExportColumn('status'),
        _ExportColumn('applied_balance_before_cents'),
        _ExportColumn('applied_balance_after_cents'),
        _ExportColumn('created_at'),
        _ExportColumn('updated_at'),
        _ExportColumn('deleted_at'),
      ],
      orderBy: 'scenario_id ASC, date ASC, created_at ASC, id ASC',
      filtersSoftDeleted: true,
    ),
    _ExportDescriptor(
      fileStem: 'plans',
      tableName: 'plans',
      resultSet: _TableRef.plans,
      columns: const [
        _ExportColumn('id'),
        _ExportColumn('scenario_id'),
        _ExportColumn('strategy'),
        _ExportColumn('extra_monthly_amount_cents'),
        _ExportColumn('extra_payment_cadence'),
        _ExportColumn('custom_order_json'),
        _ExportColumn('last_recast_at'),
        _ExportColumn('projected_debt_free_date'),
        _ExportColumn('total_interest_projected_cents'),
        _ExportColumn('total_interest_saved_cents'),
        _ExportColumn('created_at'),
        _ExportColumn('updated_at'),
        _ExportColumn('deleted_at'),
      ],
      orderBy: 'scenario_id ASC, updated_at ASC, created_at ASC, id ASC',
      filtersSoftDeleted: true,
    ),
    _ExportDescriptor(
      fileStem: 'user_settings',
      tableName: 'user_settings',
      resultSet: _TableRef.userSettings,
      columns: const [
        _ExportColumn('id'),
        _ExportColumn('trust_level'),
        _ExportColumn('firebase_uid'),
        _ExportColumn('currency_code'),
        _ExportColumn('locale_code'),
        _ExportColumn('day_count_convention'),
        _ExportColumn(
          'notif_payment_reminder',
          valueType: _ExportValueType.boolean,
        ),
        _ExportColumn('notif_payment_reminder_days_before'),
        _ExportColumn('notif_milestone', valueType: _ExportValueType.boolean),
        _ExportColumn('notif_monthly_log', valueType: _ExportValueType.boolean),
        _ExportColumn('onboarding_step'),
        _ExportColumn(
          'onboarding_completed',
          valueType: _ExportValueType.boolean,
        ),
        _ExportColumn('onboarding_completed_at'),
        _ExportColumn('is_premium', valueType: _ExportValueType.boolean),
        _ExportColumn('premium_expires_at'),
        _ExportColumn('created_at'),
        _ExportColumn('updated_at'),
      ],
      orderBy: 'id ASC',
      filtersSoftDeleted: false,
    ),
    _ExportDescriptor(
      fileStem: 'milestones',
      tableName: 'milestones',
      resultSet: _TableRef.milestones,
      columns: const [
        _ExportColumn('id'),
        _ExportColumn('scenario_id'),
        _ExportColumn('type'),
        _ExportColumn('debt_id'),
        _ExportColumn('achieved_at'),
        _ExportColumn('seen', valueType: _ExportValueType.boolean),
        _ExportColumn('metadata'),
        _ExportColumn('created_at'),
        _ExportColumn('deleted_at'),
      ],
      orderBy: 'scenario_id ASC, achieved_at ASC, created_at ASC, id ASC',
      filtersSoftDeleted: true,
    ),
    _ExportDescriptor(
      fileStem: 'interest_rate_history',
      tableName: 'interest_rate_history',
      resultSet: _TableRef.interestRateHistory,
      columns: const [
        _ExportColumn('id'),
        _ExportColumn('debt_id'),
        _ExportColumn('apr'),
        _ExportColumn('effective_from'),
        _ExportColumn('effective_to'),
        _ExportColumn('reason'),
        _ExportColumn('created_at'),
        _ExportColumn('updated_at'),
        _ExportColumn('deleted_at'),
      ],
      orderBy: 'debt_id ASC, effective_from ASC, created_at ASC, id ASC',
      filtersSoftDeleted: true,
    ),
  ];

  Future<DataExportArtifact> generateCsvExportBundle() async {
    return _generateBundle(
      kind: DataExportArtifactKind.csvBundle,
      bundlePrefix: 'debt_payoff_csv_export',
      bundleType: 'csv_export',
      extension: 'csv',
      serializer: _serializeCsv,
    );
  }

  Future<DataExportArtifact> generateLocalBackupBundle() async {
    return _generateBundle(
      kind: DataExportArtifactKind.localBackup,
      bundlePrefix: 'debt_payoff_backup',
      bundleType: 'local_backup',
      extension: 'json',
      serializer: _serializeJson,
    );
  }

  Future<BackupBundlePreview> inspectLocalBackupBundle({
    required String filePath,
    String? fileName,
  }) async {
    final parsed = await _parseLocalBackupBundle(
      filePath: filePath,
      fileName: fileName,
    );
    return parsed.preview;
  }

  Future<void> restoreFromLocalBackup({
    required String filePath,
    String? fileName,
  }) async {
    final settings = await (_db.select(
      _db.userSettingsTable,
    )..where((row) => row.id.equals('singleton'))).getSingleOrNull();

    if ((settings?.trustLevel ?? 0) > 0) {
      throw StateError(
        'Hãy tắt Sao lưu đám mây trước khi khôi phục bản sao lưu cục bộ.',
      );
    }

    final parsed = await _parseLocalBackupBundle(
      filePath: filePath,
      fileName: fileName,
    );

    await _db.transaction(() async {
      await _db.clearAllUserData();
      await _restoreUserSettings(parsed.rowsByFileStem['user_settings']!);
      await _restorePlans(parsed.rowsByFileStem['plans']!);
      await _restoreDebts(parsed.rowsByFileStem['debts']!);
      await _restorePayments(parsed.rowsByFileStem['payments']!);
      await _restoreMilestones(parsed.rowsByFileStem['milestones']!);
      await _restoreInterestRateHistory(
        parsed.rowsByFileStem['interest_rate_history']!,
      );
    });
  }

  Future<void> clearAllData() async {
    final settings = await (_db.select(
      _db.userSettingsTable,
    )..where((row) => row.id.equals('singleton'))).getSingleOrNull();

    if ((settings?.trustLevel ?? 0) > 0) {
      throw StateError(
        'Hãy tắt Sao lưu đám mây trước khi xóa toàn bộ dữ liệu.',
      );
    }

    await _db.resetToFactoryState();
  }

  Future<_ParsedLocalBackupBundle> _parseLocalBackupBundle({
    required String filePath,
    String? fileName,
  }) async {
    final resolvedFileName = _resolveBundleFileName(
      filePath: filePath,
      fileName: fileName,
    );
    final archive = await _readZipArchive(
      filePath: filePath,
      fileName: resolvedFileName,
    );
    final manifest = _readManifest(
      archive: archive,
      fileName: resolvedFileName,
    );
    final bundleType = _readManifestString(
      manifest,
      'bundle_type',
      fileName: resolvedFileName,
    );
    if (bundleType != 'local_backup') {
      throw StateError(
        'File $resolvedFileName không phải local backup bundle hợp lệ.',
      );
    }

    final bundleVersion = _readManifestInt(
      manifest,
      'bundle_version',
      fileName: resolvedFileName,
    );
    if (bundleVersion != _bundleVersion) {
      throw StateError(
        'Backup $resolvedFileName có bundle_version=$bundleVersion, '
        'nhưng app hiện chỉ hỗ trợ bundle_version=$_bundleVersion.',
      );
    }

    final schemaVersion = _readManifestInt(
      manifest,
      'schema_version',
      fileName: resolvedFileName,
    );
    if (schemaVersion != _db.schemaVersion) {
      throw StateError(
        'Backup $resolvedFileName có schema_version=$schemaVersion, '
        'không tương thích với app hiện tại (schema_version=${_db.schemaVersion}).',
      );
    }

    final exportedAtUtc = _readUtcDateTime(
      manifest,
      'exported_at_utc',
      tableName: 'manifest',
      fileName: resolvedFileName,
    );
    final rawCounts = _readManifestMap(
      manifest,
      'table_row_counts',
      fileName: resolvedFileName,
    );

    final rowsByFileStem = <String, List<Map<String, dynamic>>>{};
    final tableRowCounts = <String, int>{};

    for (final descriptor in _exportDescriptors) {
      final rows = _readArchiveJsonArray(
        archive,
        fileName: '${descriptor.fileStem}.json',
        bundleName: resolvedFileName,
      );
      _validateRowShape(
        descriptor: descriptor,
        rows: rows,
        bundleName: resolvedFileName,
      );

      final expectedCount = _readCountFromManifest(
        rawCounts,
        descriptor.fileStem,
        fileName: resolvedFileName,
      );
      if (rows.length != expectedCount) {
        throw StateError(
          'Backup $resolvedFileName bị lỗi: ${descriptor.fileStem}.json có '
          '${rows.length} dòng nhưng manifest khai báo $expectedCount.',
        );
      }

      rowsByFileStem[descriptor.fileStem] = rows;
      tableRowCounts[descriptor.fileStem] = rows.length;
    }

    _validateLocalBackupRows(
      rowsByFileStem: rowsByFileStem,
      fileName: resolvedFileName,
    );

    return _ParsedLocalBackupBundle(
      preview: BackupBundlePreview(
        path: filePath,
        fileName: resolvedFileName,
        bundleVersion: bundleVersion,
        schemaVersion: schemaVersion,
        exportedAtUtc: exportedAtUtc,
        tableRowCounts: tableRowCounts,
      ),
      rowsByFileStem: rowsByFileStem,
    );
  }

  Future<DataExportArtifact> _generateBundle({
    required DataExportArtifactKind kind,
    required String bundlePrefix,
    required String bundleType,
    required String extension,
    required String Function(
      _ExportDescriptor descriptor,
      List<Map<String, dynamic>> rows,
    )
    serializer,
  }) async {
    final exportedAt = _nowProvider().toUtc();
    final rowsByDescriptor = <_ExportDescriptor, List<Map<String, dynamic>>>{};

    for (final descriptor in _exportDescriptors) {
      rowsByDescriptor[descriptor] = await _fetchRows(descriptor);
    }

    final manifest = <String, dynamic>{
      'bundle_type': bundleType,
      'bundle_version': _bundleVersion,
      'schema_version': _db.schemaVersion,
      'exported_at_utc': exportedAt.toIso8601String(),
      'table_row_counts': <String, int>{
        for (final descriptor in _exportDescriptors)
          descriptor.fileStem: rowsByDescriptor[descriptor]!.length,
      },
    };

    final archive = Archive()
      ..addFile(ArchiveFile.string('manifest.json', jsonEncode(manifest)));

    for (final descriptor in _exportDescriptors) {
      final fileName = '${descriptor.fileStem}.$extension';
      final contents = serializer(descriptor, rowsByDescriptor[descriptor]!);
      archive.addFile(ArchiveFile.string(fileName, contents));
    }

    final bytes = ZipEncoder().encodeBytes(archive);
    final directory = await _temporaryDirectoryProvider();
    await directory.create(recursive: true);

    final fileName = '${bundlePrefix}_${_timestampForFileName(exportedAt)}.zip';
    final filePath = path.join(directory.path, fileName);
    await File(filePath).writeAsBytes(bytes, flush: true);

    return DataExportArtifact(
      path: filePath,
      fileName: fileName,
      mimeType: _zipMimeType,
      kind: kind,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRows(
    _ExportDescriptor descriptor,
  ) async {
    final sql = StringBuffer()
      ..write('SELECT ')
      ..write(descriptor.columns.map((column) => column.name).join(', '))
      ..write(' FROM ${descriptor.tableName}');

    if (descriptor.filtersSoftDeleted) {
      sql.write(' WHERE deleted_at IS NULL');
    }

    sql.write(' ORDER BY ${descriptor.orderBy}');

    final rows = await _db
        .customSelect(
          sql.toString(),
          readsFrom: {descriptor.resultSet.resolve(_db)},
        )
        .get();

    return rows
        .map(
          (row) => <String, dynamic>{
            for (final column in descriptor.columns)
              column.name: column.normalize(row.data[column.name]),
          },
        )
        .toList(growable: false);
  }

  String _serializeCsv(
    _ExportDescriptor descriptor,
    List<Map<String, dynamic>> rows,
  ) {
    final records = <List<dynamic>>[
      descriptor.columns.map((column) => column.name).toList(growable: false),
      ...rows.map(
        (row) => descriptor.columns
            .map((column) => row[column.name])
            .toList(growable: false),
      ),
    ];

    return const ListToCsvConverter(eol: '\n').convert(records);
  }

  String _serializeJson(
    _ExportDescriptor descriptor,
    List<Map<String, dynamic>> rows,
  ) {
    return jsonEncode(rows);
  }

  String _timestampForFileName(DateTime value) {
    final utc = value.toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    final second = utc.second.toString().padLeft(2, '0');
    final millis = utc.millisecond.toString().padLeft(3, '0');
    return '$year$month$day'
        'T$hour$minute$second$millis'
        'Z';
  }

  String _resolveBundleFileName({required String filePath, String? fileName}) {
    final trimmed = fileName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return path.basename(filePath);
  }

  Future<Archive> _readZipArchive({
    required String filePath,
    required String fileName,
  }) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      return ZipDecoder().decodeBytes(bytes);
    } on FileSystemException {
      throw StateError('Không thể đọc file backup $fileName.');
    } catch (_) {
      throw StateError('File $fileName không phải ZIP hợp lệ.');
    }
  }

  Map<String, dynamic> _readManifest({
    required Archive archive,
    required String fileName,
  }) {
    final decoded = _decodeArchiveEntryJson(
      archive,
      entryName: 'manifest.json',
      bundleName: fileName,
    );
    if (decoded is! Map) {
      throw StateError(
        'Backup $fileName không hợp lệ: manifest.json phải là object JSON.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  List<Map<String, dynamic>> _readArchiveJsonArray(
    Archive archive, {
    required String fileName,
    required String bundleName,
  }) {
    final decoded = _decodeArchiveEntryJson(
      archive,
      entryName: fileName,
      bundleName: bundleName,
    );
    if (decoded is! List) {
      throw StateError(
        'Backup $bundleName không hợp lệ: $fileName phải là JSON array.',
      );
    }

    return decoded
        .asMap()
        .entries
        .map((entry) {
          final row = entry.value;
          if (row is! Map) {
            throw StateError(
              'Backup $bundleName không hợp lệ: $fileName dòng ${entry.key + 1} '
              'phải là JSON object.',
            );
          }
          return Map<String, dynamic>.from(row);
        })
        .toList(growable: false);
  }

  dynamic _decodeArchiveEntryJson(
    Archive archive, {
    required String entryName,
    required String bundleName,
  }) {
    final text = _readArchiveText(
      archive,
      entryName: entryName,
      bundleName: bundleName,
    );
    try {
      return jsonDecode(text);
    } on FormatException {
      throw StateError(
        'Backup $bundleName không hợp lệ: $entryName không phải JSON hợp lệ.',
      );
    }
  }

  String _readArchiveText(
    Archive archive, {
    required String entryName,
    required String bundleName,
  }) {
    final entry = archive.findFile(entryName);
    if (entry == null) {
      throw StateError(
        'Backup $bundleName không hợp lệ: thiếu file $entryName.',
      );
    }

    return utf8.decode(entry.content);
  }

  void _validateRowShape({
    required _ExportDescriptor descriptor,
    required List<Map<String, dynamic>> rows,
    required String bundleName,
  }) {
    final expectedColumns = descriptor.columns
        .map((column) => column.name)
        .toSet();

    for (final entry in rows.asMap().entries) {
      final row = entry.value;
      final missingColumns = expectedColumns
          .where((column) => !row.containsKey(column))
          .toList(growable: false);
      if (missingColumns.isNotEmpty) {
        throw StateError(
          'Backup $bundleName không hợp lệ: ${descriptor.fileStem}.json '
          'dòng ${entry.key + 1} thiếu cột ${missingColumns.join(', ')}.',
        );
      }
    }
  }

  void _validateLocalBackupRows({
    required Map<String, List<Map<String, dynamic>>> rowsByFileStem,
    required String fileName,
  }) {
    final settingsRows = rowsByFileStem['user_settings'];
    if (settingsRows == null || settingsRows.length != 1) {
      throw StateError(
        'Backup $fileName không hợp lệ: user_settings phải chứa đúng 1 bản ghi.',
      );
    }

    final settingsRow = settingsRows.single;
    final settingsId = _readRequiredString(
      settingsRow,
      'id',
      tableName: 'user_settings',
      fileName: fileName,
    );
    if (settingsId != 'singleton') {
      throw StateError(
        'Backup $fileName không hợp lệ: user_settings.id phải là singleton.',
      );
    }

    final trustLevel = _readRequiredInt(
      settingsRow,
      'trust_level',
      tableName: 'user_settings',
      fileName: fileName,
    );
    final firebaseUid = _readOptionalString(
      settingsRow,
      'firebase_uid',
      tableName: 'user_settings',
      fileName: fileName,
    );
    if (trustLevel > 0 || (firebaseUid?.isNotEmpty ?? false)) {
      throw StateError(
        'Backup $fileName không thể khôi phục vì được tạo khi Sao lưu đám mây đang bật.',
      );
    }

    final planRows = rowsByFileStem['plans'] ?? const <Map<String, dynamic>>[];
    if (planRows.isEmpty) {
      throw StateError('Backup $fileName không hợp lệ: thiếu dữ liệu plans.');
    }

    final seenScenarioIds = <String>{};
    var hasMainPlan = false;
    for (final row in planRows) {
      final scenarioId = _readRequiredString(
        row,
        'scenario_id',
        tableName: 'plans',
        fileName: fileName,
      );
      if (!seenScenarioIds.add(scenarioId)) {
        throw StateError(
          'Backup $fileName không hợp lệ: plans chứa nhiều hơn 1 plan cho scenario_id=$scenarioId.',
        );
      }
      if (scenarioId == 'main') {
        hasMainPlan = true;
      }
    }

    if (!hasMainPlan) {
      throw StateError('Backup $fileName không hợp lệ: thiếu main plan.');
    }
  }

  String _readManifestString(
    Map<String, dynamic> manifest,
    String key, {
    required String fileName,
  }) {
    final rawValue = manifest[key];
    if (rawValue is String && rawValue.isNotEmpty) {
      return rawValue;
    }
    throw StateError(
      'Backup $fileName không hợp lệ: manifest.$key phải là chuỗi hợp lệ.',
    );
  }

  int _readManifestInt(
    Map<String, dynamic> manifest,
    String key, {
    required String fileName,
  }) {
    try {
      return _coerceInt(manifest[key]);
    } catch (_) {
      throw StateError(
        'Backup $fileName không hợp lệ: manifest.$key phải là số nguyên hợp lệ.',
      );
    }
  }

  Map<String, dynamic> _readManifestMap(
    Map<String, dynamic> manifest,
    String key, {
    required String fileName,
  }) {
    final rawValue = manifest[key];
    if (rawValue is! Map) {
      throw StateError(
        'Backup $fileName không hợp lệ: manifest.$key phải là object JSON.',
      );
    }
    return Map<String, dynamic>.from(rawValue);
  }

  int _readCountFromManifest(
    Map<String, dynamic> counts,
    String fileStem, {
    required String fileName,
  }) {
    final rawValue = counts[fileStem];
    try {
      return _coerceInt(rawValue);
    } catch (_) {
      throw StateError(
        'Backup $fileName không hợp lệ: table_row_counts.$fileStem phải là số nguyên.',
      );
    }
  }

  Future<void> _restoreUserSettings(List<Map<String, dynamic>> rows) async {
    final row = rows.single;

    await _db
        .into(_db.userSettingsTable)
        .insert(
          UserSettingsTableCompanion(
            id: Value(
              _readRequiredString(
                row,
                'id',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            trustLevel: Value(
              _readRequiredInt(
                row,
                'trust_level',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            firebaseUid: Value(
              _readOptionalString(
                row,
                'firebase_uid',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            currencyCode: Value(
              _readRequiredString(
                row,
                'currency_code',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            localeCode: Value(
              _readRequiredString(
                row,
                'locale_code',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            dayCountConvention: Value(
              _readRequiredString(
                row,
                'day_count_convention',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            notifPaymentReminder: Value(
              _readRequiredBool(
                row,
                'notif_payment_reminder',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            notifPaymentReminderDaysBefore: Value(
              _readRequiredInt(
                row,
                'notif_payment_reminder_days_before',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            notifMilestone: Value(
              _readRequiredBool(
                row,
                'notif_milestone',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            notifMonthlyLog: Value(
              _readRequiredBool(
                row,
                'notif_monthly_log',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            onboardingStep: Value(
              _readRequiredInt(
                row,
                'onboarding_step',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            onboardingCompleted: Value(
              _readRequiredBool(
                row,
                'onboarding_completed',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            onboardingCompletedAt: Value(
              _readOptionalUtcDateTime(
                row,
                'onboarding_completed_at',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            isPremium: Value(
              _readRequiredBool(
                row,
                'is_premium',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            premiumExpiresAt: Value(
              _readOptionalUtcDateTime(
                row,
                'premium_expires_at',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            createdAt: Value(
              _readUtcDateTime(
                row,
                'created_at',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
            updatedAt: Value(
              _readUtcDateTime(
                row,
                'updated_at',
                tableName: 'user_settings',
                fileName: 'user_settings.json',
              ),
            ),
          ),
        );
  }

  Future<void> _restorePlans(List<Map<String, dynamic>> rows) async {
    for (final row in rows) {
      await _db
          .into(_db.plansTable)
          .insert(
            PlansTableCompanion(
              id: Value(
                _readRequiredString(
                  row,
                  'id',
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              scenarioId: Value(
                _readRequiredString(
                  row,
                  'scenario_id',
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              strategy: Value(
                _readEnum(
                  row,
                  'strategy',
                  Strategy.values,
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              extraMonthlyAmountCents: Value(
                _readRequiredInt(
                  row,
                  'extra_monthly_amount_cents',
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              extraPaymentCadence: Value(
                _readEnum(
                  row,
                  'extra_payment_cadence',
                  PaymentCadence.values,
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              customOrderJson: Value(
                _readOptionalString(
                  row,
                  'custom_order_json',
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              lastRecastAt: Value(
                _readUtcDateTime(
                  row,
                  'last_recast_at',
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              projectedDebtFreeDate: Value(
                _readOptionalLocalDate(
                  row,
                  'projected_debt_free_date',
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              totalInterestProjectedCents: Value(
                _readOptionalInt(
                  row,
                  'total_interest_projected_cents',
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              totalInterestSavedCents: Value(
                _readOptionalInt(
                  row,
                  'total_interest_saved_cents',
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              createdAt: Value(
                _readUtcDateTime(
                  row,
                  'created_at',
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              updatedAt: Value(
                _readUtcDateTime(
                  row,
                  'updated_at',
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
              deletedAt: Value(
                _readOptionalUtcDateTime(
                  row,
                  'deleted_at',
                  tableName: 'plans',
                  fileName: 'plans.json',
                ),
              ),
            ),
          );
    }
  }

  Future<void> _restoreDebts(List<Map<String, dynamic>> rows) async {
    for (final row in rows) {
      await _db
          .into(_db.debtsTable)
          .insert(
            DebtsTableCompanion(
              id: Value(
                _readRequiredString(
                  row,
                  'id',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              scenarioId: Value(
                _readRequiredString(
                  row,
                  'scenario_id',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              name: Value(
                _readRequiredString(
                  row,
                  'name',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              type: Value(
                _readEnum(
                  row,
                  'type',
                  DebtType.values,
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              originalPrincipalCents: Value(
                _readRequiredInt(
                  row,
                  'original_principal_cents',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              currentBalanceCents: Value(
                _readRequiredInt(
                  row,
                  'current_balance_cents',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              apr: Value(
                _readDecimal(
                  row,
                  'apr',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              interestMethod: Value(
                _readEnum(
                  row,
                  'interest_method',
                  InterestMethod.values,
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              minimumPaymentCents: Value(
                _readRequiredInt(
                  row,
                  'minimum_payment_cents',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              minimumPaymentType: Value(
                _readEnum(
                  row,
                  'minimum_payment_type',
                  MinPaymentType.values,
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              minimumPaymentPercent: Value(
                _readOptionalDecimal(
                  row,
                  'minimum_payment_percent',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              minimumPaymentFloorCents: Value(
                _readOptionalInt(
                  row,
                  'minimum_payment_floor_cents',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              paymentCadence: Value(
                _readEnum(
                  row,
                  'payment_cadence',
                  PaymentCadence.values,
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              dueDayOfMonth: Value(
                _readRequiredInt(
                  row,
                  'due_day_of_month',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              firstDueDate: Value(
                _readLocalDate(
                  row,
                  'first_due_date',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              status: Value(
                _readEnum(
                  row,
                  'status',
                  DebtStatus.values,
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              pausedUntil: Value(
                _readOptionalLocalDate(
                  row,
                  'paused_until',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              priority: Value(
                _readOptionalInt(
                  row,
                  'priority',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              excludeFromStrategy: Value(
                _readRequiredBool(
                  row,
                  'exclude_from_strategy',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              createdAt: Value(
                _readUtcDateTime(
                  row,
                  'created_at',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              updatedAt: Value(
                _readUtcDateTime(
                  row,
                  'updated_at',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              paidOffAt: Value(
                _readOptionalUtcDateTime(
                  row,
                  'paid_off_at',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
              deletedAt: Value(
                _readOptionalUtcDateTime(
                  row,
                  'deleted_at',
                  tableName: 'debts',
                  fileName: 'debts.json',
                ),
              ),
            ),
          );
    }
  }

  Future<void> _restorePayments(List<Map<String, dynamic>> rows) async {
    for (final row in rows) {
      await _db
          .into(_db.paymentsTable)
          .insert(
            PaymentsTableCompanion(
              id: Value(
                _readRequiredString(
                  row,
                  'id',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              scenarioId: Value(
                _readRequiredString(
                  row,
                  'scenario_id',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              debtId: Value(
                _readRequiredString(
                  row,
                  'debt_id',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              amountCents: Value(
                _readRequiredInt(
                  row,
                  'amount_cents',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              principalPortionCents: Value(
                _readRequiredInt(
                  row,
                  'principal_portion_cents',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              interestPortionCents: Value(
                _readRequiredInt(
                  row,
                  'interest_portion_cents',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              feePortionCents: Value(
                _readRequiredInt(
                  row,
                  'fee_portion_cents',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              date: Value(
                _readLocalDate(
                  row,
                  'date',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              type: Value(
                _readEnum(
                  row,
                  'type',
                  PaymentType.values,
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              source: Value(
                _readEnum(
                  row,
                  'source',
                  PaymentSource.values,
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              note: Value(
                _readOptionalString(
                  row,
                  'note',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              status: Value(
                _readEnum(
                  row,
                  'status',
                  PaymentStatus.values,
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              appliedBalanceBeforeCents: Value(
                _readRequiredInt(
                  row,
                  'applied_balance_before_cents',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              appliedBalanceAfterCents: Value(
                _readRequiredInt(
                  row,
                  'applied_balance_after_cents',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              createdAt: Value(
                _readUtcDateTime(
                  row,
                  'created_at',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              updatedAt: Value(
                _readUtcDateTime(
                  row,
                  'updated_at',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
              deletedAt: Value(
                _readOptionalUtcDateTime(
                  row,
                  'deleted_at',
                  tableName: 'payments',
                  fileName: 'payments.json',
                ),
              ),
            ),
          );
    }
  }

  Future<void> _restoreMilestones(List<Map<String, dynamic>> rows) async {
    for (final row in rows) {
      await _db
          .into(_db.milestonesTable)
          .insert(
            MilestonesTableCompanion(
              id: Value(
                _readRequiredString(
                  row,
                  'id',
                  tableName: 'milestones',
                  fileName: 'milestones.json',
                ),
              ),
              scenarioId: Value(
                _readRequiredString(
                  row,
                  'scenario_id',
                  tableName: 'milestones',
                  fileName: 'milestones.json',
                ),
              ),
              type: Value(
                _readEnum(
                  row,
                  'type',
                  MilestoneType.values,
                  tableName: 'milestones',
                  fileName: 'milestones.json',
                ),
              ),
              debtId: Value(
                _readOptionalString(
                  row,
                  'debt_id',
                  tableName: 'milestones',
                  fileName: 'milestones.json',
                ),
              ),
              achievedAt: Value(
                _readUtcDateTime(
                  row,
                  'achieved_at',
                  tableName: 'milestones',
                  fileName: 'milestones.json',
                ),
              ),
              seen: Value(
                _readRequiredBool(
                  row,
                  'seen',
                  tableName: 'milestones',
                  fileName: 'milestones.json',
                ),
              ),
              metadata: Value(
                _readOptionalString(
                  row,
                  'metadata',
                  tableName: 'milestones',
                  fileName: 'milestones.json',
                ),
              ),
              createdAt: Value(
                _readUtcDateTime(
                  row,
                  'created_at',
                  tableName: 'milestones',
                  fileName: 'milestones.json',
                ),
              ),
              deletedAt: Value(
                _readOptionalUtcDateTime(
                  row,
                  'deleted_at',
                  tableName: 'milestones',
                  fileName: 'milestones.json',
                ),
              ),
            ),
          );
    }
  }

  Future<void> _restoreInterestRateHistory(
    List<Map<String, dynamic>> rows,
  ) async {
    for (final row in rows) {
      await _db
          .into(_db.interestRateHistoryTable)
          .insert(
            InterestRateHistoryTableCompanion(
              id: Value(
                _readRequiredString(
                  row,
                  'id',
                  tableName: 'interest_rate_history',
                  fileName: 'interest_rate_history.json',
                ),
              ),
              debtId: Value(
                _readRequiredString(
                  row,
                  'debt_id',
                  tableName: 'interest_rate_history',
                  fileName: 'interest_rate_history.json',
                ),
              ),
              apr: Value(
                _readDecimal(
                  row,
                  'apr',
                  tableName: 'interest_rate_history',
                  fileName: 'interest_rate_history.json',
                ),
              ),
              effectiveFrom: Value(
                _readLocalDate(
                  row,
                  'effective_from',
                  tableName: 'interest_rate_history',
                  fileName: 'interest_rate_history.json',
                ),
              ),
              effectiveTo: Value(
                _readOptionalLocalDate(
                  row,
                  'effective_to',
                  tableName: 'interest_rate_history',
                  fileName: 'interest_rate_history.json',
                ),
              ),
              reason: Value(
                _readOptionalString(
                  row,
                  'reason',
                  tableName: 'interest_rate_history',
                  fileName: 'interest_rate_history.json',
                ),
              ),
              createdAt: Value(
                _readUtcDateTime(
                  row,
                  'created_at',
                  tableName: 'interest_rate_history',
                  fileName: 'interest_rate_history.json',
                ),
              ),
              updatedAt: Value(
                _readUtcDateTime(
                  row,
                  'updated_at',
                  tableName: 'interest_rate_history',
                  fileName: 'interest_rate_history.json',
                ),
              ),
              deletedAt: Value(
                _readOptionalUtcDateTime(
                  row,
                  'deleted_at',
                  tableName: 'interest_rate_history',
                  fileName: 'interest_rate_history.json',
                ),
              ),
            ),
          );
    }
  }

  String _readRequiredString(
    Map<String, dynamic> row,
    String key, {
    required String tableName,
    required String fileName,
  }) {
    final value = row[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw StateError(
      'Backup $fileName không hợp lệ: $tableName.$key phải là chuỗi hợp lệ.',
    );
  }

  String? _readOptionalString(
    Map<String, dynamic> row,
    String key, {
    required String tableName,
    required String fileName,
  }) {
    final value = row[key];
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    throw StateError(
      'Backup $fileName không hợp lệ: $tableName.$key phải là chuỗi hoặc null.',
    );
  }

  int _readRequiredInt(
    Map<String, dynamic> row,
    String key, {
    required String tableName,
    required String fileName,
  }) {
    try {
      return _coerceInt(row[key]);
    } catch (_) {
      throw StateError(
        'Backup $fileName không hợp lệ: $tableName.$key phải là số nguyên.',
      );
    }
  }

  int? _readOptionalInt(
    Map<String, dynamic> row,
    String key, {
    required String tableName,
    required String fileName,
  }) {
    final value = row[key];
    if (value == null) {
      return null;
    }
    try {
      return _coerceInt(value);
    } catch (_) {
      throw StateError(
        'Backup $fileName không hợp lệ: $tableName.$key phải là số nguyên hoặc null.',
      );
    }
  }

  bool _readRequiredBool(
    Map<String, dynamic> row,
    String key, {
    required String tableName,
    required String fileName,
  }) {
    final value = row[key];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      if (value == 'true' || value == '1') {
        return true;
      }
      if (value == 'false' || value == '0') {
        return false;
      }
    }
    throw StateError(
      'Backup $fileName không hợp lệ: $tableName.$key phải là boolean.',
    );
  }

  Decimal _readDecimal(
    Map<String, dynamic> row,
    String key, {
    required String tableName,
    required String fileName,
  }) {
    final value = row[key];
    if (value is! String || value.isEmpty) {
      throw StateError(
        'Backup $fileName không hợp lệ: $tableName.$key phải là chuỗi decimal.',
      );
    }
    try {
      return Decimal.parse(value);
    } on FormatException {
      throw StateError(
        'Backup $fileName không hợp lệ: $tableName.$key không phải decimal hợp lệ.',
      );
    }
  }

  Decimal? _readOptionalDecimal(
    Map<String, dynamic> row,
    String key, {
    required String tableName,
    required String fileName,
  }) {
    final value = row[key];
    if (value == null) {
      return null;
    }
    if (value is! String || value.isEmpty) {
      throw StateError(
        'Backup $fileName không hợp lệ: $tableName.$key phải là chuỗi decimal hoặc null.',
      );
    }
    try {
      return Decimal.parse(value);
    } on FormatException {
      throw StateError(
        'Backup $fileName không hợp lệ: $tableName.$key không phải decimal hợp lệ.',
      );
    }
  }

  DateTime _readUtcDateTime(
    Map<String, dynamic> row,
    String key, {
    required String tableName,
    required String fileName,
  }) {
    final value = _readRequiredString(
      row,
      key,
      tableName: tableName,
      fileName: fileName,
    );
    try {
      return DateTime.parse(value).toUtc();
    } on FormatException {
      throw StateError(
        'Backup $fileName không hợp lệ: $tableName.$key không phải UTC datetime hợp lệ.',
      );
    }
  }

  DateTime? _readOptionalUtcDateTime(
    Map<String, dynamic> row,
    String key, {
    required String tableName,
    required String fileName,
  }) {
    final value = _readOptionalString(
      row,
      key,
      tableName: tableName,
      fileName: fileName,
    );
    if (value == null) {
      return null;
    }
    try {
      return DateTime.parse(value).toUtc();
    } on FormatException {
      throw StateError(
        'Backup $fileName không hợp lệ: $tableName.$key không phải UTC datetime hợp lệ.',
      );
    }
  }

  DateTime _readLocalDate(
    Map<String, dynamic> row,
    String key, {
    required String tableName,
    required String fileName,
  }) {
    final value = _readRequiredString(
      row,
      key,
      tableName: tableName,
      fileName: fileName,
    );
    try {
      return DateTime.parse(value);
    } on FormatException {
      throw StateError(
        'Backup $fileName không hợp lệ: $tableName.$key không phải local date hợp lệ.',
      );
    }
  }

  DateTime? _readOptionalLocalDate(
    Map<String, dynamic> row,
    String key, {
    required String tableName,
    required String fileName,
  }) {
    final value = _readOptionalString(
      row,
      key,
      tableName: tableName,
      fileName: fileName,
    );
    if (value == null) {
      return null;
    }
    try {
      return DateTime.parse(value);
    } on FormatException {
      throw StateError(
        'Backup $fileName không hợp lệ: $tableName.$key không phải local date hợp lệ.',
      );
    }
  }

  T _readEnum<T extends Enum>(
    Map<String, dynamic> row,
    String key,
    List<T> values, {
    required String tableName,
    required String fileName,
  }) {
    final rawValue = _readRequiredString(
      row,
      key,
      tableName: tableName,
      fileName: fileName,
    );
    try {
      return values.byName(rawValue);
    } catch (_) {
      throw StateError(
        'Backup $fileName không hợp lệ: $tableName.$key có giá trị không hỗ trợ: $rawValue.',
      );
    }
  }

  int _coerceInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      final coerced = value.toInt();
      if (value == coerced) {
        return coerced;
      }
      throw StateError('Expected whole number value.');
    }
    if (value is String) {
      return int.parse(value);
    }
    throw StateError('Expected int-compatible value.');
  }
}

class _ParsedLocalBackupBundle {
  const _ParsedLocalBackupBundle({
    required this.preview,
    required this.rowsByFileStem,
  });

  final BackupBundlePreview preview;
  final Map<String, List<Map<String, dynamic>>> rowsByFileStem;
}

class _ExportDescriptor {
  const _ExportDescriptor({
    required this.fileStem,
    required this.tableName,
    required this.resultSet,
    required this.columns,
    required this.orderBy,
    required this.filtersSoftDeleted,
  });

  final String fileStem;
  final String tableName;
  final _TableRef resultSet;
  final List<_ExportColumn> columns;
  final String orderBy;
  final bool filtersSoftDeleted;
}

enum _ExportValueType { defaultValue, boolean }

class _ExportColumn {
  const _ExportColumn(
    this.name, {
    this.valueType = _ExportValueType.defaultValue,
  });

  final String name;
  final _ExportValueType valueType;

  dynamic normalize(dynamic rawValue) {
    switch (valueType) {
      case _ExportValueType.boolean:
        if (rawValue == null) {
          return null;
        }
        if (rawValue is bool) {
          return rawValue;
        }
        if (rawValue is num) {
          return rawValue != 0;
        }
        return rawValue.toString() == '1';
      case _ExportValueType.defaultValue:
        return rawValue;
    }
  }
}

enum _TableRef {
  debts,
  payments,
  plans,
  userSettings,
  milestones,
  interestRateHistory,
}

extension on _TableRef {
  ResultSetImplementation resolve(AppDatabase db) {
    switch (this) {
      case _TableRef.debts:
        return db.debtsTable;
      case _TableRef.payments:
        return db.paymentsTable;
      case _TableRef.plans:
        return db.plansTable;
      case _TableRef.userSettings:
        return db.userSettingsTable;
      case _TableRef.milestones:
        return db.milestonesTable;
      case _TableRef.interestRateHistory:
        return db.interestRateHistoryTable;
    }
  }
}
