import 'package:flutter/material.dart';
import 'package:flutter_base_template/models/strength_set_model.dart';
import 'package:flutter_base_template/models/workout_plan_model.dart';
import 'package:flutter_base_template/modules/home/bloc/home_bloc.dart';

class HomeTodayTab extends StatelessWidget {
  final HomeReady state;
  final TextEditingController exerciseController;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final TextEditingController bodyWeightController;
  final TextEditingController heightController;
  final TextEditingController bodyFatController;
  final TextEditingController sessionNoteController;
  final StrengthLoadType selectedLoadType;
  final VoidCallback onSubmitStrengthSet;
  final ValueChanged<String> onSelectStrengthMove;
  final VoidCallback onSaveBodyMetrics;
  final VoidCallback onSaveSessionNote;
  final VoidCallback onCompleteSession;
  final ValueChanged<StrengthLoadType> onLoadTypeChanged;

  const HomeTodayTab({
    required this.state,
    required this.exerciseController,
    required this.weightController,
    required this.repsController,
    required this.bodyWeightController,
    required this.heightController,
    required this.bodyFatController,
    required this.sessionNoteController,
    required this.selectedLoadType,
    required this.onSubmitStrengthSet,
    required this.onSelectStrengthMove,
    required this.onSaveBodyMetrics,
    required this.onSaveSessionNote,
    required this.onCompleteSession,
    required this.onLoadTypeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList.list(children: [
        _SectionCard(
          title: 'Today\'s blueprint',
          subtitle: 'What to focus on and what to avoid during this session.',
          child: _TodayBlueprint(state: state),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Weekly rhythm',
          subtitle: 'See where today fits into the full training week.',
          child: _WeeklyPlanPreview(state: state),
        ),
        const SizedBox(height: 16),
        _WeeklyGoalsCard(state: state),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Quick strength log',
          subtitle: 'Record your current set without leaving the workout flow.',
          child: _StrengthSetQuickEntry(
            state: state,
            exerciseController: exerciseController,
            weightController: weightController,
            repsController: repsController,
            selectedLoadType: selectedLoadType,
            onSubmitStrengthSet: onSubmitStrengthSet,
            onSelectStrengthMove: onSelectStrengthMove,
            onLoadTypeChanged: onLoadTypeChanged,
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Body metrics',
          subtitle: 'Track the numbers that matter between sessions.',
          child: _BodyMetricsCard(
            state: state,
            bodyWeightController: bodyWeightController,
            heightController: heightController,
            bodyFatController: bodyFatController,
            onSaveBodyMetrics: onSaveBodyMetrics,
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Session notes',
          subtitle: 'Capture context that numbers cannot explain.',
          child: _SessionNotesCard(
            sessionNoteController: sessionNoteController,
            onSaveSessionNote: onSaveSessionNote,
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Finish session',
          subtitle: 'Wrap today only after all planned work is completed.',
          child: _SessionCompleteCard(
            state: state,
            onCompleteSession: onCompleteSession,
          ),
        ),
      ]),
    ),
  ]);
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _StrengthSetQuickEntry extends StatelessWidget {
  final HomeReady state;
  final TextEditingController exerciseController;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final StrengthLoadType selectedLoadType;
  final VoidCallback onSubmitStrengthSet;
  final ValueChanged<String> onSelectStrengthMove;
  final ValueChanged<StrengthLoadType> onLoadTypeChanged;

  const _StrengthSetQuickEntry({
    required this.state,
    required this.exerciseController,
    required this.weightController,
    required this.repsController,
    required this.selectedLoadType,
    required this.onSubmitStrengthSet,
    required this.onSelectStrengthMove,
    required this.onLoadTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.todayPlan.strengthMoves
              .map(
                (move) => ActionChip(
                  avatar: const Icon(Icons.flash_on_outlined, size: 18),
                  label: Text(move),
                  onPressed: () => onSelectStrengthMove(move),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: exerciseController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Exercise',
            hintText: 'Pull-up, squat, push-up',
            prefixIcon: Icon(Icons.fitness_center),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<StrengthLoadType>(
          initialValue: selectedLoadType,
          decoration: const InputDecoration(
            labelText: 'Load type',
            prefixIcon: Icon(Icons.tune),
          ),
          items: const [
            DropdownMenuItem(
              value: StrengthLoadType.bodyweight,
              child: Text('Bodyweight'),
            ),
            DropdownMenuItem(
              value: StrengthLoadType.external,
              child: Text('External load'),
            ),
            DropdownMenuItem(
              value: StrengthLoadType.assisted,
              child: Text('Assisted'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onLoadTypeChanged(value);
            }
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: weightController,
                enabled: selectedLoadType != StrengthLoadType.bodyweight,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: selectedLoadType == StrengthLoadType.assisted
                      ? 'Assistance (kg)'
                      : 'Load (kg)',
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  prefixIcon: Icon(Icons.repeat),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onSubmitStrengthSet,
            icon: const Icon(Icons.add_task),
            label: const Text('Save set and start rest'),
          ),
        ),
        if (state.strengthSets.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Latest sets',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ...state.strengthSets.take(3).map(
                (set) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LogTile(
                    icon: Icons.fitness_center,
                    title: set.exerciseName,
                    subtitle: _formatStrengthSet(set),
                  ),
                ),
              ),
        ],
      ],
    );
  }

  String _formatStrengthSet(StrengthSetModel set) {
    if (set.loadType == StrengthLoadType.bodyweight || set.weight <= 0) {
      return '${set.reps} reps • bodyweight';
    }
    if (set.loadType == StrengthLoadType.assisted) {
      return '${set.reps} reps • ${set.weight.toStringAsFixed(1)} kg assistance';
    }
    return '${set.reps} reps • ${set.weight.toStringAsFixed(1)} kg';
  }
}

class _TodayBlueprint extends StatelessWidget {
  final HomeReady state;

  const _TodayBlueprint({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabelBlock(
          label: 'Targets',
          items: state.todayPlan.targets,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 14),
        _LabelBlock(
          label: 'Avoid',
          items: state.todayPlan.commonMistakes,
          icon: Icons.report_gmailerrorred_outlined,
        ),
      ],
    );
  }
}

class _LabelBlock extends StatelessWidget {
  final String label;
  final List<String> items;
  final IconData icon;

  const _LabelBlock({
    required this.label,
    required this.items,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _BulletLine(text: item),
          ),
        ),
      ],
    );
  }
}

class _BodyMetricsCard extends StatelessWidget {
  final HomeReady state;
  final TextEditingController bodyWeightController;
  final TextEditingController heightController;
  final TextEditingController bodyFatController;
  final VoidCallback onSaveBodyMetrics;

  const _BodyMetricsCard({
    required this.state,
    required this.bodyWeightController,
    required this.heightController,
    required this.bodyFatController,
    required this.onSaveBodyMetrics,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = state.latestBodyMetrics;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (metrics != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Latest: ${metrics.weightKg.toStringAsFixed(1)} kg, ${metrics.heightCm.toStringAsFixed(0)} cm, ${metrics.bodyFatPercent.toStringAsFixed(1)}% fat, BMI ${metrics.bmi.toStringAsFixed(1)}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: bodyWeightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                  suffixText: 'kg',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: heightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Height',
                  prefixIcon: Icon(Icons.height),
                  suffixText: 'cm',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: bodyFatController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Body fat',
            prefixIcon: Icon(Icons.percent),
            suffixText: '%',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: onSaveBodyMetrics,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save body metrics'),
          ),
        ),
      ],
    );
  }
}

class _SessionCompleteCard extends StatelessWidget {
  final HomeReady state;
  final VoidCallback onCompleteSession;

  const _SessionCompleteCard({
    required this.state,
    required this.onCompleteSession,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: state.session.workoutCompleted
            ? Theme.of(context)
                .colorScheme
                .secondaryContainer
                .withValues(alpha: 0.5)
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            state.session.workoutCompleted
                ? Icons.verified_outlined
                : Icons.flag_outlined,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.session.workoutCompleted
                  ? 'Session marked complete. Nice work.'
                  : 'Mark the session complete once all work is done.',
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed:
                state.session.workoutCompleted ? null : onCompleteSession,
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}

class _SessionNotesCard extends StatelessWidget {
  final TextEditingController sessionNoteController;
  final VoidCallback onSaveSessionNote;

  const _SessionNotesCard({
    required this.sessionNoteController,
    required this.onSaveSessionNote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: sessionNoteController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Felt tired, slept 5 hours, elbows felt better...',
            // prefixIcon: Icon(Icons.sticky_note_2_outlined),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: onSaveSessionNote,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save session note'),
          ),
        ),
      ],
    );
  }
}

class _WeeklyPlanPreview extends StatelessWidget {
  final HomeReady state;

  const _WeeklyPlanPreview({required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final day = WorkoutWeekPlan.days[index];
          final bool isToday = day.weekday == DateTime.now().weekday;
          return Container(
            width: 150,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isToday
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.dayLabel,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    day.focus,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: WorkoutWeekPlan.days.length,
      ),
    );
  }
}

class _WeeklyGoalsCard extends StatelessWidget {
  final HomeReady state;

  const _WeeklyGoalsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final volumeProgress = (state.weeklyVolumeGoal <= 0
            ? 0
            : state.currentWeekVolume / state.weeklyVolumeGoal)
        .clamp(0, 1)
        .toDouble();
    final cardioProgress = (state.weeklyCardioSessionsGoal <= 0
            ? 0
            : state.currentWeekCardioSessions / state.weeklyCardioSessionsGoal)
        .clamp(0, 1)
        .toDouble();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This week\'s goals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Auto targets based on your recent performance.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
            ),
            const SizedBox(height: 16),
            _GoalProgressRow(
              title: 'Strength volume',
              progress: volumeProgress,
              subtitle:
                  '${state.currentWeekVolume.toStringAsFixed(0)} / ${state.weeklyVolumeGoal.toStringAsFixed(0)} kg',
            ),
            const SizedBox(height: 12),
            _GoalProgressRow(
              title: 'Cardio sessions',
              progress: cardioProgress,
              subtitle:
                  '${state.currentWeekCardioSessions} / ${state.weeklyCardioSessionsGoal} sessions',
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalProgressRow extends StatelessWidget {
  final String title;
  final double progress;
  final String subtitle;

  const _GoalProgressRow({
    required this.title,
    required this.progress,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;

  const _BulletLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _LogTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
