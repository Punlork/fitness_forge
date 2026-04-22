enum StrengthLoadType {
  bodyweight,
  external,
  assisted,
}

class StrengthSetModel {
  final int id;
  final int sessionId;
  final String exerciseName;
  final double weight;
  final StrengthLoadType loadType;
  final int reps;
  final DateTime createdAt;

  const StrengthSetModel({
    required this.id,
    required this.sessionId,
    required this.exerciseName,
    required this.weight,
    required this.loadType,
    required this.reps,
    required this.createdAt,
  });

  double get volume => weight * reps;

  factory StrengthSetModel.fromDb(Map<String, dynamic> data) {
    return StrengthSetModel(
      id: data['id'] as int,
      sessionId: data['session_id'] as int,
      exerciseName: data['exercise_name'] as String,
      weight: (data['weight'] as num).toDouble(),
      loadType: _loadTypeFromValue(data['load_type'] as String?),
      reps: data['reps'] as int,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  static StrengthLoadType _loadTypeFromValue(String? value) {
    switch (value) {
      case 'bodyweight':
        return StrengthLoadType.bodyweight;
      case 'assisted':
        return StrengthLoadType.assisted;
      case 'external':
      default:
        return StrengthLoadType.external;
    }
  }
}
