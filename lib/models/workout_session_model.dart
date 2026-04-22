class WorkoutSessionModel {
  final int id;
  final DateTime sessionDate;
  final DateTime startedAt;
  final bool workoutCompleted;
  final bool proteinCompleted;

  const WorkoutSessionModel({
    required this.id,
    required this.sessionDate,
    required this.startedAt,
    required this.workoutCompleted,
    required this.proteinCompleted,
  });

  factory WorkoutSessionModel.fromDb(Map<String, dynamic> data) {
    return WorkoutSessionModel(
      id: data['id'] as int,
      sessionDate: DateTime.parse(data['session_date'] as String),
      startedAt: DateTime.parse(data['started_at'] as String),
      workoutCompleted: (data['workout_completed'] as int) == 1,
      proteinCompleted: (data['protein_completed'] as int) == 1,
    );
  }
}
