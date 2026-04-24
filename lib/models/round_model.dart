import 'strength_set_model.dart';

class RoundData {
  final int roundNumber;
  final bool hasCardio;
  final List<StrengthSetModel> workLogs;

  const RoundData({
    required this.roundNumber,
    required this.hasCardio,
    required this.workLogs,
  });
}
