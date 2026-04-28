import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/base_bloc.dart';
import 'package:forge/core/error/app_error.dart';
import 'package:forge/models/body_metric_model.dart';
import 'package:forge/models/jump_rope_interval_model.dart';
import 'package:forge/models/progress_point_model.dart';
import 'package:forge/models/strength_set_model.dart';
import 'package:forge/models/workout_history_entry_model.dart';
import 'package:forge/models/workout_plan_model.dart';
import 'package:forge/models/workout_session_model.dart';
import 'package:forge/repository/workout/local/local_workout_plan_repository.dart';
import 'package:forge/repository/workout/local/local_workout_repository.dart';
import 'package:logger/logger.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
  final Logger _logger = Logger();
  final LocalWorkoutRepository _workoutRepository;
  final LocalWorkoutPlanRepository _workoutPlanRepository;

  HomeBloc({
    LocalWorkoutRepository? workoutRepository,
    LocalWorkoutPlanRepository? workoutPlanRepository,
  })  : _workoutRepository = workoutRepository ?? LocalWorkoutRepository(),
        _workoutPlanRepository =
            workoutPlanRepository ?? LocalWorkoutPlanRepository(),
        super(const HomeInitial());

  @override
  Future<void> handleEvent(HomeEvent event, Emitter<HomeState> emit) async {
    if (event is InitializeHomeEvent) {
      await _initializeSession(emit);
    } else if (event is StartNewSessionEvent) {
      await _startNewSession(emit);
    } else if (event is AddJumpRopeIntervalEvent) {
      await _addJumpRopeInterval(event, emit);
    } else if (event is AddStrengthSetEvent) {
      await _addStrengthSet(event, emit);
    } else if (event is CompleteSessionEvent) {
      await _completeSession(emit);
    } else if (event is SaveBodyMetricsEvent) {
      await _saveBodyMetrics(event, emit);
    } else if (event is SaveSessionNoteEvent) {
      await _saveSessionNote(event, emit);
    } else if (event is DismissSessionSummaryEvent) {
      _dismissSessionSummary(emit);
    } else if (event is LogCardioCheckEvent) {
      await _logCardioCheck(event, emit);
    } else if (event is LogWorkSetEvent) {
      await _logWorkSet(event, emit);
    } else if (event is LogTimedWorkEvent) {
      await _logTimedWork(event, emit);
    } else if (event is AddRoundEvent) {
      _addRound(emit);
    } else if (event is RemoveRoundEvent) {
      _removeRound(event, emit);
    } else {
      emit(const HomeError(message: 'Unknown event type'));
    }
  }

  Future<void> _initializeSession(Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _workoutPlanRepository.getWeekPlan();
    final existingSession = await _workoutRepository.getLatestSessionForToday();
    if (existingSession == null) {
      await _startNewSession(emit);
      return;
    }
    await _reloadSession(existingSession, emit);
  }

  Future<void> _startNewSession(Emitter<HomeState> emit) async {
    _logger.i('Starting a new workout session');
    final id = await _workoutRepository.startSession();
    final session = await _workoutRepository.getLatestSessionForToday();
    if (session == null || session.id != id) {
      emit(const HomeError(message: 'Unable to start session'));
      return;
    }
    await _reloadSession(session, emit);
  }

  Future<void> _addJumpRopeInterval(
    AddJumpRopeIntervalEvent event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeReady) return;

    await _workoutRepository.addJumpRopeInterval(
      sessionId: currentState.session.id,
      intervalType: event.intervalType,
      durationSeconds: event.durationSeconds,
    );

    await _reloadSession(currentState.session, emit);
  }

  Future<void> _addStrengthSet(
    AddStrengthSetEvent event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeReady) return;

    await _workoutRepository.addStrengthSet(
      sessionId: currentState.session.id,
      exerciseId: event.exerciseId,
      exerciseName: event.exerciseName,
      weight: event.weight,
      loadType: event.loadType,
      isTimedWork: event.isTimedWork,
      reps: event.reps,
    );

    await _reloadSession(currentState.session, emit);
  }

  Future<void> _completeSession(Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is! HomeReady) return;

    await _workoutRepository.completeSession(
      currentState.session.id,
    );

    final updatedSession = await _workoutRepository.getSessionById(
      currentState.session.id,
    );

    if (updatedSession == null) {
      return;
    }

    await _reloadSession(updatedSession, emit);
    final refreshed = state;
    if (refreshed is HomeReady) {
      emit(
        refreshed.copyWith(
          sessionSummaryMessage:
              'Session complete: ${refreshed.intervals.length} cardio intervals, ${refreshed.strengthSets.length} strength sets, total volume ${refreshed.totalStrengthVolume.toStringAsFixed(1)}.',
        ),
      );
    }
  }

  Future<void> _saveBodyMetrics(
    SaveBodyMetricsEvent event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeReady) return;

    await _workoutRepository.upsertBodyMetrics(
      date: DateTime.now(),
      weightKg: event.weightKg,
      heightCm: event.heightCm,
      bodyFatPercent: event.bodyFatPercent,
    );

    await _reloadSession(currentState.session, emit);
  }

  Future<void> _saveSessionNote(
    SaveSessionNoteEvent event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeReady) return;

    await _workoutRepository.saveSessionNote(
      sessionId: currentState.session.id,
      note: event.note,
    );
    final updatedSession =
        await _workoutRepository.getSessionById(currentState.session.id);
    if (updatedSession == null) {
      return;
    }
    await _reloadSession(updatedSession, emit);
  }

  void _dismissSessionSummary(Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is! HomeReady) return;
    emit(currentState.copyWith(clearSessionSummaryMessage: true));
  }

  Future<void> _logCardioCheck(
    LogCardioCheckEvent event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeReady) return;

    await _workoutRepository.addJumpRopeInterval(
      sessionId: currentState.session.id,
      intervalType: currentState.todayPlan.cardioMode.name,
      durationSeconds: currentState.todayPlan.cardioSeconds,
      roundNumber: event.roundNumber,
    );

    await _reloadSession(currentState.session, emit);
  }

  Future<void> _logWorkSet(
    LogWorkSetEvent event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeReady) return;

    await _workoutRepository.addStrengthSet(
      sessionId: currentState.session.id,
      exerciseId: event.exerciseId,
      exerciseName: event.exerciseName,
      isTimedWork: false,
      reps: event.reps,
      roundNumber: event.roundNumber,
    );

    await _reloadSession(currentState.session, emit);
  }

  Future<void> _logTimedWork(
    LogTimedWorkEvent event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeReady) return;

    await _workoutRepository.addStrengthSet(
      sessionId: currentState.session.id,
      exerciseId: event.exerciseId,
      exerciseName: event.exerciseName,
      isTimedWork: true,
      reps: event.durationSeconds,
      roundNumber: event.roundNumber,
    );

    await _reloadSession(currentState.session, emit);
  }

  void _addRound(Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is! HomeReady) return;
    emit(currentState.copyWith(currentRound: currentState.currentRound + 1));
  }

  void _removeRound(RemoveRoundEvent event, Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is! HomeReady) return;

    // Remove all jump rope intervals and strength sets with the specified roundNumber

    final updatedIntervals = currentState.intervals
        .where((interval) => interval.roundNumber != event.roundNumber)
        .toList();

    final updatedStrengthSets = currentState.strengthSets
        .where((set) => set.roundNumber != event.roundNumber)
        .toList();

    emit(
      currentState.copyWith(
        intervals: updatedIntervals,
        strengthSets: updatedStrengthSets,
        // If the removed round was the current round, decrease currentRound if needed
        currentRound: currentState.currentRound > 0 &&
                currentState.currentRound == event.roundNumber
            ? currentState.currentRound - 1
            : currentState.currentRound,
      ),
    );
  }

  Future<void> _reloadSession(
    WorkoutSessionModel session,
    Emitter<HomeState> emit,
  ) async {
    final todayPlan = await _workoutPlanRepository.getTodayWorkout();

    final intervals = await _workoutRepository.getJumpRopeIntervals(
      session.id,
    );
    final strengthSets = await _workoutRepository.getStrengthSets(
      session.id,
    );
    final recentStrengthSets = await _workoutRepository.getRecentStrengthSets(
      days: 60,
    );
    final progressPoints = await _workoutRepository.getRecentProgress(
      days: 60,
    );
    final latestBodyMetrics = await _workoutRepository.getLatestBodyMetrics();
    final bodyMetricsHistory = await _workoutRepository.getRecentBodyMetrics();
    final sessionHistory = await _workoutRepository.getRecentSessionHistory();

    final currentState = state;
    final int wasRound =
        currentState is HomeReady ? currentState.currentRound : 0;

    emit(
      HomeReady(
        session: session,
        todayPlan: todayPlan,
        intervals: intervals,
        strengthSets: strengthSets,
        recentStrengthSets: recentStrengthSets,
        progressPoints: progressPoints,
        latestBodyMetrics: latestBodyMetrics,
        bodyMetricsHistory: bodyMetricsHistory,
        sessionHistory: sessionHistory,
        currentRound: wasRound,
      ),
    );
  }

  @override
  Future<void> handleError(
    dynamic error,
    StackTrace stackTrace,
    Emitter<HomeState> emit,
  ) async {
    // Custom error handling for HomeBloc
    AppError.create(
      message: 'Error in HomeBloc',
      type: ErrorType.unknown,
      originalError: error,
      stackTrace: stackTrace,
    );
    emit(HomeError(message: error.toString()));
  }

  @override
  Future<void> close() async {
    await super.close();
  }
}
