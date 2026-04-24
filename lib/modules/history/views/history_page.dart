import 'package:flutter/material.dart';
import 'package:forge/models/workout_history_entry_model.dart';
import 'package:forge/repository/workout/local/local_workout_repository.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final LocalWorkoutRepository _repo = LocalWorkoutRepository();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<WorkoutHistoryEntryModel> _history = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _repo.getRecentSessionHistory(days: 365);
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  List<WorkoutHistoryEntryModel> _getEventsForDay(DateTime day) {
    return _history.where((h) => _isSameDay(h.sessionDate, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedEvents = _selectedDay == null
        ? const <WorkoutHistoryEntryModel>[]
        : _getEventsForDay(_selectedDay!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: TableCalendar<WorkoutHistoryEntryModel>(
                          firstDay: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDay: DateTime.now(),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) {
                            return _isSameDay(_selectedDay, day);
                          },
                          eventLoader: _getEventsForDay,
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          headerStyle: HeaderStyle(
                            formatButtonDecoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            formatButtonTextStyle: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                            ),
                            titleCentered: true,
                          ),
                          calendarStyle: CalendarStyle(
                            markerDecoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: TextStyle(
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      selectedEvents.isEmpty
                          ? 'No workouts on this day'
                          : '${selectedEvents.length} session${selectedEvents.length > 1 ? 's' : ''} on ${DateFormat.yMMMd().format(_selectedDay!)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                if (selectedEvents.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 64,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rest day or not logged yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    sliver: SliverList.separated(
                      itemCount: selectedEvents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = selectedEvents[index];
                        return _HistoryEntryCard(entry: entry);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _HistoryEntryCard extends StatelessWidget {
  final WorkoutHistoryEntryModel entry;

  const _HistoryEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: entry.workoutCompleted
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.workoutCompleted ? 'Completed' : 'In progress',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: entry.workoutCompleted
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat.Hm().format(entry.startedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _HistoryStat(
                    icon: Icons.fitness_center,
                    label: 'Volume',
                    value: '${entry.strengthVolume.toStringAsFixed(0)} kg',
                  ),
                ),
                Expanded(
                  child: _HistoryStat(
                    icon: Icons.timer_outlined,
                    label: 'Cardio',
                    value: '${entry.cardioSeconds}s',
                  ),
                ),
              ],
            ),
            if (entry.sessionNote.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 18,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.sessionNote.trim(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HistoryStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ],
    );
  }
}
