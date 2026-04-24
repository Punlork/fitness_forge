import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';
import 'package:forge/core/error/app_error.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;
  final Logger _logger = Logger();

  // Database version and name
  static const _databaseName = "app_database.db";
  static const _databaseVersion = 5;

  // Private constructor
  DatabaseService._();

  // Singleton instance
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  // Database instance getter
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    try {
      final String path = join(await getDatabasesPath(), _databaseName);
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: onDatabaseDowngradeDelete,
      );
    } catch (e, stackTrace) {
      throw AppError.create(
        message: 'Failed to initialize database',
        type: ErrorType.database,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.transaction((txn) async {
        // Users table
        await txn.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            avatar TEXT,
            last_sync TEXT
          )
        ''');

        // Create indexes
        await txn.execute('CREATE INDEX idx_users_email ON users(email)');

        await _createWorkoutTables(txn);

        _logger.i('Database tables created successfully');
      });
    } catch (e, stackTrace) {
      throw AppError.create(
        message: 'Failed to create database tables',
        type: ErrorType.database,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Upgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      await db.transaction((txn) async {
        if (oldVersion < 2) {
          await _createWorkoutTables(txn);
        }
        if (oldVersion < 3) {
          await _upgradeToV3(txn);
        }
        if (oldVersion < 4) {
          await _upgradeToV4(txn);
        }
        if (oldVersion < 5) {
          await _upgradeToV5(txn);
        }
      });
      _logger.i('Database upgraded from $oldVersion to $newVersion');
    } catch (e, stackTrace) {
      throw AppError.create(
        message: 'Failed to upgrade database from $oldVersion to $newVersion',
        type: ErrorType.database,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _createWorkoutTables(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS session_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_date TEXT NOT NULL,
        started_at TEXT NOT NULL,
        workout_completed INTEGER NOT NULL DEFAULT 0,
        protein_completed INTEGER NOT NULL DEFAULT 0,
        session_note TEXT NOT NULL DEFAULT ''
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS jump_rope_intervals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        interval_type TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        interval_order INTEGER NOT NULL,
        round_number INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES session_logs(id) ON DELETE CASCADE
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS strength_sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        exercise_name TEXT NOT NULL,
        weight REAL NOT NULL DEFAULT 0,
        load_type TEXT NOT NULL DEFAULT 'bodyweight',
        reps INTEGER NOT NULL DEFAULT 0,
        round_number INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES session_logs(id) ON DELETE CASCADE
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS body_weight_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_date TEXT NOT NULL UNIQUE,
        body_weight REAL NOT NULL
      )
    ''');

    await txn.execute('''
      CREATE TABLE IF NOT EXISTS body_metrics(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_date TEXT NOT NULL UNIQUE,
        weight_kg REAL NOT NULL,
        height_cm REAL NOT NULL,
        body_fat_percent REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_sessions_date ON session_logs(session_date)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_intervals_session ON jump_rope_intervals(session_id)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_sets_session ON strength_sets(session_id)');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_body_metrics_date ON body_metrics(log_date)');
  }

  Future<void> _upgradeToV3(Transaction txn) async {
    final columns = await txn.rawQuery('PRAGMA table_info(strength_sets)');
    final hasLoadType = columns.any((c) => c['name'] == 'load_type');
    if (!hasLoadType) {
      await txn.execute(
        "ALTER TABLE strength_sets ADD COLUMN load_type TEXT NOT NULL DEFAULT 'external'",
      );
    }
    await txn.execute('''
      CREATE TABLE IF NOT EXISTS body_metrics(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_date TEXT NOT NULL UNIQUE,
        weight_kg REAL NOT NULL,
        height_cm REAL NOT NULL,
        body_fat_percent REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_body_metrics_date ON body_metrics(log_date)');
  }

  Future<void> _upgradeToV4(Transaction txn) async {
    final columns = await txn.rawQuery('PRAGMA table_info(session_logs)');
    final hasSessionNote = columns.any((c) => c['name'] == 'session_note');
    if (!hasSessionNote) {
      await txn.execute(
        "ALTER TABLE session_logs ADD COLUMN session_note TEXT NOT NULL DEFAULT ''",
      );
    }
  }

  Future<void> _upgradeToV5(Transaction txn) async {
    final setColumns = await txn.rawQuery('PRAGMA table_info(strength_sets)');
    if (!setColumns.any((c) => c['name'] == 'round_number')) {
      await txn.execute(
        'ALTER TABLE strength_sets ADD COLUMN round_number INTEGER NOT NULL DEFAULT 0',
      );
    }
    final intervalColumns =
        await txn.rawQuery('PRAGMA table_info(jump_rope_intervals)');
    if (!intervalColumns.any((c) => c['name'] == 'round_number')) {
      await txn.execute(
        'ALTER TABLE jump_rope_intervals ADD COLUMN round_number INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  // Generic query methods with automatic retry
  Future<T> _withRetry<T>(Future<T> Function() operation,
      {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        attempts++;
        if (attempts == maxRetries) {
          throw AppError.create(
            message: 'Database operation failed after $maxRetries attempts',
            type: ErrorType.database,
            originalError: e,
            stackTrace: stackTrace,
          );
        }
        await Future.delayed(Duration(milliseconds: 200 * attempts));
        AppError.create(
          message: 'Retrying database operation, attempt $attempts',
          type: ErrorType.database,
          originalError: e,
          stackTrace: stackTrace,
          shouldLog: false, // Suppress logging for retry attempts
        );
      }
    }
    throw AppError.create(
      message: 'Unexpected error in database retry mechanism',
      type: ErrorType.database,
    );
  }

  // Batch operations
  Future<void> runBatch(void Function(Batch batch) operations) async {
    final db = await database;
    await _withRetry(() async {
      final batch = db.batch();
      operations(batch);
      await batch.commit(noResult: true);
    });
  }

  // Transaction wrapper
  Future<T> runTransaction<T>(
      Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await _withRetry(() => db.transaction(action));
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
