import 'package:flutter/material.dart';
import 'package:forge/models/workout_plan_model.dart';
import 'package:forge/utils/constants/app_assets.dart';
import 'package:forge/utils/widgets/app_header_text.dart';
import 'package:forge/utils/widgets/app_svg_icon.dart';
import 'package:forge/modules/home/bloc/home_bloc.dart';
import 'package:forge/modules/dashboard/widgets/round_log_section_widget.dart';

class HomeDashboardTab extends StatelessWidget {
  final HomeReady state;
  final TextEditingController bodyWeightController;
  final TextEditingController heightController;
  final TextEditingController bodyFatController;
  final TextEditingController sessionNoteController;
  final VoidCallback onSaveBodyMetrics;
  final VoidCallback onSaveSessionNote;
  final VoidCallback onCompleteSession;

  const HomeDashboardTab({
    required this.state,
    required this.bodyWeightController,
    required this.heightController,
    required this.bodyFatController,
    required this.sessionNoteController,
    required this.onSaveBodyMetrics,
    required this.onSaveSessionNote,
    required this.onCompleteSession,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final plan = state.todayPlan;

    if (plan.isRestDay) {
      return _RestDayView(state: state);
    }

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList.list(
            children: [
              _ProtocolCard(plan: plan),
              const SizedBox(height: 16),
              RoundLogSection(state: state),
              const SizedBox(height: 16),
              _WeeklyGoalsCard(state: state),
              const SizedBox(height: 16),
              _CollapsibleBodyMetrics(
                state: state,
                bodyWeightController: bodyWeightController,
                heightController: heightController,
                bodyFatController: bodyFatController,
                onSaveBodyMetrics: onSaveBodyMetrics,
              ),
              const SizedBox(height: 16),
              _CollapsibleSessionNotes(
                sessionNoteController: sessionNoteController,
                onSaveSessionNote: onSaveSessionNote,
              ),
              const SizedBox(height: 16),
              _SessionCompleteCard(
                state: state,
                onCompleteSession: onCompleteSession,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RestDayView extends StatelessWidget {
  final HomeReady state;

  const _RestDayView({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList.list(
            children: [
              Icon(
                Icons.bedtime_outlined,
                size: 64,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 24),
              AppHeaderText(
                'Rest Day',
                level: AppHeaderLevel.page,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Recovery is part of the program. Muscle grows while resting.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ...state.todayPlan.exercises.map(
                (ex) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          ex.name == 'Nutrition'
                              ? Icons.restaurant_outlined
                              : Icons.nightlight_outlined,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.name,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                ex.howTo,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProtocolCard extends StatefulWidget {
  final WorkoutDayPlanModel plan;

  const _ProtocolCard({required this.plan});

  @override
  State<_ProtocolCard> createState() => _ProtocolCardState();
}

class _ProtocolCardState extends State<_ProtocolCard> {
  bool _expanded = true;

  Widget _buildExerciseItem(BuildContext context, ExercisePlan ex) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ex.name,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (ex.repsTarget != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ex.repsTarget!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                  ),
                ),
              ],
              if (ex.durationTarget != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ex.durationTarget!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                        ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            ex.howTo,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Avoid: ${ex.mistake}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.error.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final primaryExercises = plan.primaryPoolExercises;
    final supportExercises = plan.supportPoolExercises;
    final fallbackExercises = plan.exercises;
    final hasPools = primaryExercises.isNotEmpty || supportExercises.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppHeaderText('Protocol'),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ProtocolRow(
                iconAssetName: AppAssets.cardioIcon,
                label: 'Cardio',
                time: '${plan.cardioSeconds}s',
                detail: plan.cardioDescription,
              ),
              if (plan.hasTransition) ...[
                const SizedBox(height: 10),
                _ProtocolRow(
                  iconAssetName: AppAssets.transitionIcon,
                  label: 'Transition',
                  time: '${plan.transitionSeconds}s',
                  detail: plan.transitionDescription,
                ),
              ],
              const SizedBox(height: 10),
              _ProtocolRow(
                iconAssetName: AppAssets.workIcon,
                label: 'Work',
                time: '${plan.workSeconds}s',
                detail: plan.workDescription,
              ),
              if (_expanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (hasPools) ...[
                  if (primaryExercises.isNotEmpty) ...[
                    Text(
                      'Primary Pool',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    ...primaryExercises.map(
                      (ex) => _buildExerciseItem(context, ex),
                    ),
                  ],
                  if (supportExercises.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Support Pool',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    ...supportExercises.map(
                      (ex) => _buildExerciseItem(context, ex),
                    ),
                  ],
                ] else ...[
                  ...fallbackExercises.map(
                    (ex) => _buildExerciseItem(context, ex),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProtocolRow extends StatelessWidget {
  final String iconAssetName;
  final String label;
  final String time;
  final String detail;

  const _ProtocolRow({
    required this.iconAssetName,
    required this.label,
    required this.time,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: AppSvgIcon(
            assetName: iconAssetName,
            size: 20,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label \u2022 $time',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CollapsibleBodyMetrics extends StatefulWidget {
  final HomeReady state;
  final TextEditingController bodyWeightController;
  final TextEditingController heightController;
  final TextEditingController bodyFatController;
  final VoidCallback onSaveBodyMetrics;

  const _CollapsibleBodyMetrics({
    required this.state,
    required this.bodyWeightController,
    required this.heightController,
    required this.bodyFatController,
    required this.onSaveBodyMetrics,
  });

  @override
  State<_CollapsibleBodyMetrics> createState() =>
      _CollapsibleBodyMetricsState();
}

class _CollapsibleBodyMetricsState extends State<_CollapsibleBodyMetrics> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.monitor_weight_outlined, size: 20),
                  const SizedBox(width: 12),
                  const AppHeaderText(
                    'Body Metrics',
                    level: AppHeaderLevel.subsection,
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 16),
                _BodyMetricsForm(
                  state: widget.state,
                  bodyWeightController: widget.bodyWeightController,
                  heightController: widget.heightController,
                  bodyFatController: widget.bodyFatController,
                  onSaveBodyMetrics: widget.onSaveBodyMetrics,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyMetricsForm extends StatelessWidget {
  final HomeReady state;
  final TextEditingController bodyWeightController;
  final TextEditingController heightController;
  final TextEditingController bodyFatController;
  final VoidCallback onSaveBodyMetrics;

  const _BodyMetricsForm({
    required this.state,
    required this.bodyWeightController,
    required this.heightController,
    required this.bodyFatController,
    required this.onSaveBodyMetrics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: bodyWeightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight',
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
            suffixText: '%',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: onSaveBodyMetrics,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save'),
          ),
        ),
      ],
    );
  }
}

class _CollapsibleSessionNotes extends StatefulWidget {
  final TextEditingController sessionNoteController;
  final VoidCallback onSaveSessionNote;

  const _CollapsibleSessionNotes({
    required this.sessionNoteController,
    required this.onSaveSessionNote,
  });

  @override
  State<_CollapsibleSessionNotes> createState() =>
      _CollapsibleSessionNotesState();
}

class _CollapsibleSessionNotesState extends State<_CollapsibleSessionNotes> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.sticky_note_2_outlined, size: 20),
                  const SizedBox(width: 12),
                  const AppHeaderText(
                    'Session Notes',
                    level: AppHeaderLevel.subsection,
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: widget.sessionNoteController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'How did it feel?',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: widget.onSaveSessionNote,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
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

class _WeeklyGoalsCard extends StatelessWidget {
  final HomeReady state;

  const _WeeklyGoalsCard({required this.state});

  @override
  Widget build(BuildContext context) {
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
            const AppHeaderText(
              'This week\'s goals',
            ),
            const SizedBox(height: 12),
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
