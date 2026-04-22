import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_base_template/core/base_bloc.dart';
import 'package:flutter_base_template/core/error/app_error.dart';
import 'package:flutter_base_template/models/body_metric_model.dart';
import 'package:flutter_base_template/models/jump_rope_interval_model.dart';
import 'package:flutter_base_template/models/progress_point_model.dart';
import 'package:flutter_base_template/models/strength_set_model.dart';
import 'package:flutter_base_template/models/workout_plan_model.dart';
import 'package:flutter_base_template/models/workout_session_model.dart';
import 'package:flutter_base_template/repository/workout/local/local_workout_repository.dart';
import 'package:logger/logger.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
  final Logger _logger = Logger();
  final LocalWorkoutRepository _workoutRepository;
  Timer? _restTimer;
  static const int _defaultRestSeconds = 90;

  HomeBloc({LocalWorkoutRepository? workoutRepository})
      : _workoutRepository = workoutRepository ?? LocalWorkoutRepository(),
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
    } else if (event is DismissSessionSummaryEvent) {
      _dismissSessionSummary(emit);
    } else if (event is _RestTimerTickEvent) {
      _handleRestTimerTick(event, emit);
    } else {
      emit(const HomeError(message: 'Unknown event type'));
    }
  }

  Future<void> _initializeSession(Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    final existingSession = await _workoutRepository.getLatestSessionForToday();
    if (existingSession == null) {
      await _startNewSession(emit);
      return;
    }
    await _reloadSession(existingSession, emit);
  }

  Future<void> _startNewSession(Emitter<HomeState> emit) async {
    _logger.i('Starting a new workout session');
    _stopRestTimer();
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
      exerciseName: event.exerciseName,
      weight: event.weight,
      loadType: event.loadType,
      reps: event.reps,
    );

    _startRestTimer(_defaultRestSeconds);
    await _reloadSession(currentState.session, emit,
        restSecondsRemaining: _defaultRestSeconds);
  }

  void _handleRestTimerTick(
      _RestTimerTickEvent event, Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is! HomeReady) return;
    emit(currentState.copyWith(restSecondsRemaining: event.secondsRemaining));
  }

  Future<void> _completeSession(Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is! HomeReady) return;

    await _workoutRepository.completeSession(currentState.session.id);
    final updatedSession =
        await _workoutRepository.getSessionById(currentState.session.id);
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

  void _dismissSessionSummary(Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is! HomeReady) return;
    emit(currentState.copyWith(clearSessionSummaryMessage: true));
  }

  Future<void> _reloadSession(
    WorkoutSessionModel session,
    Emitter<HomeState> emit, {
    int restSecondsRemaining = 0,
  }) async {
    final WorkoutDayPlanModel todayPlan =
        WorkoutWeekPlan.forDate(DateTime.now());
    final List<JumpRopeIntervalModel> intervals =
        await _workoutRepository.getJumpRopeIntervals(session.id);
    final List<StrengthSetModel> strengthSets =
        await _workoutRepository.getStrengthSets(session.id);
    final List<ProgressPointModel> progressPoints =
        await _workoutRepository.getRecentProgress();
    final BodyMetricModel? latestBodyMetrics =
        await _workoutRepository.getLatestBodyMetrics();
    final List<BodyMetricModel> bodyMetricsHistory =
        await _workoutRepository.getRecentBodyMetrics();
    emit(HomeReady(
      session: session,
      todayPlan: todayPlan,
      intervals: intervals,
      strengthSets: strengthSets,
      progressPoints: progressPoints,
      latestBodyMetrics: latestBodyMetrics,
      bodyMetricsHistory: bodyMetricsHistory,
      restSecondsRemaining: restSecondsRemaining,
    ));
  }

  void _startRestTimer(int seconds) {
    _stopRestTimer();
    int remaining = seconds;
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining -= 1;
      if (remaining <= 0) {
        add(const _RestTimerTickEvent(0));
        timer.cancel();
        return;
      }
      add(_RestTimerTickEvent(remaining));
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
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
    _stopRestTimer();
    await super.close();
  }
}
