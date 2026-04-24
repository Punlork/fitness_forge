import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:forge/models/strength_set_model.dart';
import 'package:forge/models/workout_history_entry_model.dart';
import 'package:forge/modules/home/bloc/home_bloc.dart';

class HomeProgressTab extends StatefulWidget {
  final HomeReady state;

  const HomeProgressTab({
    required this.state,
    super.key,
  });

  @override
  State<HomeProgressTab> createState() => _HomeProgressTabState();
}

class _HomeProgressTabState extends State<HomeProgressTab> {
  DateTime? _selectedHistoryDate;

  @override
  void didUpdateWidget(covariant HomeProgressTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.sessionHistory.isEmpty) {
      _selectedHistoryDate = null;
      return;
    }
    _selectedHistoryDate ??= widget.state.sessionHistory.first.sessionDate;
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.state.progressPoints;
    final history = widget.state.sessionHistory;
    _selectedHistoryDate ??=
        history.isNotEmpty ? history.first.sessionDate : null;
    final selectedEntries = _selectedHistoryDate == null
        ? const <WorkoutHistoryEntryModel>[]
        : history
            .where(
              (entry) => _isSameDay(entry.sessionDate, _selectedHistoryDate!),
            )
            .toList();

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList.list(children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    title: '14 day volume',
                    value: points
                        .fold<double>(
                            0, (sum, point) => sum + point.strengthVolume)
                        .toStringAsFixed(0),
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryTile(
                    title: '14 day cardio',
                    value:
                        '${points.fold<int>(0, (sum, point) => sum + point.cardioSeconds)}s',
                    icon: Icons.timer_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InsightCard(message: widget.state.primaryInsight),
            const SizedBox(height: 16),
            _GoalsCard(
              currentWeekVolume: widget.state.currentWeekVolume,
              weeklyVolumeGoal: widget.state.weeklyVolumeGoal,
              currentWeekCardioSessions: widget.state.currentWeekCardioSessions,
              weeklyCardioSessionsGoal: widget.state.weeklyCardioSessionsGoal,
            ),
            const SizedBox(height: 16),
            _ChartCard(
              title: 'Strength volume trend',
              subtitle: 'See whether your output is climbing or flattening.',
              points: points
                  .asMap()
                  .entries
                  .map(
                    (entry) => FlSpot(
                      entry.key.toDouble(),
                      entry.value.strengthVolume,
                    ),
                  )
                  .toList(),
              lineColor: Colors.orangeAccent,
              emptyText: 'Log strength sets to unlock this chart.',
            ),
            const SizedBox(height: 16),
            _ChartCard(
              title: 'Cardio trend',
              subtitle:
                  'Track how consistently you are putting in interval work.',
              points: points
                  .asMap()
                  .entries
                  .map(
                    (entry) => FlSpot(
                      entry.key.toDouble(),
                      entry.value.cardioSeconds.toDouble(),
                    ),
                  )
                  .toList(),
              lineColor: Colors.lightBlueAccent,
              emptyText: 'Log timer intervals to unlock this chart.',
            ),
            const SizedBox(height: 16),
            _ChartCard(
              title: 'Body fat trend',
              subtitle:
                  'Monitor long-term body composition rather than daily emotion.',
              points: widget.state.bodyMetricsHistory
                  .asMap()
                  .entries
                  .map(
                    (entry) => FlSpot(
                      entry.key.toDouble(),
                      entry.value.bodyFatPercent,
                    ),
                  )
                  .toList(),
              lineColor: Colors.pinkAccent,
              emptyText: 'Save body metrics to unlock this chart.',
            ),
            const SizedBox(height: 16),
            _WorkoutHistoryCard(
              history: history,
              selectedDate: _selectedHistoryDate,
              selectedEntries: selectedEntries,
              onSelectDate: (date) {
                setState(() {
                  _selectedHistoryDate = date;
                });
              },
            ),
            const SizedBox(height: 16),
            _LatestSetsCard(state: widget.state),
          ]),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class _InsightCard extends StatelessWidget {
  final String message;

  const _InsightCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.insights_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  final double currentWeekVolume;
  final double weeklyVolumeGoal;
  final int currentWeekCardioSessions;
  final int weeklyCardioSessionsGoal;

  const _GoalsCard({
    required this.currentWeekVolume,
    required this.weeklyVolumeGoal,
    required this.currentWeekCardioSessions,
    required this.weeklyCardioSessionsGoal,
  });

  @override
  Widget build(BuildContext context) {
    final volumeProgress =
        (weeklyVolumeGoal <= 0 ? 0 : currentWeekVolume / weeklyVolumeGoal)
            .clamp(0, 1)
            .toDouble();
    final cardioProgress = (weeklyCardioSessionsGoal <= 0
            ? 0
            : currentWeekCardioSessions / weeklyCardioSessionsGoal)
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
              'Auto weekly goals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _GoalProgressRow(
              title: 'Strength volume',
              progress: volumeProgress,
              subtitle:
                  '${currentWeekVolume.toStringAsFixed(0)} / ${weeklyVolumeGoal.toStringAsFixed(0)} kg',
            ),
            const SizedBox(height: 12),
            _GoalProgressRow(
              title: 'Cardio sessions',
              progress: cardioProgress,
              subtitle:
                  '$currentWeekCardioSessions / $weeklyCardioSessionsGoal sessions',
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
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final List<WorkoutHistoryEntryModel> history;
  final DateTime? selectedDate;
  final List<WorkoutHistoryEntryModel> selectedEntries;
  final ValueChanged<DateTime> onSelectDate;

  const _WorkoutHistoryCard({
    required this.history,
    required this.selectedDate,
    required this.selectedEntries,
    required this.onSelectDate,
  });

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
              'Workout history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Browse sessions by date and review what happened.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            if (history.isEmpty)
              const Text('No session history yet.')
            else ...[
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    final isSelected = selectedDate != null &&
                        entry.sessionDate.year == selectedDate!.year &&
                        entry.sessionDate.month == selectedDate!.month &&
                        entry.sessionDate.day == selectedDate!.day;
                    return ChoiceChip(
                      label: Text(_formatDate(entry.sessionDate)),
                      selected: isSelected,
                      onSelected: (_) => onSelectDate(entry.sessionDate),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ...selectedEntries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.strengthVolume.toStringAsFixed(0)} kg volume • ${entry.cardioSeconds}s cardio',
                        ),
                        if (entry.sessionNote.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Note: ${entry.sessionNote.trim()}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day';
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<FlSpot> points;
  final Color lineColor;
  final String emptyText;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.lineColor,
    required this.emptyText,
  });

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
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 14),
            if (points.isEmpty)
              Text(emptyText)
            else
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _horizontalInterval(points),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: const LineTouchData(enabled: true),
                    titlesData: const FlTitlesData(
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: points,
                        isCurved: true,
                        color: lineColor,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: lineColor.withValues(alpha: 0.16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _horizontalInterval(List<FlSpot> points) {
    final maxY =
        points.fold<double>(0, (max, point) => point.y > max ? point.y : max);
    if (maxY <= 20) {
      return 5;
    }
    if (maxY <= 100) {
      return 20;
    }
    return maxY / 4;
  }
}

class _LatestSetsCard extends StatelessWidget {
  final HomeReady state;

  const _LatestSetsCard({required this.state});

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
              'Recent strength sets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'A quick look at the latest work you logged.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            if (state.strengthSets.isEmpty)
              const Text('No sets logged yet.')
            else
              ...state.strengthSets.take(5).map(
                    (set) => Padding(
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
                            const Icon(Icons.fitness_center),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    set.exerciseName,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(_formatStrengthSet(set)),
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
    );
  }

  String _formatStrengthSet(StrengthSetModel set) {
    if (set.loadType == StrengthLoadType.bodyweight || set.weight <= 0) {
      return '${set.reps} reps • bodyweight';
    }
    if (set.loadType == StrengthLoadType.assisted) {
      return '${set.reps} reps • ${set.weight.toStringAsFixed(1)} kg assistance';
    }
    return '${set.reps} reps • ${set.weight.toStringAsFixed(1)} kg • volume ${set.volume.toStringAsFixed(1)}';
  }
}
