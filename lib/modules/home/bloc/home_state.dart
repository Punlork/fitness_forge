part of 'home_bloc.dart';

abstract class HomeState extends BaseState {
  const HomeState();
}

class HomeInitial extends HomeState {
  final String message;

  const HomeInitial({this.message = 'Start your workout session'});

  @override
  List<Object?> get props => [message];
}

class HomeLoading extends HomeState {
  const HomeLoading();

  @override
  List<Object?> get props => [];
}

class HomeReady extends HomeState {
  final WorkoutSessionModel session;
  final WorkoutDayPlanModel todayPlan;
  final List<JumpRopeIntervalModel> intervals;
  final List<StrengthSetModel> strengthSets;
  final List<StrengthSetModel> recentStrengthSets;
  final List<ProgressPointModel> progressPoints;
  final BodyMetricModel? latestBodyMetrics;
  final List<BodyMetricModel> bodyMetricsHistory;
  final List<WorkoutHistoryEntryModel> sessionHistory;
  final String? sessionSummaryMessage;
  final int currentRound;

  const HomeReady({
    required this.session,
    required this.todayPlan,
    required this.intervals,
    required this.strengthSets,
    required this.recentStrengthSets,
    required this.progressPoints,
    required this.latestBodyMetrics,
    required this.bodyMetricsHistory,
    required this.sessionHistory,
    this.sessionSummaryMessage,
    this.currentRound = 0,
  });

  double get totalStrengthVolume => strengthSets.fold<double>(
        0,
        (sum, set) => sum + set.volume,
      );

  int get cardioSeconds => intervals.fold<int>(
        0,
        (sum, interval) => sum + interval.durationSeconds,
      );

  bool get hasCardioLogged => cardioSeconds > 0;
  bool get hasStrengthLogged => strengthSets.isNotEmpty;
  double get currentWeekVolume => _sumStrengthInLastDays(progressPoints, 7);
  int get currentWeekCardioSessions =>
      _countCardioSessionsInLastDays(progressPoints, 7);
  double get weeklyVolumeGoal {
    final avg = _sumStrengthInLastDays(progressPoints, 28) / 4;
    return avg < 10000 ? 10000 : avg;
  }

  int get weeklyCardioSessionsGoal {
    final avg =
        (_countCardioSessionsInLastDays(progressPoints, 28) / 4).round();
    return avg < 3 ? 3 : avg;
  }

  String get primaryInsight {
    final currentMonth = _sumStrengthInLastDays(progressPoints, 30);
    final previousMonth = _sumStrengthInDaysAgoRange(progressPoints, 31, 60);
    if (currentMonth <= 0 && previousMonth <= 0) {
      return 'Log a few sessions to unlock trend insights.';
    }
    if (previousMonth <= 0) {
      return 'Great start. Keep logging to establish your monthly baseline.';
    }
    final percent = ((currentMonth - previousMonth) / previousMonth) * 100;
    final direction = percent >= 0 ? 'up' : 'down';
    return 'Your strength volume is ${percent.abs().toStringAsFixed(0)}% $direction vs last month.';
  }

  int get completionScore {
    int score = 0;
    if (hasCardioLogged) score += 40;
    if (hasStrengthLogged) score += 40;
    if (session.proteinCompleted) score += 20;
    return score;
  }

  int get computedRound {
    final maxIntervalRound = intervals.isEmpty
        ? 0
        : intervals.map((i) => i.roundNumber).reduce(
              (a, b) => a > b ? a : b,
            );

    final maxSetRound = strengthSets.isEmpty
        ? 0
        : strengthSets.map((s) => s.roundNumber).reduce(
              (a, b) => a > b ? a : b,
            );
    final maxDbRound =
        maxIntervalRound > maxSetRound ? maxIntervalRound : maxSetRound;

    return currentRound > maxDbRound ? currentRound : maxDbRound;
  }

  @override
  List<Object?> get props => [
        session,
        todayPlan,
        intervals,
        strengthSets,
        recentStrengthSets,
        progressPoints,
        latestBodyMetrics,
        bodyMetricsHistory,
        sessionHistory,
        sessionSummaryMessage,
        currentRound,
      ];

  HomeReady copyWith({
    WorkoutSessionModel? session,
    WorkoutDayPlanModel? todayPlan,
    List<JumpRopeIntervalModel>? intervals,
    List<StrengthSetModel>? strengthSets,
    List<StrengthSetModel>? recentStrengthSets,
    List<ProgressPointModel>? progressPoints,
    BodyMetricModel? latestBodyMetrics,
    List<BodyMetricModel>? bodyMetricsHistory,
    List<WorkoutHistoryEntryModel>? sessionHistory,
    String? sessionSummaryMessage,
    bool clearSessionSummaryMessage = false,
    int? currentRound,
  }) {
    return HomeReady(
      session: session ?? this.session,
      todayPlan: todayPlan ?? this.todayPlan,
      intervals: intervals ?? this.intervals,
      strengthSets: strengthSets ?? this.strengthSets,
      recentStrengthSets: recentStrengthSets ?? this.recentStrengthSets,
      progressPoints: progressPoints ?? this.progressPoints,
      latestBodyMetrics: latestBodyMetrics ?? this.latestBodyMetrics,
      bodyMetricsHistory: bodyMetricsHistory ?? this.bodyMetricsHistory,
      sessionHistory: sessionHistory ?? this.sessionHistory,
      sessionSummaryMessage: clearSessionSummaryMessage
          ? null
          : (sessionSummaryMessage ?? this.sessionSummaryMessage),
      currentRound: currentRound ?? this.currentRound,
    );
  }

  static double _sumStrengthInLastDays(
    List<ProgressPointModel> points,
    int days,
  ) {
    final threshold = DateTime.now().subtract(Duration(days: days - 1));
    return points
        .where((point) => !point.date.isBefore(threshold))
        .fold<double>(0, (sum, point) => sum + point.strengthVolume);
  }

  static double _sumStrengthInDaysAgoRange(
    List<ProgressPointModel> points,
    int minDaysAgo,
    int maxDaysAgo,
  ) {
    final start = DateTime.now().subtract(Duration(days: maxDaysAgo));
    final end = DateTime.now().subtract(Duration(days: minDaysAgo - 1));
    return points
        .where((point) => point.date.isAfter(start) && point.date.isBefore(end))
        .fold<double>(0, (sum, point) => sum + point.strengthVolume);
  }

  static int _countCardioSessionsInLastDays(
    List<ProgressPointModel> points,
    int days,
  ) {
    final threshold = DateTime.now().subtract(Duration(days: days - 1));
    return points
        .where(
          (point) => !point.date.isBefore(threshold) && point.cardioSeconds > 0,
        )
        .length;
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
