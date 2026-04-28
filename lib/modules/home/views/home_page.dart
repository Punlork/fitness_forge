import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forge/models/workout_plan_model.dart';
import 'package:forge/modules/home/bloc/home_bloc.dart';
import 'package:forge/modules/home/bloc/home_timer_cubit.dart';
import 'package:forge/modules/home/utils/home_backup_utils.dart';
import 'package:forge/modules/home/widgets/home_progress_tab.dart';
import 'package:forge/modules/home/widgets/home_timer_tab.dart';
import 'package:forge/modules/dashboard/home_dashboard_tab.dart';
import 'package:forge/modules/home/widgets/top_session_header.dart';
import 'package:forge/utils/constants/app_assets.dart';
import 'package:forge/utils/widgets/app_header_text.dart';
import 'package:forge/utils/widgets/app_svg_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  int _selectedTab = 0;
  double _top = 0;
  late final HomeBloc _homeBloc;
  late final HomeTimerCubit _homeTimerCubit;
  final _bodyWeightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _sessionNoteController = TextEditingController();
  String? _lastBackupDirectory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _homeBloc = HomeBloc()..add(const InitializeHomeEvent());
    _homeTimerCubit = HomeTimerCubit(
      onWorkPhaseCompleted: (seconds) {
        final currentState = _homeBloc.state;
        final intervalType = currentState is HomeReady
            ? currentState.todayPlan.cardioMode.label
            : CardioMode.steady.label;
        _homeBloc.add(
          AddJumpRopeIntervalEvent(
            intervalType: intervalType,
            durationSeconds: seconds,
          ),
        );
      },
    );
  }

  void _onTabChanged() {
    if (_tabController.index != _selectedTab) {
      _selectedTab = _tabController.index;
      setState(() {});
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
        BlocProvider<HomeBloc>.value(value: _homeBloc),
        BlocProvider<HomeTimerCubit>.value(value: _homeTimerCubit),
      ],
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              final isSessionSummary = state is HomeReady &&
                  state.sessionSummaryMessage != null &&
                  state.sessionSummaryMessage!.isNotEmpty;

              if (state is HomeError) {
                _showSnackBar(state.message);
              } else if (isSessionSummary) {
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
    final statusBarHeight = MediaQuery.of(context).padding.top;

    final pinnedHeaderHeight = statusBarHeight + kToolbarHeight;

    return ExtendedNestedScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      pinnedHeaderSliverHeightBuilder: () => pinnedHeaderHeight,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 230,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: colorScheme.surface,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              _top = constraints.biggest.height;

              return FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 20,
                  bottom: 18,
                ),
                title: _top == pinnedHeaderHeight
                    ? AppHeaderText(
                        '${state.todayPlan.dayLabel} \u2022 ${state.todayPlan.focus}',
                        level: AppHeaderLevel.subsection,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : SizedBox(),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.10),
                        colorScheme.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        const SizedBox(height: kToolbarHeight),
                        Expanded(
                          child: TopSessionHeader(state: state),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const AppSvgIcon(
                assetName: AppAssets.historyIcon,
              ),
              tooltip: 'Workout history',
              onPressed: () => context.push('/history'),
            ),
            // IconButton(
            //   icon: Icon(
            //     ThemeProvider.themeOf(context).id == 'lightthemeid'
            //         ? Icons.dark_mode_outlined
            //         : Icons.light_mode_outlined,
            //   ),
            //   tooltip: 'Toggle theme',
            //   onPressed: () {
            //     final currentThemeId = ThemeProvider.themeOf(context).id;
            //     final newThemeId = currentThemeId == 'lightthemeid'
            //         ? 'darkthemeid'
            //         : 'lightthemeid';

            //     ThemeProvider.controllerOf(context).setTheme(newThemeId);
            //   },
            // ),
            IconButton(
              icon: const AppSvgIcon(
                assetName: AppAssets.restartIcon,
              ),
              tooltip: 'Start new session',
              onPressed: () {
                _showSnackBar('New workout session started.');
                context.read<HomeBloc>().add(const StartNewSessionEvent());
              },
            ),
            PopupMenuButton<_BackupMenuAction>(
              tooltip: 'Backup options',
              icon: const AppSvgIcon(
                assetName: AppAssets.logIcon,
              ),
              onSelected: (value) {
                switch (value) {
                  case _BackupMenuAction.export:
                    HomeBackupUtils.handleExportBackup(
                      context: context,
                      lastBackupDirectory: _lastBackupDirectory,
                      showSnackBar: _showSnackBar,
                    ).then(
                      (value) {
                        _lastBackupDirectory = value;
                      },
                    );
                    return;
                  case _BackupMenuAction.import:
                    HomeBackupUtils.handleImportBackup(
                      context: context,
                      lastBackupDirectory: _lastBackupDirectory,
                      showSnackBar: _showSnackBar,
                      onImportApplied: () async {
                        _homeTimerCubit.resetTimer();
                        _homeBloc.add(const InitializeHomeEvent());
                      },
                    ).then((value) {
                      _lastBackupDirectory = value;
                    });
                    return;
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: _BackupMenuAction.export,
                    child: Row(
                      children: [
                        AppSvgIcon(
                          assetName: AppAssets.logIcon,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text('Export backup'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _BackupMenuAction.import,
                    child: Row(
                      children: [
                        AppSvgIcon(
                          assetName: AppAssets.historyIcon,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text('Import backup'),
                      ],
                    ),
                  ),
                ];
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            padding: EdgeInsets.zero,
            dividerColor: Colors.transparent,
            isScrollable: false,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) => states.contains(WidgetState.focused)
                  ? null
                  : Colors.transparent,
            ),
            tabs: [
              Tab(
                child: _buildTabChip(
                  context: context,
                  index: 0,
                  label: 'Dashboard',
                  iconAsset: AppAssets.dashboardIcon,
                ),
              ),
              Tab(
                child: _buildTabChip(
                  context: context,
                  index: 1,
                  label: 'Timer',
                  iconAsset: AppAssets.timerIcon,
                ),
              ),
              Tab(
                child: _buildTabChip(
                  context: context,
                  index: 2,
                  label: 'Progress',
                  iconAsset: AppAssets.progressIcon,
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ExtendedVisibilityDetector(
                  uniqueKey: const Key('DashboardTab'),
                  child: HomeDashboardTab(
                    state: state,
                    bodyWeightController: _bodyWeightController,
                    heightController: _heightController,
                    bodyFatController: _bodyFatController,
                    sessionNoteController: _sessionNoteController,
                    onSaveBodyMetrics: () => _saveBodyMetrics(context),
                    onSaveSessionNote: () => _saveSessionNote(context),
                    onCompleteSession: () => context.read<HomeBloc>().add(
                          const CompleteSessionEvent(),
                        ),
                  ),
                ),
                ExtendedVisibilityDetector(
                  uniqueKey: const Key('TimerTab'),
                  child: BlocBuilder<HomeTimerCubit, HomeTimerState>(
                    builder: (context, timerState) {
                      final timerCubit = context.read<HomeTimerCubit>();
                      return HomeTimerTab(
                        workSeconds: timerState.workSeconds,
                        restSeconds: timerState.restSeconds,
                        targetRounds: timerState.targetRounds,
                        round: timerState.round,
                        remainingSeconds: timerState.remainingSeconds,
                        isWorkPhase: timerState.isWorkPhase,
                        isRunning: timerState.isRunning,
                        isPhaseCompleteAwaitingNext:
                            timerState.isPhaseCompleteAwaitingNext,
                        onWorkSecondsChanged: timerCubit.onWorkSecondsChanged,
                        onRestSecondsChanged: timerCubit.onRestSecondsChanged,
                        onTargetRoundsChanged: timerCubit.onTargetRoundsChanged,
                        onToggleStartPause: timerCubit.toggleStartPause,
                        onReset: timerCubit.resetTimer,
                        onSkipPhase: timerCubit.skipPhase,
                        onRequestNotificationPermissions:
                            timerCubit.requestNotificationPermissions,
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
          ),
        ],
      ),
    );
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

  Widget _buildTabChip({
    required BuildContext context,
    required int index,
    required String label,
    required String iconAsset,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedTab == index;
    final tabColor = isSelected ? colorScheme.primary : colorScheme.outline;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSvgIcon(
              assetName: iconAsset,
              size: 18,
              color: tabColor,
            ),
            const SizedBox(width: 6),
            AppHeaderText(
              label,
              level: AppHeaderLevel.subsection,
              color: tabColor,
            ),
          ],
        ),
      ),
    );
  }
}

enum _BackupMenuAction {
  export,
  import,
}
