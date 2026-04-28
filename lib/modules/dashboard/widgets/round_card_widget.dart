import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/utils/constants/app_assets.dart';
import 'package:forge/utils/widgets/app_svg_icon.dart';
import 'package:forge/models/round_model.dart';
import 'package:forge/models/strength_set_model.dart';
import 'package:forge/models/workout_plan_model.dart';
import 'package:forge/modules/home/bloc/home_bloc.dart';

import 'rep_log_form_widget.dart';
import 'time_log_form_widget.dart';

class RoundCard extends StatefulWidget {
  final RoundData round;
  final HomeReady state;

  const RoundCard({
    super.key,
    required this.round,
    required this.state,
  });

  @override
  State<RoundCard> createState() => _RoundCardState();
}

class _RoundCardState extends State<RoundCard> {
  bool _useSupportPool = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final plan = widget.state.todayPlan;
    final selectedExercises =
        _useSupportPool && plan.supportPoolExercises.isNotEmpty
            ? plan.supportPoolExercises
            : (plan.primaryPoolExercises.isNotEmpty
                ? plan.primaryPoolExercises
                : plan.exercises);

    final allExercises = <ExercisePlan>{
      ...plan.primaryPoolExercises,
      ...plan.supportPoolExercises,
      ...plan.exercises,
    }.toList(growable: false);

    final hasAnyExerciseLog = allExercises.any(
      (ex) => widget.round.workLogs.any((log) => log.exerciseName == ex.name),
    );

    final isRoundComplete = widget.round.hasCardio && hasAnyExerciseLog;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RoundCardHeader(
              round: widget.round,
              isRoundComplete: isRoundComplete,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 6),
            if (plan.supportPoolExercises.isNotEmpty) ...[
              _PoolSelector(
                useSupportPool: _useSupportPool,
                onChanged: (useSupportPool) {
                  setState(() => _useSupportPool = useSupportPool);
                },
              ),
              const SizedBox(height: 6),
            ],
            Row(
              children: [
                Expanded(
                  child: _RoundCheckTile(
                    iconAssetName: AppAssets.cardioIcon,
                    label: 'Cardio',
                    checked: widget.round.hasCardio,
                    onTap: widget.round.hasCardio
                        ? null
                        : () {
                            context.read<HomeBloc>().add(
                                  LogCardioCheckEvent(
                                    roundNumber: widget.round.roundNumber,
                                  ),
                                );
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...selectedExercises.map((ex) {
              final logs = widget.round.workLogs
                  .where((s) => s.exerciseName == ex.name)
                  .toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _ExerciseLogTile(
                  exercise: ex,
                  logs: logs,
                  roundNumber: widget.round.roundNumber,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PoolSelector extends StatelessWidget {
  final bool useSupportPool;
  final ValueChanged<bool> onChanged;

  const _PoolSelector({
    required this.useSupportPool,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          label: Text('Primary'),
        ),
        ButtonSegment(
          value: true,
          label: Text('Support'),
        ),
      ],
      selected: <bool>{useSupportPool},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}

class _RoundCardHeader extends StatelessWidget {
  final RoundData round;
  final bool isRoundComplete;
  final ColorScheme colorScheme;

  const _RoundCardHeader({
    required this.round,
    required this.isRoundComplete,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Round ${round.roundNumber}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const Spacer(),
        if (isRoundComplete)
          AppSvgIcon(
            assetName: AppAssets.checkCircleIcon,
            color: colorScheme.primary,
            size: 20,
          ),
        const SizedBox(width: 10),
        _RoundDeleteButton(
          roundNumber: round.roundNumber,
        ),
      ],
    );
  }
}

class _RoundDeleteButton extends StatelessWidget {
  final int roundNumber;

  const _RoundDeleteButton({
    required this.roundNumber,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: 'Delete round',
      padding: EdgeInsets.zero,
      icon: AppSvgIcon(
        assetName: AppAssets.deleteIcon,
        color: colorScheme.error,
        size: 22,
      ),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Round?'),
            content: Text(
              'Are you sure you want to delete Round $roundNumber? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          context
              .read<HomeBloc>()
              .add(RemoveRoundEvent(roundNumber: roundNumber));
        }
      },
    );
  }
}

class _RoundCheckTile extends StatelessWidget {
  final String iconAssetName;
  final String label;
  final bool checked;
  final VoidCallback? onTap;

  const _RoundCheckTile({
    required this.iconAssetName,
    required this.label,
    required this.checked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: checked
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            AppSvgIcon(
              assetName: iconAssetName,
              size: 18,
              color: checked
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: checked ? colorScheme.onPrimaryContainer : null,
                  ),
            ),
            const Spacer(),
            AppSvgIcon(
              assetName: checked
                  ? AppAssets.checkCircleIcon
                  : AppAssets.circleOutlineIcon,
              size: 20,
              color: checked ? colorScheme.primary : colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseLogTile extends StatelessWidget {
  final ExercisePlan exercise;
  final List<StrengthSetModel> logs;
  final int roundNumber;

  const _ExerciseLogTile({
    required this.exercise,
    required this.logs,
    required this.roundNumber,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isTimed = exercise.durationTarget != null;

    String logValues;
    if (isTimed) {
      // Show durations with "s"
      logValues = logs.map((l) => '${l.reps}s').join(', ');
    } else {
      // Show reps
      logValues = logs.map((l) => '${l.reps}').join(', ');
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    if (logs.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        logValues,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                      ),
                    ],
                  ],
                ),
              ),
              _LogButton(
                exercise: exercise,
                roundNumber: roundNumber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogButton extends StatelessWidget {
  final ExercisePlan exercise;
  final int roundNumber;

  const _LogButton({
    required this.exercise,
    required this.roundNumber,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: () => _showLogSheet(context),
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(
            assetName: AppAssets.logIcon,
            size: 14,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'Log',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  void _showLogSheet(BuildContext context) {
    final isTimed = exercise.durationTarget != null;
    final targetReps = int.tryParse(
      exercise.repsTarget?.split('-').first ?? '',
    );

    final targetDuration = int.tryParse(
      exercise.durationTarget?.replaceAll('s', '') ?? '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Log ${exercise.name}',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                exercise.howTo,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(ctx)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.72),
                    ),
              ),
              const SizedBox(height: 20),
              if (isTimed) ...[
                TimedLogForm(
                  targetDuration: targetDuration ?? 60,
                  onLog: (duration) {
                    context.read<HomeBloc>().add(
                          LogTimedWorkEvent(
                            exerciseId: exercise.id,
                            exerciseName: exercise.name,
                            durationSeconds: duration,
                            roundNumber: roundNumber,
                          ),
                        );
                    Navigator.of(ctx).pop();
                  },
                ),
              ] else ...[
                RepLogForm(
                  targetReps: targetReps ?? 10,
                  onLog: (reps) {
                    context.read<HomeBloc>().add(
                          LogWorkSetEvent(
                            exerciseId: exercise.id,
                            exerciseName: exercise.name,
                            reps: reps,
                            roundNumber: roundNumber,
                          ),
                        );
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
