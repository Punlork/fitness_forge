import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/services/workout_timer_notification_service.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class HomeTimerState {
  final int workSeconds;
  final int restSeconds;
  final int targetRounds;
  final int round;
  final int remainingSeconds;
  final bool isWorkPhase;
  final bool isRunning;
  final bool isPhaseCompleteAwaitingNext;

  const HomeTimerState({
    this.workSeconds = 40,
    this.restSeconds = 60,
    this.targetRounds = 6,
    this.round = 1,
    this.remainingSeconds = 40,
    this.isWorkPhase = true,
    this.isRunning = false,
    this.isPhaseCompleteAwaitingNext = false,
  });

  HomeTimerState copyWith({
    int? workSeconds,
    int? restSeconds,
    int? targetRounds,
    int? round,
    int? remainingSeconds,
    bool? isWorkPhase,
    bool? isRunning,
    bool? isPhaseCompleteAwaitingNext,
  }) {
    return HomeTimerState(
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      targetRounds: targetRounds ?? this.targetRounds,
      round: round ?? this.round,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isWorkPhase: isWorkPhase ?? this.isWorkPhase,
      isRunning: isRunning ?? this.isRunning,
      isPhaseCompleteAwaitingNext:
          isPhaseCompleteAwaitingNext ?? this.isPhaseCompleteAwaitingNext,
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
    if (state.isRunning) {
      return;
    }
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
    if (state.isRunning) {
      return;
    }
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
    if (state.isRunning) {
      return;
    }
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
    unawaited(WorkoutTimerNotificationService.instance.requestPermissions());

    _phaseEndsAt = DateTime.now().add(
      Duration(seconds: state.remainingSeconds),
    );

    _intervalTimer?.cancel();
    emit(
      state.copyWith(
        isRunning: true,
      ),
    );
    _intervalTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) {
        _onTimerTick();
      },
    );
    _scheduleBackgroundCompletionAlert();
  }

  void requestNotificationPermissions() {
    unawaited(WorkoutTimerNotificationService.instance.requestPermissions());
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
    final current = state;
    emit(
      current.copyWith(
        isRunning: false,
        isPhaseCompleteAwaitingNext: false,
        remainingSeconds:
            current.isWorkPhase ? current.workSeconds : current.restSeconds,
      ),
    );
    _phaseEndsAt = null;
    unawaited(WorkoutTimerNotificationService.instance.cancelTimerAlert());
  }

  void skipPhase() {
    _advanceToNextPhase(
      shouldAlert: false,
      startImmediately: state.isRunning,
      logCurrentWorkCompletion: false,
    );
  }

  Future<void> onPhaseCompletedAlert({
    required bool completedWorkPhase,
    required bool workoutComplete,
    required bool nextPhaseIsWork,
  }) async {
    if (workoutComplete) {
      await WorkoutTimerNotificationService.instance.showCompletionAlert(
        title: 'Workout Complete',
        body: 'All rounds done. Tap Reset to start a new session.',
      );
      return;
    }

    final String nextPhase = nextPhaseIsWork ? 'Work' : 'Rest';
    await WorkoutTimerNotificationService.instance.showCompletionAlert(
      title: '${completedWorkPhase ? 'Work' : 'Rest'} Complete',
      body: '$nextPhase is ready. Tap Start to continue.',
    );
  }

  void _onTimerTick() {
    final endAt = _phaseEndsAt;
    if (endAt == null) {
      return;
    }

    final int secondsLeft = _secondsUntil(endAt);
    if (secondsLeft <= 0) {
      _completeCurrentPhase(
        shouldAlert: !_isAppInBackground,
      );
      return;
    }

    if (secondsLeft != state.remainingSeconds) {
      emit(state.copyWith(remainingSeconds: secondsLeft));
    }
  }

  void _completeCurrentPhase({
    required bool shouldAlert,
  }) {
    final current = state;
    final bool completedWorkPhase = current.isWorkPhase;
    final bool workoutComplete =
        !current.isWorkPhase && current.round >= current.targetRounds;

    _intervalTimer?.cancel();
    _phaseEndsAt = null;
    unawaited(WorkoutTimerNotificationService.instance.cancelTimerAlert());

    if (completedWorkPhase) {
      onWorkPhaseCompleted?.call(current.workSeconds);
    }

    unawaited(_triggerCompletionHaptic());

    if (workoutComplete) {
      emit(
        current.copyWith(
          isRunning: false,
          isWorkPhase: true,
          remainingSeconds: current.workSeconds,
          isPhaseCompleteAwaitingNext: false,
        ),
      );
      if (shouldAlert) {
        unawaited(
          onPhaseCompletedAlert(
            completedWorkPhase: completedWorkPhase,
            workoutComplete: true,
            nextPhaseIsWork: true,
          ),
        );
      }
      return;
    }

    final HomeTimerState nextState;
    if (current.isWorkPhase) {
      nextState = current.copyWith(
        isWorkPhase: false,
        remainingSeconds: current.restSeconds,
        isRunning: false,
        isPhaseCompleteAwaitingNext: true,
      );
    } else {
      nextState = current.copyWith(
        round: current.round + 1,
        isWorkPhase: true,
        remainingSeconds: current.workSeconds,
        isRunning: false,
        isPhaseCompleteAwaitingNext: true,
      );
    }

    emit(nextState);

    if (!shouldAlert) {
      return;
    }

    unawaited(
      onPhaseCompletedAlert(
        completedWorkPhase: completedWorkPhase,
        workoutComplete: false,
        nextPhaseIsWork: nextState.isWorkPhase,
      ),
    );
  }

  void _advanceToNextPhase({
    required bool shouldAlert,
    required bool startImmediately,
    bool logCurrentWorkCompletion = false,
  }) {
    final current = state;
    final bool completedWorkPhase = current.isWorkPhase;
    final bool workoutComplete =
        !current.isWorkPhase && current.round >= current.targetRounds;

    if (logCurrentWorkCompletion && completedWorkPhase) {
      onWorkPhaseCompleted?.call(current.workSeconds);
    }

    if (workoutComplete) {
      emit(
        current.copyWith(
          isRunning: false,
          isWorkPhase: true,
          remainingSeconds: current.workSeconds,
          isPhaseCompleteAwaitingNext: false,
        ),
      );
      _phaseEndsAt = null;
      unawaited(WorkoutTimerNotificationService.instance.cancelTimerAlert());
      return;
    }

    final HomeTimerState nextState;
    if (current.isWorkPhase) {
      nextState = current.copyWith(
        isWorkPhase: false,
        remainingSeconds: current.restSeconds,
        isRunning: startImmediately,
        isPhaseCompleteAwaitingNext: false,
      );
    } else {
      nextState = current.copyWith(
        round: current.round + 1,
        isWorkPhase: true,
        remainingSeconds: current.workSeconds,
        isRunning: startImmediately,
        isPhaseCompleteAwaitingNext: false,
      );
    }

    emit(nextState);

    if (startImmediately) {
      _phaseEndsAt = DateTime.now().add(
        Duration(seconds: nextState.remainingSeconds),
      );
      _scheduleBackgroundCompletionAlert();
    } else {
      _phaseEndsAt = null;
      unawaited(WorkoutTimerNotificationService.instance.cancelTimerAlert());
    }

    if (!shouldAlert) {
      return;
    }

    unawaited(
      onPhaseCompletedAlert(
        completedWorkPhase: completedWorkPhase,
        workoutComplete: false,
        nextPhaseIsWork: nextState.isWorkPhase,
      ),
    );
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

    final endAt = _phaseEndsAt;
    if (endAt == null) {
      return;
    }

    final int secondsLeft = _secondsUntil(endAt);
    if (secondsLeft <= 0) {
      _completeCurrentPhase(shouldAlert: true);
      return;
    }

    emit(state.copyWith(remainingSeconds: secondsLeft));
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

  Future<void> _triggerCompletionHaptic() async {
    const pulseCount = 7;
    const pulseSpacing = Duration(milliseconds: 700);

    try {
      if (await Haptics.canVibrate()) {
        for (var i = 0; i < pulseCount; i++) {
          await Haptics.vibrate(
            HapticsType.heavy,
            usage: HapticsUsage.notification,
          );
          if (i < pulseCount - 1) {
            await Future<void>.delayed(pulseSpacing);
          }
        }
        return;
      }
    } on PlatformException {
      // Fall back to default haptic.
    }

    for (var i = 0; i < pulseCount; i++) {
      await HapticFeedback.vibrate();
      if (i < pulseCount - 1) {
        await Future<void>.delayed(pulseSpacing);
      }
    }
  }
}
