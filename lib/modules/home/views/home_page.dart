import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base_template/models/strength_set_model.dart';
import 'package:flutter_base_template/models/workout_plan_model.dart';
import 'package:flutter_base_template/modules/home/bloc/home_bloc.dart';
import 'package:flutter_base_template/modules/home/bloc/home_timer_cubit.dart';
import 'package:flutter_base_template/modules/home/views/widgets/home_progress_tab.dart';
import 'package:flutter_base_template/modules/home/views/widgets/home_timer_tab.dart';
import 'package:flutter_base_template/modules/home/views/widgets/home_today_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_provider/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedTab = 0;
  late final HomeBloc _homeBloc;
  late final HomeTimerCubit _homeTimerCubit;
  final _exerciseController = TextEditingController();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _bodyWeightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  StrengthLoadType _selectedLoadType = StrengthLoadType.bodyweight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = HomeBloc()..add(const InitializeHomeEvent());
    _homeTimerCubit = HomeTimerCubit(
      onWorkPhaseCompleted: (seconds) {
        _homeBloc.add(
          AddJumpRopeIntervalEvent(
            intervalType: _cardioModeLabel(
                WorkoutWeekPlan.forDate(DateTime.now()).cardioMode),
            durationSeconds: seconds,
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _homeTimerCubit.onLifecycleChanged(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _homeTimerCubit.close();
    _homeBloc.close();
    _exerciseController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _bodyWeightController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>.value(
          value: _homeBloc,
        ),
        BlocProvider<HomeTimerCubit>.value(
          value: _homeTimerCubit,
        ),
      ],
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          toolbarHeight: 72,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _tabTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                _tabSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .appBarTheme
                          .foregroundColor
                          ?.withValues(alpha: 0.82),
                    ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                ThemeProvider.themeOf(context).id == 'lightthemeid'
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              tooltip: 'Toggle theme',
              onPressed: () {
                final currentThemeId = ThemeProvider.themeOf(context).id;
                final newThemeId = currentThemeId == 'lightthemeid'
                    ? 'darkthemeid'
                    : 'lightthemeid';

                ThemeProvider.controllerOf(context).setTheme(newThemeId);
              },
            ),
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: 'Start new session',
              onPressed: () {
                _showSnackBar('New workout session started.');
                context.read<HomeBloc>().add(const StartNewSessionEvent());
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          top: false,
          child: BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeError) {
                _showSnackBar(state.message);
              } else if (state is HomeReady &&
                  state.sessionSummaryMessage != null &&
                  state.sessionSummaryMessage!.isNotEmpty) {
                showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Daily Summary'),
                    content: Text(state.sessionSummaryMessage!),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                context
                    .read<HomeBloc>()
                    .add(const DismissSessionSummaryEvent());
              }
            },
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is HomeReady) {
                _prefillBodyMetrics(state);
                return Column(
                  children: [
                    _TopSessionHeader(
                      state: state,
                      selectedTab: _selectedTab,
                      onTabSelected: (index) {
                        setState(() {
                          _selectedTab = index;
                        });
                      },
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedTab,
                        children: [
                          HomeTodayTab(
                            state: state,
                            exerciseController: _exerciseController,
                            weightController: _weightController,
                            repsController: _repsController,
                            bodyWeightController: _bodyWeightController,
                            heightController: _heightController,
                            bodyFatController: _bodyFatController,
                            selectedLoadType: _selectedLoadType,
                            onSubmitStrengthSet: () =>
                                _submitStrengthSet(context),
                            onSelectStrengthMove: (move) {
                              _exerciseController.text = move;
                            },
                            onLoadTypeChanged: (type) {
                              setState(() {
                                _selectedLoadType = type;
                                if (type == StrengthLoadType.bodyweight) {
                                  _weightController.clear();
                                }
                              });
                            },
                            onOpenTimerTab: () {
                              setState(() {
                                _selectedTab = 1;
                              });
                            },
                            onSaveBodyMetrics: () => _saveBodyMetrics(context),
                            onCompleteSession: () {
                              context
                                  .read<HomeBloc>()
                                  .add(const CompleteSessionEvent());
                            },
                          ),
                          BlocBuilder<HomeTimerCubit, HomeTimerState>(
                            builder: (context, timerState) {
                              final timerCubit = context.read<HomeTimerCubit>();
                              return HomeTimerTab(
                                state: state,
                                workSeconds: timerState.workSeconds,
                                restSeconds: timerState.restSeconds,
                                targetRounds: timerState.targetRounds,
                                round: timerState.round,
                                remainingSeconds: timerState.remainingSeconds,
                                isWorkPhase: timerState.isWorkPhase,
                                isRunning: timerState.isRunning,
                                onWorkSecondsChanged:
                                    timerCubit.onWorkSecondsChanged,
                                onRestSecondsChanged:
                                    timerCubit.onRestSecondsChanged,
                                onTargetRoundsChanged:
                                    timerCubit.onTargetRoundsChanged,
                                onToggleStartPause: timerCubit.toggleStartPause,
                                onReset: timerCubit.resetTimer,
                                onSkipPhase: timerCubit.skipPhase,
                              );
                            },
                          ),
                          HomeProgressTab(state: state),
                        ],
                      ),
                    ),
                  ],
                );
              }

              if (state is HomeInitial) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return const Center(
                child: Text('Unable to load session'),
              );
            },
          ),
        ),
      ),
    );
  }

  String get _tabTitle {
    switch (_selectedTab) {
      case 1:
        return 'Timer Studio';
      case 2:
        return 'Progress Insights';
      case 0:
      default:
        return 'Today\'s Session';
    }
  }

  String get _tabSubtitle {
    switch (_selectedTab) {
      case 1:
        return 'Run intervals without losing your place.';
      case 2:
        return 'See what is improving and what is lagging.';
      case 0:
      default:
        return 'Your plan, logs, and actions in one place.';
    }
  }

  void _submitStrengthSet(BuildContext context) {
    final exerciseName = _exerciseController.text.trim();
    final enteredWeight = double.tryParse(_weightController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());

    if (exerciseName.isEmpty || reps == null || reps <= 0) {
      _showSnackBar('Enter an exercise and a valid rep count.');
      return;
    }

    if (_selectedLoadType != StrengthLoadType.bodyweight &&
        enteredWeight == null) {
      _showSnackBar('Enter a load for assisted or external sets.');
      return;
    }

    final double finalWeight =
        _selectedLoadType == StrengthLoadType.bodyweight ? 0 : enteredWeight!;

    context.read<HomeBloc>().add(
          AddStrengthSetEvent(
            exerciseName: exerciseName,
            weight: finalWeight,
            loadType: _selectedLoadType,
            reps: reps,
          ),
        );

    HapticFeedback.mediumImpact();
    _repsController.clear();
    if (_selectedLoadType == StrengthLoadType.bodyweight) {
      _weightController.clear();
    }
    _showSnackBar('Strength set saved. Rest timer started.');
  }

  void _saveBodyMetrics(BuildContext context) {
    final weight = double.tryParse(_bodyWeightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final bodyFat = double.tryParse(_bodyFatController.text.trim());

    if (weight == null || height == null || bodyFat == null) {
      _showSnackBar('Enter weight, height, and body fat to save metrics.');
      return;
    }

    context.read<HomeBloc>().add(
          SaveBodyMetricsEvent(
            weightKg: weight,
            heightCm: height,
            bodyFatPercent: bodyFat,
          ),
        );
    HapticFeedback.selectionClick();
    _showSnackBar('Body metrics updated.');
  }

  void _prefillBodyMetrics(HomeReady state) {
    final latest = state.latestBodyMetrics;
    if (latest == null) {
      return;
    }
    if (_bodyWeightController.text.isEmpty) {
      _bodyWeightController.text = latest.weightKg.toStringAsFixed(1);
    }
    if (_heightController.text.isEmpty) {
      _heightController.text = latest.heightCm.toStringAsFixed(0);
    }
    if (_bodyFatController.text.isEmpty) {
      _bodyFatController.text = latest.bodyFatPercent.toStringAsFixed(1);
    }
  }

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  String _cardioModeLabel(CardioMode mode) {
    switch (mode) {
      case CardioMode.highIntensity:
        return 'hiit';
      case CardioMode.variable:
        return 'variable';
      case CardioMode.easy:
        return 'easy';
      case CardioMode.none:
        return 'rest';
      case CardioMode.steady:
        return 'steady';
    }
  }
}

class _TopSessionHeader extends StatelessWidget {
  final HomeReady state;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  const _TopSessionHeader({
    required this.state,
    required this.selectedTab,
    required this.onTabSelected,
  });

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
                              '${state.todayPlan.dayLabel} • ${state.todayPlan.focus}',
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
                      _CompletionRing(score: state.completionScore),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _HeaderStatChip(
                        icon: Icons.fitness_center,
                        label: 'Sets',
                        value: '${state.strengthSets.length}',
                      ),
                      _HeaderStatChip(
                        icon: Icons.timer_outlined,
                        label: 'Cardio',
                        value: '${state.cardioSeconds}s',
                      ),
                      _HeaderStatChip(
                        icon: Icons.local_fire_department_outlined,
                        label: 'Volume',
                        value: state.totalStrengthVolume.toStringAsFixed(0),
                      ),
                      if (state.restSecondsRemaining > 0)
                        _HeaderStatChip(
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
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                    value: 0, icon: Icon(Icons.today), label: Text('Today')),
                ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.timer_outlined),
                    label: Text('Timer')),
                ButtonSegment(
                    value: 2,
                    icon: Icon(Icons.show_chart),
                    label: Text('Progress')),
              ],
              selected: {selectedTab},
              onSelectionChanged: (selection) {
                onTabSelected(selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionRing extends StatelessWidget {
  final int score;

  const _CompletionRing({required this.score});

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

class _HeaderStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasized;

  const _HeaderStatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasized = false,
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
