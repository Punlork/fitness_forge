import 'package:flutter/material.dart';
import 'package:flutter_base_template/modules/home/bloc/home_bloc.dart';

class HomeTimerTab extends StatelessWidget {
  final HomeReady state;
  final int workSeconds;
  final int restSeconds;
  final int targetRounds;
  final int round;
  final int remainingSeconds;
  final bool isWorkPhase;
  final bool isRunning;
  final ValueChanged<int> onWorkSecondsChanged;
  final ValueChanged<int> onRestSecondsChanged;
  final ValueChanged<int> onTargetRoundsChanged;
  final VoidCallback onToggleStartPause;
  final VoidCallback onReset;
  final VoidCallback onSkipPhase;

  const HomeTimerTab({
    required this.state,
    required this.workSeconds,
    required this.restSeconds,
    required this.targetRounds,
    required this.round,
    required this.remainingSeconds,
    required this.isWorkPhase,
    required this.isRunning,
    required this.onWorkSecondsChanged,
    required this.onRestSecondsChanged,
    required this.onTargetRoundsChanged,
    required this.onToggleStartPause,
    required this.onReset,
    required this.onSkipPhase,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double progress = isWorkPhase
        ? 1 - (remainingSeconds / workSeconds.clamp(1, 999))
        : 1 - (remainingSeconds / restSeconds.clamp(1, 999));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.22),
                        colorScheme.surfaceContainerHighest,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0, 1),
                          strokeWidth: 8,
                          backgroundColor:
                              colorScheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$remainingSeconds',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          Text(
                            isWorkPhase ? 'WORK' : 'REST',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Round $round of $targetRounds',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  isWorkPhase
                      ? 'Push through this work phase.'
                      : 'Recover, breathe, then go again.',
                  style: Theme.of(context).textTheme.bodyMedium,
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
                              : Icons.play_arrow,
                        ),
                        label: Text(isRunning ? 'Pause' : 'Start'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSkipPhase,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Next'),
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tune the timer before you start. Work phases are auto-logged.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StepperTile(
                        label: 'Work',
                        suffix: 'sec',
                        value: workSeconds,
                        onChanged: onWorkSecondsChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StepperTile(
                        label: 'Rest',
                        suffix: 'sec',
                        value: restSeconds,
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
                        onChanged: onTargetRoundsChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _LatestIntervalsCard(state: state),
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

  const _StepperTile({
    required this.label,
    required this.suffix,
    required this.value,
    required this.onChanged,
    this.min = 10,
    this.step = 5,
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
      padding: EdgeInsets.symmetric(vertical: 12),
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
                onPressed: () => onChanged((value - step).clamp(min, 999)),
                icon: const Icon(
                  Icons.remove,
                ),
              ),
              // const SizedBox(width: 6),
              IconButton.filledTonal(
                onPressed: () => onChanged(value + step),
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

class _LatestIntervalsCard extends StatelessWidget {
  final HomeReady state;

  const _LatestIntervalsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent intervals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Your most recent cardio work logged from the timer.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            if (state.intervals.isEmpty)
              const Text('No intervals logged yet.')
            else
              ...state.intervals.reversed.take(6).map(
                    (interval) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
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
                            const Icon(Icons.bolt_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '#${interval.intervalOrder} ${interval.intervalType.toUpperCase()}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Text('${interval.durationSeconds}s'),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
