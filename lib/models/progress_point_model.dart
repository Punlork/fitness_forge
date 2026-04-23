class ProgressPointModel {
  final DateTime date;
  final double strengthVolume;
  final int cardioSeconds;

  const ProgressPointModel({
    required this.date,
    required this.strengthVolume,
    required this.cardioSeconds,
  });

  factory ProgressPointModel.fromDb(Map<String, dynamic> data) {
    return ProgressPointModel(
      date: DateTime.tryParse(data['date'] as String? ?? '') ?? DateTime.now(),
      strengthVolume: (data['strength_volume'] as num?)?.toDouble() ?? 0,
      cardioSeconds: (data['cardio_seconds'] as num?)?.toInt() ?? 0,
    );
  }
}
