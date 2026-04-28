enum CardioMode {
  steady,
  highIntensity,
  variable,
  easy,
  none,
}

extension CardioModeLabel on CardioMode {
  String get label {
    switch (this) {
      case CardioMode.highIntensity:
        return 'hiit';
      case CardioMode.variable:
        return 'variable';
      case CardioMode.easy:
        return 'easy';
      case CardioMode.none:
        return 'rest';
      case CardioMode.steady:
        return 'steady';
    }
  }
}

enum WorkoutType {
  strength,
  hiit,
  circuit,
  holds,
  recovery,
  rest,
}

enum ExerciseLogUnit {
  reps,
  seconds,
}

class ExercisePlan {
  final String id;
  final String name;
  final String? repsTarget;
  final String? durationTarget;
  final ExerciseLogUnit logUnit;
  final String howTo;
  final String mistake;

  const ExercisePlan({
    required this.id,
    required this.name,
    this.repsTarget,
    this.durationTarget,
    required this.logUnit,
    required this.howTo,
    required this.mistake,
  });

  factory ExercisePlan.fromJson(Map<String, dynamic> json) {
    final String? unitRaw = json['logUnit'] as String?;
    final ExerciseLogUnit logUnit = unitRaw != null
        ? ExerciseLogUnit.values.byName(unitRaw)
        : ((json['durationTarget'] as String?) != null
            ? ExerciseLogUnit.seconds
            : ExerciseLogUnit.reps);
    return ExercisePlan(
      id: (json['id'] as String?) ?? (json['name'] as String),
      name: json['name'] as String,
      repsTarget: json['repsTarget'] as String?,
      durationTarget: json['durationTarget'] as String?,
      logUnit: logUnit,
      howTo: json['howTo'] as String,
      mistake:
          (json['mistake'] as String?) ?? (json['commonMistake'] as String),
    );
  }
}

class WorkoutDayPlanModel {
  final int weekday;
  final String dayLabel;
  final String focus;
  final WorkoutType type;
  final CardioMode cardioMode;
  final int cardioSeconds;
  final String cardioDescription;
  final int transitionSeconds;
  final String transitionDescription;
  final int workSeconds;
  final String workDescription;
  final List<ExercisePlan> exercises;
  final List<ExercisePlan> primaryPoolExercises;
  final List<ExercisePlan> supportPoolExercises;
  final String logicHint;

  const WorkoutDayPlanModel({
    required this.weekday,
    required this.dayLabel,
    required this.focus,
    required this.type,
    required this.cardioMode,
    required this.cardioSeconds,
    required this.cardioDescription,
    required this.transitionSeconds,
    required this.transitionDescription,
    required this.workSeconds,
    required this.workDescription,
    required this.exercises,
    this.primaryPoolExercises = const [],
    this.supportPoolExercises = const [],
    this.logicHint = '',
  });

  factory WorkoutDayPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkoutDayPlanModel(
      weekday: json['weekday'] as int,
      dayLabel: json['dayLabel'] as String,
      focus: json['focus'] as String,
      type: WorkoutType.values.byName(json['type'] as String),
      cardioMode: CardioMode.values.byName(json['cardioMode'] as String),
      cardioSeconds: json['cardioSeconds'] as int,
      cardioDescription: json['cardioDescription'] as String,
      transitionSeconds: json['transitionSeconds'] as int,
      transitionDescription: json['transitionDescription'] as String,
      workSeconds: json['workSeconds'] as int,
      workDescription: json['workDescription'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map(
            (exerciseJson) =>
                ExercisePlan.fromJson(exerciseJson as Map<String, dynamic>),
          )
          .toList(),
      primaryPoolExercises: (json['primaryPoolExercises'] as List<dynamic>?)
              ?.map(
                (exerciseJson) =>
                    ExercisePlan.fromJson(exerciseJson as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      supportPoolExercises: (json['supportPoolExercises'] as List<dynamic>?)
              ?.map(
                (exerciseJson) =>
                    ExercisePlan.fromJson(exerciseJson as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      logicHint: (json['logicHint'] as String?) ?? '',
    );
  }

  bool get isRestDay => type == WorkoutType.rest;
  bool get isRecoveryDay => type == WorkoutType.recovery;
  bool get hasTransition => transitionSeconds > 0;
}

class WorkoutWeekPlan {
  final List<WorkoutDayPlanModel> days;

  const WorkoutWeekPlan({
    required this.days,
  });

  WorkoutDayPlanModel forDate(DateTime date) {
    return days.firstWhere((day) => day.weekday == date.weekday);
  }

  WorkoutDayPlanModel get todayWorkout {
    return forDate(DateTime.now());
  }
}
