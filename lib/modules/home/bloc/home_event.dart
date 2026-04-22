part of 'home_bloc.dart';

abstract class HomeEvent extends BaseEvent {
  const HomeEvent();
}

class InitializeHomeEvent extends HomeEvent {
  const InitializeHomeEvent();

  @override
  List<Object?> get props => [];
}

class StartNewSessionEvent extends HomeEvent {
  const StartNewSessionEvent();

  @override
  List<Object?> get props => [];
}

class AddJumpRopeIntervalEvent extends HomeEvent {
  final String intervalType;
  final int durationSeconds;

  const AddJumpRopeIntervalEvent({
    required this.intervalType,
    required this.durationSeconds,
  });

  @override
  List<Object?> get props => [intervalType, durationSeconds];
}

class AddStrengthSetEvent extends HomeEvent {
  final String exerciseName;
  final double weight;
  final StrengthLoadType loadType;
  final int reps;

  const AddStrengthSetEvent({
    required this.exerciseName,
    required this.weight,
    required this.loadType,
    required this.reps,
  });

  @override
  List<Object?> get props => [exerciseName, weight, loadType, reps];
}

class CompleteSessionEvent extends HomeEvent {
  const CompleteSessionEvent();

  @override
  List<Object?> get props => [];
}

class SaveBodyMetricsEvent extends HomeEvent {
  final double weightKg;
  final double heightCm;
  final double bodyFatPercent;

  const SaveBodyMetricsEvent({
    required this.weightKg,
    required this.heightCm,
    required this.bodyFatPercent,
  });

  @override
  List<Object?> get props => [weightKg, heightCm, bodyFatPercent];
}

class DismissSessionSummaryEvent extends HomeEvent {
  const DismissSessionSummaryEvent();

  @override
  List<Object?> get props => [];
}

class _RestTimerTickEvent extends HomeEvent {
  final int secondsRemaining;

  const _RestTimerTickEvent(this.secondsRemaining);

  @override
  List<Object?> get props => [secondsRemaining];
}
