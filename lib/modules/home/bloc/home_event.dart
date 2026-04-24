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

class SaveSessionNoteEvent extends HomeEvent {
  final String note;

  const SaveSessionNoteEvent({required this.note});

  @override
  List<Object?> get props => [note];
}

class DismissSessionSummaryEvent extends HomeEvent {
  const DismissSessionSummaryEvent();

  @override
  List<Object?> get props => [];
}

class StartWorkoutEvent extends HomeEvent {
  const StartWorkoutEvent();

  @override
  List<Object?> get props => [];
}

class LogCardioCheckEvent extends HomeEvent {
  final int roundNumber;

  const LogCardioCheckEvent({required this.roundNumber});

  @override
  List<Object?> get props => [roundNumber];
}

class LogWorkSetEvent extends HomeEvent {
  final String exerciseName;
  final int reps;
  final int roundNumber;

  const LogWorkSetEvent({
    required this.exerciseName,
    required this.reps,
    required this.roundNumber,
  });

  @override
  List<Object?> get props => [exerciseName, reps, roundNumber];
}

class LogTimedWorkEvent extends HomeEvent {
  final String exerciseName;
  final int durationSeconds;
  final int roundNumber;

  const LogTimedWorkEvent({
    required this.exerciseName,
    required this.durationSeconds,
    required this.roundNumber,
  });

  @override
  List<Object?> get props => [exerciseName, durationSeconds, roundNumber];
}

class AddRoundEvent extends HomeEvent {
  const AddRoundEvent();

  @override
  List<Object?> get props => [];
}

class RemoveRoundEvent extends HomeEvent {
  const RemoveRoundEvent({required this.roundNumber});

  final int roundNumber;

  @override
  List<Object?> get props => [roundNumber];
}
