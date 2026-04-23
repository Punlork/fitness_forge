import 'package:flutter/material.dart';
import 'package:flutter_base_template/modules/home/bloc/home_bloc.dart';

class TopSessionHeader extends StatelessWidget {
  final HomeReady state;

  const TopSessionHeader({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.18),
            colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
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
                              '${state.todayPlan.dayLabel} \u2022 ${state.todayPlan.focus}',
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.todayPlan.cardioInstruction,
                              style: textTheme.bodyMedium?.copyWith(
                                color: textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CompletionRing(score: state.completionScore),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      HeaderStatChip(
                        icon: Icons.fitness_center,
                        label: 'Sets',
                        value: '${state.strengthSets.length}',
                      ),
                      HeaderStatChip(
                        icon: Icons.timer_outlined,
                        label: 'Cardio',
                        value: '${state.cardioSeconds}s',
                      ),
                      HeaderStatChip(
                        icon: Icons.local_fire_department_outlined,
                        label: 'Volume',
                        value: state.totalStrengthVolume.toStringAsFixed(0),
                      ),
                      if (state.restSecondsRemaining > 0)
                        HeaderStatChip(
                          icon: Icons.hourglass_bottom,
                          label: 'Rest',
                          value: '${state.restSecondsRemaining}s',
                          emphasized: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompletionRing extends StatelessWidget {
  final int score;

  const CompletionRing({required this.score, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double progress = (score / 100).clamp(0, 1).toDouble();

    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 74,
            height: 74,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 7,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'done',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasized;

  const HeaderStatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasized = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: emphasized
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text('$label: ', style: Theme.of(context).textTheme.labelLarge),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
