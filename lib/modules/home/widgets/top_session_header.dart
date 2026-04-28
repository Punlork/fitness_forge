import 'package:flutter/material.dart';
import 'package:forge/modules/home/bloc/home_bloc.dart';
import 'package:forge/utils/constants/app_assets.dart';
import 'package:forge/utils/widgets/app_header_text.dart';
import 'package:forge/utils/widgets/app_svg_icon.dart';

class TopSessionHeader extends StatelessWidget {
  final HomeReady state;

  const TopSessionHeader({
    required this.state,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
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
            AppHeaderText(
              '${state.todayPlan.dayLabel} • ${state.todayPlan.focus}',
              level: AppHeaderLevel.page,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              '${state.todayPlan.cardioSeconds}s ${state.todayPlan.cardioMode.name} \u2192 ${state.todayPlan.workSeconds}s ${state.todayPlan.workDescription}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.15,
                height: 1.25,
                color: colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            const Spacer(),
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeaderStatChip(
                  iconAssetName: AppAssets.roundsIcon,
                  label: 'Rounds',
                  value: '${state.computedRound}',
                ),
                HeaderStatChip(
                  iconAssetName: AppAssets.cardioIcon,
                  label: 'Cardio',
                  value: _formatDuration(state.cardioSeconds),
                ),
                HeaderStatChip(
                  iconAssetName: AppAssets.volumeIcon,
                  label: 'Volume',
                  value: state.totalStrengthVolume.toStringAsFixed(0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 60) return '${totalSeconds}s';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (seconds == 0) return '${minutes}m';
    return '${minutes}m ${seconds}s';
  }
}

class HeaderStatChip extends StatelessWidget {
  final String iconAssetName;
  final String label;
  final String value;
  final bool emphasized;

  const HeaderStatChip({
    required this.iconAssetName,
    required this.label,
    required this.value,
    this.emphasized = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final baseForeground =
        emphasized ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    final chipBackground = emphasized
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.72);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: chipBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: baseForeground.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: baseForeground.withValues(alpha: emphasized ? 0.16 : 0.11),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: AppSvgIcon(
                assetName: iconAssetName,
                size: 14,
                color: baseForeground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: baseForeground,
                  letterSpacing: -0.1,
                  height: 1.0,
                ),
              ),
              Text(
                label.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: baseForeground.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
