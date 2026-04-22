class JumpRopeIntervalModel {
  final int id;
  final int sessionId;
  final String intervalType;
  final int durationSeconds;
  final int intervalOrder;
  final DateTime createdAt;

  const JumpRopeIntervalModel({
    required this.id,
    required this.sessionId,
    required this.intervalType,
    required this.durationSeconds,
    required this.intervalOrder,
    required this.createdAt,
  });

  factory JumpRopeIntervalModel.fromDb(Map<String, dynamic> data) {
    return JumpRopeIntervalModel(
      id: data['id'] as int,
      sessionId: data['session_id'] as int,
      intervalType: data['interval_type'] as String,
      durationSeconds: data['duration_seconds'] as int,
      intervalOrder: data['interval_order'] as int,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}
