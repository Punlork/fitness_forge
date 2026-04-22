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
  final List<ProgressPointModel> progressPoints;
  final BodyMetricModel? latestBodyMetrics;
  final List<BodyMetricModel> bodyMetricsHistory;
  final String? sessionSummaryMessage;
  final int restSecondsRemaining;

  const HomeReady({
    required this.session,
    required this.todayPlan,
    required this.intervals,
    required this.strengthSets,
    required this.progressPoints,
    required this.latestBodyMetrics,
    required this.bodyMetricsHistory,
    this.sessionSummaryMessage,
    this.restSecondsRemaining = 0,
  });

  double get totalStrengthVolume =>
      strengthSets.fold<double>(0, (sum, set) => sum + set.volume);
  int get cardioSeconds =>
      intervals.fold<int>(0, (sum, interval) => sum + interval.durationSeconds);
  bool get hasCardioLogged => cardioSeconds > 0;
  bool get hasStrengthLogged => strengthSets.isNotEmpty;

  int get completionScore {
    int score = 0;
    if (hasCardioLogged) score += 40;
    if (hasStrengthLogged) score += 40;
    if (session.proteinCompleted) score += 20;
    return score;
  }

  @override
  List<Object?> get props => [
        session,
        todayPlan,
        intervals,
        strengthSets,
        progressPoints,
        latestBodyMetrics,
        bodyMetricsHistory,
        sessionSummaryMessage,
        restSecondsRemaining,
      ];

  HomeReady copyWith({
    WorkoutSessionModel? session,
    WorkoutDayPlanModel? todayPlan,
    List<JumpRopeIntervalModel>? intervals,
    List<StrengthSetModel>? strengthSets,
    List<ProgressPointModel>? progressPoints,
    BodyMetricModel? latestBodyMetrics,
    List<BodyMetricModel>? bodyMetricsHistory,
    String? sessionSummaryMessage,
    bool clearSessionSummaryMessage = false,
    int? restSecondsRemaining,
  }) {
    return HomeReady(
      session: session ?? this.session,
      todayPlan: todayPlan ?? this.todayPlan,
      intervals: intervals ?? this.intervals,
      strengthSets: strengthSets ?? this.strengthSets,
      progressPoints: progressPoints ?? this.progressPoints,
      latestBodyMetrics: latestBodyMetrics ?? this.latestBodyMetrics,
      bodyMetricsHistory: bodyMetricsHistory ?? this.bodyMetricsHistory,
      sessionSummaryMessage: clearSessionSummaryMessage
          ? null
          : (sessionSummaryMessage ?? this.sessionSummaryMessage),
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
