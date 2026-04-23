import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base_template/models/strength_set_model.dart';
import 'package:flutter_base_template/models/workout_plan_model.dart';
import 'package:flutter_base_template/modules/home/bloc/home_bloc.dart';
import 'package:flutter_base_template/modules/home/bloc/home_timer_cubit.dart';
import 'package:flutter_base_template/modules/home/views/widgets/home_progress_tab.dart';
import 'package:flutter_base_template/modules/home/views/widgets/home_timer_tab.dart';
import 'package:flutter_base_template/modules/home/views/widgets/home_today_tab.dart';
import 'package:flutter_base_template/modules/home/views/widgets/sticky_tab_bar_delegate.dart';
import 'package:flutter_base_template/modules/home/views/widgets/top_session_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:theme_provider/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  int _selectedTab = 0;
  late final HomeBloc _homeBloc;
  late final HomeTimerCubit _homeTimerCubit;
  final _exerciseController = TextEditingController();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _bodyWeightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _sessionNoteController = TextEditingController();
  StrengthLoadType _selectedLoadType = StrengthLoadType.bodyweight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _homeBloc = HomeBloc()..add(const InitializeHomeEvent());
    _homeTimerCubit = HomeTimerCubit(
      onWorkPhaseCompleted: (seconds) {
        _homeBloc.add(
          AddJumpRopeIntervalEvent(
            intervalType: _cardioModeLabel(
              WorkoutWeekPlan.forDate(DateTime.now()).cardioMode,
            ),
            durationSeconds: seconds,
          ),
        );
      },
    );
  }

  void _onTabChanged() {
    if (_tabController.index != _selectedTab) {
      setState(() => _selectedTab = _tabController.index);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _homeTimerCubit.onLifecycleChanged(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _homeTimerCubit.close();
    _homeBloc.close();
    _exerciseController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _bodyWeightController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    _sessionNoteController.dispose();
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
                return _buildScrollableBody(context, state);
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

  Widget _buildScrollableBody(BuildContext context, HomeReady state) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExtendedNestedScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      pinnedHeaderSliverHeightBuilder: () => 64,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 140,
          floating: true,
          pinned: true,
          snap: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding:
                const EdgeInsetsDirectional.only(start: 20, bottom: 16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _tabTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  _tabSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.12),
                    colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history_outlined),
              tooltip: 'Workout history',
              onPressed: () => context.push('/history'),
            ),
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
        SliverToBoxAdapter(
          child: TopSessionHeader(state: state),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: StickyTabBarDelegate(
            child: Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.today, size: 18),
                    label: Text('Today'),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.timer_outlined, size: 18),
                    label: Text('Timer'),
                  ),
                  ButtonSegment(
                    value: 2,
                    icon: Icon(Icons.show_chart, size: 18),
                    label: Text('Progress'),
                  ),
                ],
                selected: {_tabController.index},
                onSelectionChanged: (selection) {
                  _tabController.animateTo(selection.first);
                },
              ),
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ExtendedVisibilityDetector(
            uniqueKey: const Key('TodayTab'),
            child: HomeTodayTab(
              state: state,
              exerciseController: _exerciseController,
              weightController: _weightController,
              repsController: _repsController,
              bodyWeightController: _bodyWeightController,
              heightController: _heightController,
              bodyFatController: _bodyFatController,
              sessionNoteController: _sessionNoteController,
              selectedLoadType: _selectedLoadType,
              onSubmitStrengthSet: () => _submitStrengthSet(context),
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
              onSaveBodyMetrics: () => _saveBodyMetrics(context),
              onSaveSessionNote: () => _saveSessionNote(context),
              onCompleteSession: () {
                context
                    .read<HomeBloc>()
                    .add(const CompleteSessionEvent());
              },
            ),
          ),
          ExtendedVisibilityDetector(
            uniqueKey: const Key('TimerTab'),
            child: BlocBuilder<HomeTimerCubit, HomeTimerState>(
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
                  onWorkSecondsChanged: timerCubit.onWorkSecondsChanged,
                  onRestSecondsChanged: timerCubit.onRestSecondsChanged,
                  onTargetRoundsChanged: timerCubit.onTargetRoundsChanged,
                  onToggleStartPause: timerCubit.toggleStartPause,
                  onReset: timerCubit.resetTimer,
                  onSkipPhase: timerCubit.skipPhase,
                );
              },
            ),
          ),
          ExtendedVisibilityDetector(
            uniqueKey: const Key('ProgressTab'),
            child: HomeProgressTab(state: state),
          ),
        ],
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
    if (_sessionNoteController.text.isEmpty) {
      _sessionNoteController.text = state.session.sessionNote;
    }
  }

  void _saveSessionNote(BuildContext context) {
    final note = _sessionNoteController.text.trim();
    context.read<HomeBloc>().add(SaveSessionNoteEvent(note: note));
    HapticFeedback.selectionClick();
    _showSnackBar('Session note saved.');
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


