class WorkoutHistoryEntryModel {
  final int sessionId;
  final DateTime sessionDate;
  final DateTime startedAt;
  final bool workoutCompleted;
  final double strengthVolume;
  final int cardioSeconds;
  final String sessionNote;

  const WorkoutHistoryEntryModel({
    required this.sessionId,
    required this.sessionDate,
    required this.startedAt,
    required this.workoutCompleted,
    required this.strengthVolume,
    required this.cardioSeconds,
    required this.sessionNote,
  });

  factory WorkoutHistoryEntryModel.fromDb(Map<String, dynamic> data) {
    return WorkoutHistoryEntryModel(
      sessionId: (data['id'] as num?)?.toInt() ?? 0,
      sessionDate:
          DateTime.tryParse(data['session_date'] as String? ?? '') ??
              DateTime.now(),
      startedAt: DateTime.tryParse(data['started_at'] as String? ?? '') ??
          DateTime.now(),
      workoutCompleted: (data['workout_completed'] as int?) == 1,
      strengthVolume: (data['strength_volume'] as num?)?.toDouble() ?? 0,
      cardioSeconds: (data['cardio_seconds'] as num?)?.toInt() ?? 0,
      sessionNote: data['session_note'] as String? ?? '',
    );
  }
}
