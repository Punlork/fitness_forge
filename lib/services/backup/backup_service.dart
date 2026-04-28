import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:forge/services/db/database_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BackupService {
  BackupService._();

  static final instance = BackupService._();

  static const _backupVersion = 1;
  static const _supportedBackupVersion = 1;

  static const _requiredTables = [
    'users',
    'session_logs',
    'jump_rope_intervals',
    'strength_sets',
    'body_metrics',
  ];

  static const _deleteOrder = [
    'jump_rope_intervals',
    'strength_sets',
    'body_metrics',
    'session_logs',
    'users',
  ];

  static const _insertOrder = [
    'users',
    'session_logs',
    'body_metrics',
    'strength_sets',
    'jump_rope_intervals',
  ];

  Future<String> getDefaultBackupDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  String buildBackupFileName() {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return 'forge_backup_$timestamp.json';
  }

  Future<String> exportBackupToAppStorage() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, buildBackupFileName());
    return exportBackupToPath(path);
  }

  Future<String> exportBackupToPath(String targetPath) async {
    final content = await buildBackupJsonContent();
    final file = File(targetPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
    return file.path;
  }

  Future<String> buildBackupJsonContent() async {
    final db = await DatabaseService.instance.database;
    final payload = await _buildBackupPayload(db);
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<Uint8List> buildBackupBytes() async {
    final jsonContent = await buildBackupJsonContent();
    return Uint8List.fromList(utf8.encode(jsonContent));
  }

  Future<void> importBackupFromPath(String backupFilePath) async {
    final file = File(backupFilePath);
    if (!await file.exists()) {
      throw const BackupException('Backup file does not exist.');
    }
    final rawContent = await file.readAsString();
    final payload = _parseAndValidatePayload(rawContent);
    await _replaceAllData(payload.tables);
  }

  Future<Map<String, dynamic>> _buildBackupPayload(Database db) async {
    final tables = <String, List<Map<String, dynamic>>>{};
    for (final table in _requiredTables) {
      final rows = await db.query(table);
      tables[table] = rows
          .map(
            (row) => row.map(
              (key, value) => MapEntry(key, _normalizeForJson(value)),
            ),
          )
          .toList();
    }
    return {
      'backupVersion': _backupVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'appDbVersion': 7,
      'tables': tables,
    };
  }

  BackupPayload _parseAndValidatePayload(String rawContent) {
    final dynamic decoded = jsonDecode(rawContent);
    if (decoded is! Map<String, dynamic>) {
      throw const BackupException('Invalid backup format.');
    }

    final backupVersion = decoded['backupVersion'];
    if (backupVersion is! int || backupVersion > _supportedBackupVersion) {
      throw const BackupException('Unsupported backup version.');
    }

    final tablesRaw = decoded['tables'];
    if (tablesRaw is! Map<String, dynamic>) {
      throw const BackupException('Missing backup tables.');
    }

    final parsedTables = <String, List<Map<String, dynamic>>>{};
    for (final table in _requiredTables) {
      final tableData = tablesRaw[table];
      if (tableData is! List) {
        throw BackupException('Missing required table: $table');
      }
      parsedTables[table] = tableData.map<Map<String, dynamic>>((row) {
        if (row is! Map) {
          throw BackupException('Invalid row in table: $table');
        }
        return row.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }).toList();
    }

    return BackupPayload(
      backupVersion: backupVersion,
      tables: parsedTables,
    );
  }

  Future<void> _replaceAllData(
      Map<String, List<Map<String, dynamic>>> tables) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      for (final table in _deleteOrder) {
        await txn.delete(table);
      }

      for (final table in _insertOrder) {
        final rows = tables[table] ?? const [];
        for (final row in rows) {
          await txn.insert(
            table,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  dynamic _normalizeForJson(dynamic value) {
    if (value is Uint8List) {
      return base64Encode(value);
    }
    return value;
  }
}

class BackupPayload {
  final int backupVersion;
  final Map<String, List<Map<String, dynamic>>> tables;

  const BackupPayload({
    required this.backupVersion,
    required this.tables,
  });
}

class BackupException implements Exception {
  final String message;

  const BackupException(this.message);

  @override
  String toString() => message;
}
