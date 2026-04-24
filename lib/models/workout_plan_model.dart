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

class ExercisePlan {
  final String name;
  final String? repsTarget;
  final String? durationTarget;
  final String howTo;
  final String commonMistake;

  const ExercisePlan({
    required this.name,
    this.repsTarget,
    this.durationTarget,
    required this.howTo,
    required this.commonMistake,
  });
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
  });

  bool get isRestDay => type == WorkoutType.rest;
  bool get isRecoveryDay => type == WorkoutType.recovery;
  bool get hasTransition => transitionSeconds > 0;
}

class WorkoutWeekPlan {
  static const List<WorkoutDayPlanModel> days = [
    WorkoutDayPlanModel(
      weekday: DateTime.monday,
      dayLabel: 'Mon',
      focus: 'Strength A (Foundation)',
      type: WorkoutType.strength,
      cardioMode: CardioMode.steady,
      cardioSeconds: 40,
      cardioDescription: 'Steady: Basic bounce',
      transitionSeconds: 20,
      transitionDescription: 'Deep Breaths',
      workSeconds: 60,
      workDescription: 'Push-ups / Negatives',
      exercises: [
        ExercisePlan(
          name: 'Push-ups',
          repsTarget: '8-12',
          howTo: 'Elbows at 45°. Chest to floor.',
          commonMistake: 'Sagging hips',
        ),
        ExercisePlan(
          name: 'Negatives',
          repsTarget: '3-5',
          howTo: '5s lowering. Use a chair to help you up.',
          commonMistake: 'Dropping too fast',
        ),
      ],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.tuesday,
      dayLabel: 'Tue',
      focus: 'Cardio HIIT (Fat Burn)',
      type: WorkoutType.hiit,
      cardioMode: CardioMode.highIntensity,
      cardioSeconds: 40,
      cardioDescription: 'Sprint Speed!',
      transitionSeconds: 20,
      transitionDescription: 'Slow Walk',
      workSeconds: 60,
      workDescription: 'Active Recovery',
      exercises: [
        ExercisePlan(
          name: 'High Knees',
          repsTarget: null,
          durationTarget: '60s',
          howTo: 'Bring knees to waist height while jumping.',
          commonMistake: 'Landing on heels; stay on balls of feet.',
        ),
      ],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.wednesday,
      dayLabel: 'Wed',
      focus: 'Strength B (Definition)',
      type: WorkoutType.strength,
      cardioMode: CardioMode.steady,
      cardioSeconds: 40,
      cardioDescription: 'Steady: Basic bounce',
      transitionSeconds: 20,
      transitionDescription: 'Deep Breaths',
      workSeconds: 60,
      workDescription: 'Hangs / Diamonds',
      exercises: [
        ExercisePlan(
          name: 'Active Dead Hangs',
          durationTarget: '30s',
          howTo: 'Active shoulders (pull down). Just hang.',
          commonMistake: 'Feet touching floor (bend knees!)',
        ),
        ExercisePlan(
          name: 'Incline Diamonds',
          repsTarget: '8-10',
          howTo: 'Hands on a table/bed. Hands touch.',
          commonMistake: 'Flaring elbows out wide',
        ),
        ExercisePlan(
          name: 'Walking Lunges',
          repsTarget: '10/leg',
          howTo: 'Large steps. Drive through front heel.',
          commonMistake: 'Front knee passing toes',
        ),
      ],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.thursday,
      dayLabel: 'Thu',
      focus: 'Cardio Circuit (Metabolic)',
      type: WorkoutType.circuit,
      cardioMode: CardioMode.variable,
      cardioSeconds: 40,
      cardioDescription: 'Variable: 10s Fast / 10s Slow',
      transitionSeconds: 20,
      transitionDescription: 'Breathe',
      workSeconds: 60,
      workDescription: 'Circuit Moves',
      exercises: [
        ExercisePlan(
          name: 'Mountain Climbers',
          repsTarget: null,
          durationTarget: '60s',
          howTo: 'Drive knees fast. Keep hips low.',
          commonMistake: 'Bouncing your butt up',
        ),
        ExercisePlan(
          name: 'Burpees',
          repsTarget: '8',
          howTo: 'No push-up; just jump. Land soft like a cat.',
          commonMistake: 'Landing loudly',
        ),
        ExercisePlan(
          name: 'Jumping Jacks',
          repsTarget: null,
          durationTarget: '60s',
          howTo: 'Hands touch overhead. Light on feet.',
          commonMistake: 'Heavy landings',
        ),
      ],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.friday,
      dayLabel: 'Fri',
      focus: 'Strength C (Stability)',
      type: WorkoutType.holds,
      cardioMode: CardioMode.steady,
      cardioSeconds: 40,
      cardioDescription: 'Steady: Basic bounce',
      transitionSeconds: 20,
      transitionDescription: 'Deep Breaths',
      workSeconds: 60,
      workDescription: 'Holds / Squats',
      exercises: [
        ExercisePlan(
          name: 'Top-of-Bar Holds',
          durationTarget: '5-10s',
          howTo: 'Chin over bar. Squeeze! Keep breathing.',
          commonMistake: 'Holding breath',
        ),
        ExercisePlan(
          name: 'Wall Sit',
          durationTarget: '60s',
          howTo: 'Back flat. Legs at 90°.',
          commonMistake: 'Resting hands on knees',
        ),
        ExercisePlan(
          name: 'Plank',
          durationTarget: '60s',
          howTo: 'Straight line head-to-heels. Squeeze glutes & core.',
          commonMistake: 'Looking up (look at floor)',
        ),
      ],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.saturday,
      dayLabel: 'Sat',
      focus: 'Recovery (Mobility)',
      type: WorkoutType.recovery,
      cardioMode: CardioMode.easy,
      cardioSeconds: 40,
      cardioDescription: 'Very Easy Hopping',
      transitionSeconds: 0,
      transitionDescription: '',
      workSeconds: 0,
      workDescription: 'Stretching',
      exercises: [
        ExercisePlan(
          name: 'Chest Stretch',
          durationTarget: '30s',
          howTo: 'Hold at doorway. Feel chest open.',
          commonMistake: 'Going too hard. Today is for healing.',
        ),
        ExercisePlan(
          name: 'Calf Stretch',
          durationTarget: '30s',
          howTo: 'Against wall. Back heel down.',
          commonMistake: 'Bouncing the stretch',
        ),
        ExercisePlan(
          name: 'Foot Roll',
          durationTarget: '60s',
          howTo: 'Use tennis ball under foot arches.',
          commonMistake: 'Pressing too hard',
        ),
      ],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.sunday,
      dayLabel: 'Sun',
      focus: 'Rest',
      type: WorkoutType.rest,
      cardioMode: CardioMode.none,
      cardioSeconds: 0,
      cardioDescription: 'None',
      transitionSeconds: 0,
      transitionDescription: '',
      workSeconds: 0,
      workDescription: 'System Rest',
      exercises: [
        ExercisePlan(
          name: 'Nutrition',
          howTo: 'High protein focus.',
          commonMistake: 'Skipping rest. Muscle grows while resting!',
        ),
        ExercisePlan(
          name: 'Sleep',
          howTo: 'Aim for 8+ hours.',
          commonMistake: 'Staying up late on rest day',
        ),
      ],
    ),
  ];

  static WorkoutDayPlanModel forDate(DateTime date) {
    return days.firstWhere((day) => day.weekday == date.weekday);
  }

  static WorkoutDayPlanModel get todayWorkout {
    return forDate(DateTime.now());
  }
}
