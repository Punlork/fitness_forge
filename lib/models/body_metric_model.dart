class BodyMetricModel {
  final int id;
  final DateTime logDate;
  final double weightKg;
  final double heightCm;
  final double bodyFatPercent;
  final DateTime createdAt;

  const BodyMetricModel({
    required this.id,
    required this.logDate,
    required this.weightKg,
    required this.heightCm,
    required this.bodyFatPercent,
    required this.createdAt,
  });

  double get bmi {
    final double heightMeters = heightCm / 100;
    if (heightMeters <= 0) {
      return 0;
    }
    return weightKg / (heightMeters * heightMeters);
  }

  factory BodyMetricModel.fromDb(Map<String, dynamic> data) {
    return BodyMetricModel(
      id: data['id'] as int,
      logDate: DateTime.parse(data['log_date'] as String),
      weightKg: (data['weight_kg'] as num).toDouble(),
      heightCm: (data['height_cm'] as num).toDouble(),
      bodyFatPercent: (data['body_fat_percent'] as num).toDouble(),
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}
