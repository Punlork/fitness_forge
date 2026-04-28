import 'package:flutter/material.dart';
import 'package:forge/services/workout_timer_notification_service.dart';

class HomeTimerTab extends StatelessWidget {
  final int workSeconds;
  final int restSeconds;
  final int targetRounds;
  final int round;
  final int remainingSeconds;
  final bool isWorkPhase;
  final bool isRunning;
  final bool isPhaseCompleteAwaitingNext;
  final ValueChanged<int> onWorkSecondsChanged;
  final ValueChanged<int> onRestSecondsChanged;
  final ValueChanged<int> onTargetRoundsChanged;
  final VoidCallback onToggleStartPause;
  final VoidCallback onReset;
  final VoidCallback onSkipPhase;
  final VoidCallback onRequestNotificationPermissions;
  final VoidCallback onDebugTestAlert;

  const HomeTimerTab({
    required this.workSeconds,
    required this.restSeconds,
    required this.targetRounds,
    required this.round,
    required this.remainingSeconds,
    required this.isWorkPhase,
    required this.isRunning,
    required this.isPhaseCompleteAwaitingNext,
    required this.onWorkSecondsChanged,
    required this.onRestSecondsChanged,
    required this.onTargetRoundsChanged,
    required this.onToggleStartPause,
    required this.onReset,
    required this.onSkipPhase,
    required this.onRequestNotificationPermissions,
    required this.onDebugTestAlert,
    super.key,
  });

  String _formatTimer(int totalSeconds) {
    final int safeSeconds = totalSeconds.clamp(0, 5999);
    final int minutes = safeSeconds ~/ 60;
    final int seconds = safeSeconds % 60;
    final String minuteText = minutes.toString().padLeft(2, '0');
    final String secondText = seconds.toString().padLeft(2, '0');
    return '$minuteText:$secondText';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final double progress = isWorkPhase
        ? 1 - (remainingSeconds / workSeconds.clamp(1, 999))
        : 1 - (remainingSeconds / restSeconds.clamp(1, 999));
    final bool isWaitingManualAction = isPhaseCompleteAwaitingNext;
    final bool canEditSetup = !isRunning;
    final bool isWorkoutComplete = !isRunning &&
        !isWaitingManualAction &&
        isWorkPhase &&
        round >= targetRounds;
    final String displayTime = _formatTimer(remainingSeconds);
    final Color phaseColor =
        isWorkPhase ? colorScheme.primary : colorScheme.tertiary;

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList.list(
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            colors: [
                              phaseColor.withValues(alpha: 0.18),
                              colorScheme.surfaceContainerHighest,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          border: Border.all(
                            color: phaseColor.withValues(alpha: 0.35),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: phaseColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    isWorkPhase ? 'WORK' : 'REST',
                                    style: textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: phaseColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Round $round/$targetRounds',
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                displayTime,
                                style: textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.5,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                minHeight: 10,
                                value: progress.clamp(0, 1),
                                backgroundColor: colorScheme.surface,
                                color: phaseColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        isWorkoutComplete
                            ? 'Workout complete. Reset when you are ready.'
                            : isWaitingManualAction
                                ? 'Phase switched. Tap Start when ready.'
                                : isWorkPhase
                                    ? 'Push through this work phase.'
                                    : 'Recover, breathe, then go again.',
                        style: textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: onToggleStartPause,
                              icon: Icon(
                                isRunning
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                              ),
                              label: Text(isRunning ? 'Pause' : 'Start'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isWorkoutComplete ? null : onSkipPhase,
                              icon: const Icon(Icons.skip_next),
                              label: const Text('Skip'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: onReset,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reset timer'),
                        ),
                      ),
                      if (WorkoutTimerNotificationService
                          .instance.shouldShowRequest) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: onRequestNotificationPermissions,
                            icon:
                                const Icon(Icons.notifications_active_outlined),
                            label: const Text('Enable timer alerts'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: onDebugTestAlert,
                            icon: const Icon(Icons.bug_report_outlined),
                            label: const Text('Test alert now'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interval setup',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose presets or customize each interval manually.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _PresetSecondsSection(
                        title: 'Work presets',
                        selectedValue: workSeconds,
                        presetValues: const [30, 45, 60, 90],
                        enabled: canEditSetup,
                        onSelected: onWorkSecondsChanged,
                      ),
                      const SizedBox(height: 12),
                      _PresetSecondsSection(
                        title: 'Rest presets',
                        selectedValue: restSeconds,
                        presetValues: const [15, 30, 45, 60],
                        enabled: canEditSetup,
                        onSelected: onRestSecondsChanged,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StepperTile(
                              label: 'Work',
                              suffix: 'sec',
                              value: workSeconds,
                              enabled: canEditSetup,
                              onChanged: onWorkSecondsChanged,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StepperTile(
                              label: 'Rest',
                              suffix: 'sec',
                              value: restSeconds,
                              enabled: canEditSetup,
                              onChanged: onRestSecondsChanged,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StepperTile(
                              label: 'Rounds',
                              suffix: 'x',
                              value: targetRounds,
                              min: 1,
                              step: 1,
                              enabled: canEditSetup,
                              onChanged: onTargetRoundsChanged,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _StepperTile extends StatelessWidget {
  final String label;
  final String suffix;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int step;
  final bool enabled;

  const _StepperTile({
    required this.label,
    required this.suffix,
    required this.value,
    required this.onChanged,
    this.min = 10,
    this.step = 5,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '$value$suffix',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: enabled
                    ? () => onChanged((value - step).clamp(min, 999))
                    : null,
                icon: const Icon(
                  Icons.remove,
                ),
              ),
              IconButton.filledTonal(
                onPressed: enabled ? () => onChanged(value + step) : null,
                icon: const Icon(
                  Icons.add,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetSecondsSection extends StatelessWidget {
  final String title;
  final int selectedValue;
  final List<int> presetValues;
  final ValueChanged<int> onSelected;
  final bool enabled;

  const _PresetSecondsSection({
    required this.title,
    required this.selectedValue,
    required this.presetValues,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...presetValues.map(
              (preset) => ChoiceChip(
                label: Text('${preset}s'),
                selected: selectedValue == preset,
                onSelected: enabled ? (_) => onSelected(preset) : null,
              ),
            ),
            ChoiceChip(
              label: const Text('Custom'),
              selected: !presetValues.contains(selectedValue),
              onSelected: (_) {},
            ),
          ],
        ),
      ],
    );
  }
}
