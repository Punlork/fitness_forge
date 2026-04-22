enum CardioMode {
  steady,
  highIntensity,
  variable,
  easy,
  none,
}

class WorkoutDayPlanModel {
  final int weekday;
  final String dayLabel;
  final String focus;
  final CardioMode cardioMode;
  final String cardioInstruction;
  final List<String> strengthMoves;
  final List<String> targets;
  final List<String> commonMistakes;

  const WorkoutDayPlanModel({
    required this.weekday,
    required this.dayLabel,
    required this.focus,
    required this.cardioMode,
    required this.cardioInstruction,
    required this.strengthMoves,
    required this.targets,
    required this.commonMistakes,
  });
}

class WorkoutWeekPlan {
  static const List<WorkoutDayPlanModel> days = [
    WorkoutDayPlanModel(
      weekday: DateTime.monday,
      dayLabel: 'Mon',
      focus: 'Strength A (Foundation)',
      cardioMode: CardioMode.steady,
      cardioInstruction: '40s basic bounce at steady pace',
      strengthMoves: ['Assisted Negatives', 'Full Push-ups', 'Slow Squats'],
      targets: [
        'Negatives: 3-5 reps, 5s lowering',
        'Push-ups: 8-12 reps, chest to floor',
        'Squats: 15 reps, 3s down / 1s up',
      ],
      commonMistakes: [
        'Negatives: dropping too fast',
        'Push-ups: sagging hips',
        'Squats: shifting weight to toes',
      ],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.tuesday,
      dayLabel: 'Tue',
      focus: 'Cardio HIIT (Fat Burn)',
      cardioMode: CardioMode.highIntensity,
      cardioInstruction: '40s sprint rope pace with high knees',
      strengthMoves: ['Shadow Box', 'Walk in Circles'],
      targets: [
        'Active recovery during 60s block',
        'Keep heart rate steady between intervals',
      ],
      commonMistakes: [
        'Landing on heels while jumping',
        'Skipping shoes and overloading calves',
      ],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.wednesday,
      dayLabel: 'Wed',
      focus: 'Strength B (Definition)',
      cardioMode: CardioMode.steady,
      cardioInstruction: '40s basic bounce at steady pace',
      strengthMoves: [
        'Active Dead Hangs',
        'Incline Diamonds',
        'Walking Lunges'
      ],
      targets: [
        'Hangs: 30s with shoulders pulled down',
        'Diamonds: 8-10 reps',
        'Lunges: 10 reps per leg',
      ],
      commonMistakes: [
        'Hangs: feet touching floor',
        'Diamonds: elbows flaring out',
        'Lunges: front knee passing toes',
      ],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.thursday,
      dayLabel: 'Thu',
      focus: 'Cardio Circuit (Metabolic)',
      cardioMode: CardioMode.variable,
      cardioInstruction: '40s rope with 10s fast / 10s slow pattern',
      strengthMoves: ['Mountain Climbers', 'Burpees', 'Jumping Jacks'],
      targets: [
        'Climbers: drive knees fast',
        'Burpees: 8 reps (jump only, no push-up)',
        'Jacks: hands touch overhead',
      ],
      commonMistakes: [
        'Climbers: hips bouncing too high',
        'Burpees: loud and hard landings',
      ],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.friday,
      dayLabel: 'Fri',
      focus: 'Strength C (Stability)',
      cardioMode: CardioMode.steady,
      cardioInstruction: '40s basic bounce at steady pace',
      strengthMoves: ['Top-of-Bar Holds', 'Wall Sit', 'Plank'],
      targets: [
        'Holds: 5-10s with controlled breathing',
        'Wall sit: 60s at 90 degrees',
        'Plank: 60s in straight line',
      ],
      commonMistakes: [
        'Holds: breath-holding',
        'Wall sit: resting hands on knees',
        'Plank: looking up instead of down',
      ],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.saturday,
      dayLabel: 'Sat',
      focus: 'Recovery (Mobility)',
      cardioMode: CardioMode.easy,
      cardioInstruction: 'Very easy hopping or light rope',
      strengthMoves: ['Calf Stretch', 'Chest Stretch', 'Foot Roll'],
      targets: [
        'Hold each stretch for 30s',
        'Use tennis ball under foot for roll-out',
      ],
      commonMistakes: ['Going too hard on recovery day'],
    ),
    WorkoutDayPlanModel(
      weekday: DateTime.sunday,
      dayLabel: 'Sun',
      focus: 'Rest',
      cardioMode: CardioMode.none,
      cardioInstruction: 'No cardio',
      strengthMoves: ['Nutrition', 'Sleep'],
      targets: ['High protein focus', 'Aim for 8+ hours sleep'],
      commonMistakes: ['Skipping rest day'],
    ),
  ];

  static WorkoutDayPlanModel forDate(DateTime date) {
    return days.firstWhere((day) => day.weekday == date.weekday);
  }
}
