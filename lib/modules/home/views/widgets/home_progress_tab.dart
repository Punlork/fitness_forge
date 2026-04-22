import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_template/models/strength_set_model.dart';
import 'package:flutter_base_template/modules/home/bloc/home_bloc.dart';

class HomeProgressTab extends StatelessWidget {
  final HomeReady state;

  const HomeProgressTab({
    required this.state,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final points = state.progressPoints;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                title: '14 day volume',
                value: points
                    .fold<double>(0, (sum, point) => sum + point.strengthVolume)
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
          subtitle: 'Track how consistently you are putting in interval work.',
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
          points: state.bodyMetricsHistory
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
        _LatestSetsCard(state: state),
      ],
    );
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
