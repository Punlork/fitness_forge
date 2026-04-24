import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/services/workout_timer_notification_service.dart';

class HomeTimerState {
  final int workSeconds;
  final int restSeconds;
  final int targetRounds;
  final int round;
  final int remainingSeconds;
  final bool isWorkPhase;
  final bool isRunning;

  const HomeTimerState({
    this.workSeconds = 40,
    this.restSeconds = 60,
    this.targetRounds = 6,
    this.round = 1,
    this.remainingSeconds = 40,
    this.isWorkPhase = true,
    this.isRunning = false,
  });

  HomeTimerState copyWith({
    int? workSeconds,
    int? restSeconds,
    int? targetRounds,
    int? round,
    int? remainingSeconds,
    bool? isWorkPhase,
    bool? isRunning,
  }) {
    return HomeTimerState(
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      targetRounds: targetRounds ?? this.targetRounds,
      round: round ?? this.round,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isWorkPhase: isWorkPhase ?? this.isWorkPhase,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class HomeTimerCubit extends Cubit<HomeTimerState> {
  final void Function(int workSeconds)? onWorkPhaseCompleted;

  HomeTimerCubit({this.onWorkPhaseCompleted}) : super(const HomeTimerState()) {
    unawaited(WorkoutTimerNotificationService.instance.initialize());
  }

  Timer? _intervalTimer;
  DateTime? _phaseEndsAt;
  bool _isAppInBackground = false;

  void onLifecycleChanged(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      _isAppInBackground = false;
      unawaited(WorkoutTimerNotificationService.instance.cancelTimerAlert());
      _reconcilePhaseAfterResume();
      return;
    }

    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached ||
        lifecycleState == AppLifecycleState.inactive) {
      _isAppInBackground = true;
      _scheduleBackgroundCompletionAlert();
    }
  }

  void onWorkSecondsChanged(int value) {
    final current = state;
    emit(
      current.copyWith(
        workSeconds: value,
        remainingSeconds: current.isWorkPhase && !current.isRunning
            ? value
            : current.remainingSeconds,
      ),
    );
  }

  void onRestSecondsChanged(int value) {
    final current = state;
    emit(
      current.copyWith(
        restSeconds: value,
        remainingSeconds: !current.isWorkPhase && !current.isRunning
            ? value
            : current.remainingSeconds,
      ),
    );
  }

  void onTargetRoundsChanged(int value) {
    emit(state.copyWith(targetRounds: value));
  }

  void toggleStartPause() {
    if (state.isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    if (state.isRunning) return;

    _phaseEndsAt = DateTime.now().add(
      Duration(seconds: state.remainingSeconds),
    );

    _intervalTimer?.cancel();
    emit(state.copyWith(isRunning: true));
    _intervalTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _onTimerTick();
    });
    _scheduleBackgroundCompletionAlert();
  }

  void pauseTimer() {
    _intervalTimer?.cancel();
    final endAt = _phaseEndsAt;
    emit(
      state.copyWith(
        isRunning: false,
        remainingSeconds:
            endAt == null ? state.remainingSeconds : _secondsUntil(endAt),
      ),
    );
    _phaseEndsAt = null;
    unawaited(WorkoutTimerNotificationService.instance.cancelTimerAlert());
  }

  void resetTimer() {
    _intervalTimer?.cancel();
    emit(
      state.copyWith(
        isRunning: false,
        isWorkPhase: true,
        round: 1,
        remainingSeconds: state.workSeconds,
      ),
    );
    _phaseEndsAt = null;
    unawaited(WorkoutTimerNotificationService.instance.cancelTimerAlert());
  }

  void skipPhase() {
    _advancePhase(
      shouldAlert: false,
      logWorkCompletion: false,
    );
  }

  Future<void> onPhaseCompletedAlert() async {
    final current = state;
    final bool completedWorkPhase = !current.isWorkPhase;
    if (current.round >= current.targetRounds && completedWorkPhase) {
      await WorkoutTimerNotificationService.instance.showCompletionAlert(
        title: 'Workout Complete',
        body: 'All rounds done. Great work.',
      );
      return;
    }

    final String nextPhase = current.isWorkPhase ? 'Work' : 'Rest';
    await WorkoutTimerNotificationService.instance.showCompletionAlert(
      title: '${completedWorkPhase ? 'Work' : 'Rest'} Complete',
      body: '$nextPhase phase has started.',
    );
  }

  void _onTimerTick() {
    final endAt = _phaseEndsAt;
    if (endAt == null) {
      return;
    }

    final int secondsLeft = _secondsUntil(endAt);
    if (secondsLeft <= 0) {
      _advancePhase(shouldAlert: !_isAppInBackground);
      return;
    }

    if (secondsLeft != state.remainingSeconds) {
      emit(state.copyWith(remainingSeconds: secondsLeft));
    }
  }

  void _advancePhase({
    required bool shouldAlert,
    bool logWorkCompletion = true,
  }) {
    final current = state;
    final bool wasWorkPhase = current.isWorkPhase;
    HomeTimerState nextState;

    if (current.isWorkPhase) {
      nextState = current.copyWith(
        isWorkPhase: false,
        remainingSeconds: current.restSeconds,
      );
    } else if (current.round >= current.targetRounds) {
      _intervalTimer?.cancel();
      nextState = current.copyWith(
        isRunning: false,
        isWorkPhase: true,
        remainingSeconds: current.workSeconds,
      );
    } else {
      nextState = current.copyWith(
        round: current.round + 1,
        isWorkPhase: true,
        remainingSeconds: current.workSeconds,
      );
    }

    emit(nextState);

    if (wasWorkPhase && logWorkCompletion) {
      onWorkPhaseCompleted?.call(current.workSeconds);
    }

    if (nextState.isRunning) {
      _phaseEndsAt = DateTime.now().add(
        Duration(seconds: nextState.remainingSeconds),
      );
      _scheduleBackgroundCompletionAlert();
    } else {
      _phaseEndsAt = null;
      unawaited(WorkoutTimerNotificationService.instance.cancelTimerAlert());
    }

    if (shouldAlert) {
      unawaited(onPhaseCompletedAlert());
    }
  }

  Future<void> _scheduleBackgroundCompletionAlert() async {
    if (!state.isRunning || !_isAppInBackground) {
      return;
    }
    final endAt = _phaseEndsAt;
    if (endAt == null) {
      return;
    }

    final String phase = state.isWorkPhase ? 'Work' : 'Rest';
    await WorkoutTimerNotificationService.instance.scheduleCompletionAlert(
      at: endAt,
      title: '$phase Complete',
      body: 'Open the app to continue your workout timer.',
    );
  }

  void _reconcilePhaseAfterResume() {
    if (!state.isRunning || _phaseEndsAt == null) {
      return;
    }

    int safetyCounter = 0;
    while (_phaseEndsAt != null &&
        _secondsUntil(_phaseEndsAt!) <= 0 &&
        state.isRunning &&
        safetyCounter < 20) {
      _advancePhase(shouldAlert: false);
      safetyCounter += 1;
    }

    final endAt = _phaseEndsAt;
    if (endAt != null) {
      emit(state.copyWith(remainingSeconds: _secondsUntil(endAt)));
    }
  }

  int _secondsUntil(DateTime endAt) {
    final int millis = endAt.difference(DateTime.now()).inMilliseconds;
    if (millis <= 0) {
      return 0;
    }
    return (millis / 1000).ceil();
  }

  @override
  Future<void> close() async {
    _intervalTimer?.cancel();
    await WorkoutTimerNotificationService.instance.cancelTimerAlert();
    return super.close();
  }
}
