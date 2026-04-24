import 'package:forge/core/base_repository.dart';
import 'package:forge/models/body_metric_model.dart';
import 'package:forge/models/jump_rope_interval_model.dart';
import 'package:forge/models/progress_point_model.dart';
import 'package:forge/models/strength_set_model.dart';
import 'package:forge/models/workout_history_entry_model.dart';
import 'package:forge/models/workout_session_model.dart';

class LocalWorkoutRepository extends BaseRepository {
  Future<int> startSession({DateTime? now}) async {
    return handleDatabaseOperation(() async {
      final db = await databaseService.database;
      final DateTime timestamp = now ?? DateTime.now();
      return db.insert('session_logs', {
        'session_date': _asDateString(timestamp),
        'started_at': timestamp.toIso8601String(),
        'workout_completed': 0,
        'protein_completed': 0,
        'session_note': '',
      });
    });
  }

  Future<WorkoutSessionModel?> getLatestSessionForToday() async {
    return handleDatabaseOperation(() async {
      final db = await databaseService.database;
      final rows = await db.query(
        'session_logs',
        where: 'session_date = ?',
        whereArgs: [_asDateString(DateTime.now())],
        orderBy: 'started_at DESC',
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }
      return WorkoutSessionModel.fromDb(rows.first);
    });
  }

  Future<void> addJumpRopeInterval({
    required int sessionId,
    required String intervalType,
    required int durationSeconds,
    int roundNumber = 0,
  }) async {
    await handleDatabaseOperation(() async {
      final db = await databaseService.database;
      final maxOrderResult = await db.rawQuery(
        'SELECT MAX(interval_order) as max_order FROM jump_rope_intervals WHERE session_id = ?',
        [sessionId],
      );
      final int nextOrder =
          ((maxOrderResult.first['max_order'] as int?) ?? 0) + 1;
      await db.insert('jump_rope_intervals', {
        'session_id': sessionId,
        'interval_type': intervalType,
        'duration_seconds': durationSeconds,
        'interval_order': nextOrder,
        'round_number': roundNumber,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> addStrengthSet({
    required int sessionId,
    required String exerciseName,
    double weight = 0,
    StrengthLoadType loadType = StrengthLoadType.bodyweight,
    required int reps,
    int roundNumber = 0,
  }) async {
    await handleDatabaseOperation(() async {
      final db = await databaseService.database;
      await db.insert('strength_sets', {
        'session_id': sessionId,
        'exercise_name': exerciseName,
        'weight': weight,
        'load_type': loadType.name,
        'reps': reps,
        'round_number': roundNumber,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<List<JumpRopeIntervalModel>> getJumpRopeIntervals(
      int sessionId) async {
    return handleDatabaseOperation(() async {
      final db = await databaseService.database;
      final rows = await db.query(
        'jump_rope_intervals',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'interval_order ASC',
      );
      return rows.map(JumpRopeIntervalModel.fromDb).toList();
    });
  }

  Future<List<StrengthSetModel>> getStrengthSets(int sessionId) async {
    return handleDatabaseOperation(() async {
      final db = await databaseService.database;
      final rows = await db.query(
        'strength_sets',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'created_at DESC',
      );
      return rows.map(StrengthSetModel.fromDb).toList();
    });
  }

  Future<List<ProgressPointModel>> getRecentProgress({int days = 14}) async {
    return handleDatabaseOperation(() async {
      final db = await databaseService.database;
      final rows = await db.rawQuery(
        '''
        SELECT
          session_totals.date AS date,
          COALESCE(SUM(session_totals.strength_volume), 0) AS strength_volume,
          COALESCE(SUM(session_totals.cardio_seconds), 0) AS cardio_seconds
        FROM session_logs s
        JOIN (
          SELECT
            s.id,
            s.session_date AS date,
            COALESCE((
              SELECT SUM(ss.weight * ss.reps)
              FROM strength_sets ss
              WHERE ss.session_id = s.id
            ), 0) AS strength_volume,
            COALESCE((
              SELECT SUM(j.duration_seconds)
              FROM jump_rope_intervals j
              WHERE j.session_id = s.id
            ), 0) AS cardio_seconds
          FROM session_logs s
          WHERE s.session_date >= date('now', ?)
        ) AS session_totals ON session_totals.id = s.id
        GROUP BY session_totals.date
        ORDER BY session_totals.date ASC
        ''',
        ['-${days - 1} day'],
      );
      return rows.map(ProgressPointModel.fromDb).toList();
    });
  }

  Future<void> completeSession(int sessionId) async {
    await handleDatabaseOperation(() async {
      final db = await databaseService.database;
      await db.update(
        'session_logs',
        {'workout_completed': 1},
        where: 'id = ?',
        whereArgs: [sessionId],
      );
    });
  }

  Future<void> saveSessionNote({
    required int sessionId,
    required String note,
  }) async {
    await handleDatabaseOperation(() async {
      final db = await databaseService.database;
      await db.update(
        'session_logs',
        {'session_note': note.trim()},
        where: 'id = ?',
        whereArgs: [sessionId],
      );
    });
  }

  Future<WorkoutSessionModel?> getSessionById(int sessionId) async {
    return handleDatabaseOperation(() async {
      final db = await databaseService.database;
      final rows = await db.query(
        'session_logs',
        where: 'id = ?',
        whereArgs: [sessionId],
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }
      return WorkoutSessionModel.fromDb(rows.first);
    });
  }

  Future<void> upsertBodyMetrics({
    required DateTime date,
    required double weightKg,
    required double heightCm,
    required double bodyFatPercent,
  }) async {
    await handleDatabaseOperation(() async {
      final db = await databaseService.database;
      final String dateString = _asDateString(date);
      final existing = await db.query(
        'body_metrics',
        where: 'log_date = ?',
        whereArgs: [dateString],
        limit: 1,
      );
      final payload = {
        'log_date': dateString,
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'body_fat_percent': bodyFatPercent,
        'created_at': DateTime.now().toIso8601String(),
      };
      if (existing.isEmpty) {
        await db.insert('body_metrics', payload);
      } else {
        await db.update(
          'body_metrics',
          payload,
          where: 'log_date = ?',
          whereArgs: [dateString],
        );
      }
    });
  }

  Future<BodyMetricModel?> getLatestBodyMetrics() async {
    return handleDatabaseOperation(() async {
      final db = await databaseService.database;
      final rows = await db.query(
        'body_metrics',
        orderBy: 'log_date DESC',
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }
      return BodyMetricModel.fromDb(rows.first);
    });
  }

  Future<List<BodyMetricModel>> getRecentBodyMetrics({int days = 30}) async {
    return handleDatabaseOperation(() async {
      final db = await databaseService.database;
      final rows = await db.query(
        'body_metrics',
        where: 'log_date >= date(\'now\', ?)',
        whereArgs: ['-${days - 1} day'],
        orderBy: 'log_date ASC',
      );
      return rows.map(BodyMetricModel.fromDb).toList();
    });
  }

  Future<List<WorkoutHistoryEntryModel>> getRecentSessionHistory(
      {int days = 42}) async {
    return handleDatabaseOperation(() async {
      final db = await databaseService.database;
      final rows = await db.rawQuery(
        '''
        SELECT
          s.id,
          s.session_date,
          s.started_at,
          s.workout_completed,
          s.session_note,
          COALESCE((
            SELECT SUM(ss.weight * ss.reps)
            FROM strength_sets ss
            WHERE ss.session_id = s.id
          ), 0) AS strength_volume,
          COALESCE((
            SELECT SUM(j.duration_seconds)
            FROM jump_rope_intervals j
            WHERE j.session_id = s.id
          ), 0) AS cardio_seconds
        FROM session_logs s
        WHERE s.session_date >= date('now', ?)
        ORDER BY s.session_date DESC, s.started_at DESC
        ''',
        ['-${days - 1} day'],
      );
      return rows.map(WorkoutHistoryEntryModel.fromDb).toList();
    });
  }

  String _asDateString(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}
