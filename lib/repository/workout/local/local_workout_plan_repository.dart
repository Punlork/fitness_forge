import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:forge/models/workout_plan_model.dart';

class LocalWorkoutPlanRepository {
  static const String _weekPlanAssetPath = 'lib/data/workout_week_plan.json';
  static const String _exerciseAssetPath = 'lib/data/exercise.json';

  WorkoutWeekPlan? _cachedPlan;

  Future<WorkoutWeekPlan> getWeekPlan() async {
    final cachedPlan = _cachedPlan;
    if (cachedPlan != null) {
      return cachedPlan;
    }

    final rawWeekPlanJson = await rootBundle.loadString(_weekPlanAssetPath);
    final rawExerciseJson = await rootBundle.loadString(_exerciseAssetPath);
    final weekPlanDecoded = jsonDecode(rawWeekPlanJson) as Map<String, dynamic>;
    final exerciseDecoded = jsonDecode(rawExerciseJson) as Map<String, dynamic>;

    final exerciseLibrary =
        (exerciseDecoded['exercise_library'] as List<dynamic>)
            .map(
              (json) => ExercisePlan.fromJson(json as Map<String, dynamic>),
            )
            .toList(growable: false);
    final exerciseById = {
      for (final exercise in exerciseLibrary) exercise.id: exercise,
    };

    final weeklyPlan = weekPlanDecoded['weekly_plan'] as List<dynamic>;
    final loadedPlan = WorkoutWeekPlan(
      days: weeklyPlan
          .map((dayJson) =>
              _mapDay(dayJson as Map<String, dynamic>, exerciseById))
          .toList(growable: false),
    );

    _cachedPlan = loadedPlan;
    return loadedPlan;
  }

  Future<WorkoutDayPlanModel> getWorkoutForDate(DateTime date) async {
    final weekPlan = await getWeekPlan();
    return weekPlan.forDate(date);
  }

  Future<WorkoutDayPlanModel> getTodayWorkout() async {
    final weekPlan = await getWeekPlan();
    return weekPlan.todayWorkout;
  }

  WorkoutDayPlanModel _mapDay(
    Map<String, dynamic> dayJson,
    Map<String, ExercisePlan> exerciseById,
  ) {
    final primaryIds =
        (dayJson['primary_pool'] as List<dynamic>? ?? const []).cast<String>();
    final supportIds =
        (dayJson['support_pool'] as List<dynamic>? ?? const []).cast<String>();

    final primaryPoolExercises = _resolveExercises(primaryIds, exerciseById);
    final supportPoolExercises = _resolveExercises(supportIds, exerciseById);
    final fallbackExercises =
        (dayJson['exercises'] as List<dynamic>? ?? const [])
            .map((json) => ExercisePlan.fromJson(json as Map<String, dynamic>))
            .toList(growable: false);

    return WorkoutDayPlanModel(
      weekday: dayJson['weekday'] as int,
      dayLabel: dayJson['dayLabel'] as String,
      focus: dayJson['focus'] as String,
      type: WorkoutType.values.byName(dayJson['type'] as String),
      cardioMode: CardioMode.values.byName(dayJson['cardioMode'] as String),
      cardioSeconds: dayJson['cardioSeconds'] as int,
      cardioDescription: dayJson['cardioDescription'] as String,
      transitionSeconds: dayJson['transitionSeconds'] as int,
      transitionDescription: dayJson['transitionDescription'] as String,
      workSeconds: dayJson['workSeconds'] as int,
      workDescription: dayJson['workDescription'] as String,
      exercises: primaryPoolExercises.isNotEmpty
          ? primaryPoolExercises
          : fallbackExercises,
      primaryPoolExercises: primaryPoolExercises,
      supportPoolExercises: supportPoolExercises,
      logicHint: (dayJson['logic_hint'] as String?) ?? '',
    );
  }

  List<ExercisePlan> _resolveExercises(
    List<String> ids,
    Map<String, ExercisePlan> exerciseById,
  ) {
    return ids
        .map((id) => exerciseById[id])
        .whereType<ExercisePlan>()
        .toList(growable: false);
  }
}
