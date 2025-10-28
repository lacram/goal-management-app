import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../data/providers/goal_provider.dart';
import '../../../data/models/goal.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/goal_widgets/goal_card.dart';
import '../../widgets/animations/animated_widgets.dart';
import '../../widgets/animations/animated_card.dart';
import '../goal/create_goal_screen.dart';
import '../goal_list/goal_list_screen.dart';
import '../statistics/statistics_screen.dart';
import '../goal/goal_detail_screen.dart';
import '../settings/settings_screen.dart';
import '../routine/routine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;
  GoalCardDisplayMode _displayMode = GoalCardDisplayMode.compact; // 컴팩트 모드를 기본값으로 설정
  bool _showRootGoalsOnly = true; // 최상위 목표만 보기
  final Set<int> _expandedGoalIds = {}; // 확장된 목표 ID 집합
  bool _showAllGoals = false; // 전체 목표 섹션에서 모든 목표 표시 여부

  @override
  void initState() {
    super.initState();
    
    // FAB 애니메이션 초기화
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));
    
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      // FAB 애니메이션 시작
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _fabController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final goalProvider = context.read<GoalProvider>();
    await Future.wait([
      goalProvider.loadTodayGoals(),
      goalProvider.loadActiveGoals(),
    ]);
  }

  Future<void> _refreshData() async {
    final goalProvider = context.read<GoalProvider>();
    await goalProvider.refreshAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInWidget(
          delay: const Duration(milliseconds: 200),
          child: const Text(AppStrings.appTitle),
        ),
        elevation: 0,
        actions: [
          FadeInWidget(
            delay: const Duration(milliseconds: 300),
            child: IconButton(
              icon: const Icon(Icons.view_agenda),
              tooltip: '표시 모드',
              onPressed: _showDisplayModeSelector,
            ),
          ),
          FadeInWidget(
            delay: const Duration(milliseconds: 400),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushWithSlideFromRight(
                  const SettingsScreen(),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          if (goalProvider.isLoading && goalProvider.todayGoals.isEmpty) {
            return const LoadingWidget();
          }

          if (goalProvider.error != null) {
            return CustomErrorWidget(
              message: goalProvider.error!,
              onRetry: _loadInitialData,
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: StaggeredListAnimation(
                children: [
                  // 빠른 액션 섹션
                  _buildQuickActionsSection(),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 오늘의 목표 섹션
                  _buildTodayGoalsSection(goalProvider),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 전체 목표 섹션
                  _buildAllGoalsSection(goalProvider),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 진행률 요약 섹션
                  _buildProgressSummarySection(goalProvider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).pushWithSlideFromBottom(
              const CreateGoalScreen(),
            );
            
            if (result == true) {
              _loadInitialData();
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTodayGoalsSection(GoalProvider goalProvider) {
    final todayGoals = goalProvider.todayGoals;
    
    // 활성화된 목표와 완료된 목표 분리
    final activeGoals = todayGoals.where((goal) => !goal.isCompleted).toList();
    final completedGoals = todayGoals.where((goal) => goal.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.todayGoals,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (todayGoals.isNotEmpty)
              ScaleInWidget(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                  child: Text(
                    '${completedGoals.length}/${todayGoals.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        
        if (todayGoals.isEmpty)
          FadeInWidget(
            delay: const Duration(milliseconds: 400),
            child: AnimatedGoalCard(
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Center(
                    child: Column(
                      children: [
                        PulseAnimation(
                          child: Icon(
                            Icons.task_alt,
                            size: 48,
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingMedium),
                        Text(
                          '오늘의 목표가 없습니다',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          '새로운 목표를 추가해보세요!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        
        // 활성 목표 섬션
        if (activeGoals.isNotEmpty) ...[
          Text(
            '활성 목표',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          StaggeredListAnimation(
            staggerDelay: const Duration(milliseconds: 100),
            children: activeGoals.map((goal) => GoalCard(
              goal: goal,
              displayMode: _displayMode,
              onTap: () {
                Navigator.of(context).pushWithSlideAndFade(
                  GoalDetailScreen(goal: goal),
                );
              },
              onCompleteToggle: (goal) async {
              final success = await goalProvider.completeGoal(goal.id!);
              if (success) {
                  await goalProvider.loadTodayGoals();
                  }
                },
              onEdit: () async {
                final result = await Navigator.of(context).pushWithSlideFromRight(
                  CreateGoalScreen(editGoal: goal),
                );

                if (result == true) {
                  _loadInitialData();
                }
              },
            )).toList(),
          ),
        ],
        
        // 완료된 목표 섬션
        if (completedGoals.isNotEmpty) ...[
          const SizedBox(height: AppSizes.paddingLarge),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.successColor,
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                '오늘 완료한 목표',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.successColor,
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                '(${completedGoals.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          StaggeredListAnimation(
            staggerDelay: const Duration(milliseconds: 100),
            children: completedGoals.map((goal) => Opacity(
              opacity: 0.7,
              child: GoalCard(
                goal: goal,
                displayMode: _displayMode,
                onTap: () {
                  Navigator.of(context).pushWithSlideAndFade(
                    GoalDetailScreen(goal: goal),
                  );
                },
                onCompleteToggle: (goal) async {
                final success = await goalProvider.uncompleteGoal(goal.id!);
                if (success) {
                    await goalProvider.loadTodayGoals();
                    }
                  },
                onEdit: () async {
                  final result = await Navigator.of(context).pushWithSlideFromRight(
                    CreateGoalScreen(editGoal: goal),
                  );

                  if (result == true) {
                    _loadInitialData();
                  }
                },
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAllGoalsSection(GoalProvider goalProvider) {
    final allActiveGoals = goalProvider.activeGoals;
    final rootGoals = allActiveGoals.where((goal) => goal.parentGoalId == null).toList();
    final displayGoals = _showRootGoalsOnly ? rootGoals : allActiveGoals;
    final displayLimit = _showAllGoals ? displayGoals.length : 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '전체 목표',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                // 토글 버튼
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.dividerColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton(
                        '최상위',
                        _showRootGoalsOnly,
                        () => setState(() => _showRootGoalsOnly = true),
                      ),
                      _buildToggleButton(
                        '전체',
                        !_showRootGoalsOnly,
                        () => setState(() => _showRootGoalsOnly = false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                // 개수 표시
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.activeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                  child: Text(
                    '${displayGoals.length}개',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.activeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),

        if (displayGoals.isEmpty)
          FadeInWidget(
            delay: const Duration(milliseconds: 400),
            child: AnimatedGoalCard(
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 48,
                          color: AppColors.textSecondaryColor,
                        ),
                        const SizedBox(height: AppSizes.paddingMedium),
                        Text(
                          _showRootGoalsOnly ? '최상위 목표가 없습니다' : '활성 목표가 없습니다',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          '새로운 목표를 추가해보세요!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (displayGoals.isNotEmpty)
          _showRootGoalsOnly
              ? _buildHierarchicalGoals(displayGoals.take(displayLimit).toList(), goalProvider)
              : StaggeredListAnimation(
                  staggerDelay: const Duration(milliseconds: 100),
                  children: displayGoals.take(displayLimit).map((goal) => GoalCard(
                    goal: goal,
                    displayMode: _displayMode,
                    onTap: () {
                      Navigator.of(context).pushWithSlideAndFade(
                        GoalDetailScreen(goal: goal),
                      );
                    },
                    onCompleteToggle: (goal) async {
                      final success = await goalProvider.completeGoal(goal.id!);
                      if (success) {
                        await goalProvider.loadActiveGoals();
                        await goalProvider.loadTodayGoals();
                      }
                    },
                    onEdit: () async {
                      final result = await Navigator.of(context).pushWithSlideFromRight(
                        CreateGoalScreen(editGoal: goal),
                      );

                      if (result == true) {
                        _loadInitialData();
                      }
                    },
                  )).toList(),
                ),

        if (displayGoals.length > 5) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showAllGoals = !_showAllGoals;
                });
              },
              icon: Icon(_showAllGoals ? Icons.expand_less : Icons.expand_more),
              label: Text(
                _showAllGoals
                  ? '접기'
                  : '더보기 (${displayGoals.length - 5}개 더)',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHierarchicalGoals(List<Goal> rootGoals, GoalProvider goalProvider) {
    return Column(
      children: rootGoals.map((rootGoal) {
        final isExpanded = _expandedGoalIds.contains(rootGoal.id);
        final hasSubGoals = rootGoal.subGoals.isNotEmpty;

        return Column(
          children: [
            // 최상위 목표 (확장/축소 버튼 포함)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 확장/축소 버튼 (하위 목표가 있을 때만)
                if (hasSubGoals)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedGoalIds.remove(rootGoal.id);
                          } else {
                            _expandedGoalIds.add(rootGoal.id!);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          isExpanded ? Icons.expand_more : Icons.chevron_right,
                          size: 20,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                // 목표 카드
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: AppSizes.paddingMedium,
                    ),
                    child: GoalCard(
                      goal: rootGoal,
                      displayMode: _displayMode,
                      enableAnimation: false, // 계층형 뷰에서는 애니메이션 비활성화
                      margin: const EdgeInsets.only(
                        top: AppSizes.paddingSmall,
                        bottom: AppSizes.paddingSmall,
                      ),
                      onTap: () {
                        Navigator.of(context).pushWithSlideAndFade(
                          GoalDetailScreen(goal: rootGoal),
                        );
                      },
                      onCompleteToggle: (goal) async {
                        final success = await goalProvider.completeGoal(goal.id!);
                        if (success) {
                          await goalProvider.loadActiveGoals();
                          await goalProvider.loadTodayGoals();
                        }
                      },
                      onEdit: () async {
                        final result = await Navigator.of(context).pushWithSlideFromRight(
                          CreateGoalScreen(editGoal: rootGoal),
                        );

                        if (result == true) {
                          _loadInitialData();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            // 하위 목표들 (확장된 경우에만 표시)
            if (hasSubGoals && isExpanded) ...[
              Padding(
                padding: const EdgeInsets.only(left: AppSizes.paddingLarge * 1.5),
                child: Column(
                  children: rootGoal.subGoals.take(3).map((subGoal) {
                    return GoalCard(
                      goal: subGoal,
                      displayMode: _displayMode,
                      enableAnimation: false, // 계층형 뷰에서는 애니메이션 비활성화
                      isSubGoal: true,
                      onTap: () {
                        Navigator.of(context).pushWithSlideAndFade(
                          GoalDetailScreen(goal: subGoal),
                        );
                      },
                      onCompleteToggle: (goal) async {
                        final success = await goalProvider.completeGoal(goal.id!);
                        if (success) {
                          await goalProvider.loadActiveGoals();
                          await goalProvider.loadTodayGoals();
                        }
                      },
                      onEdit: () async {
                        final result = await Navigator.of(context).pushWithSlideFromRight(
                          CreateGoalScreen(editGoal: subGoal),
                        );

                        if (result == true) {
                          _loadInitialData();
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              if (rootGoal.subGoals.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: AppSizes.paddingLarge * 1.5),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushWithSlideAndFade(
                        GoalDetailScreen(goal: rootGoal),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text('하위 목표 ${rootGoal.subGoals.length - 3}개 더 보기'),
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
            ],
          ],
        );
      }).toList(),
    );
  }

  Widget _buildProgressSummarySection(GoalProvider goalProvider) {
    final activeGoals = goalProvider.activeGoals;
    final todayGoals = goalProvider.todayGoals;
    
    final completedTodayGoals = todayGoals.where((goal) => goal.isCompleted).length;
    final totalTodayGoals = todayGoals.length;
    final todayProgress = totalTodayGoals > 0 ? completedTodayGoals / totalTodayGoals : 0.0;
    
    return AnimatedGoalCard(
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '진행 현황',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              
              // 오늘의 진행률
              SlideInWidget(
                delay: const Duration(milliseconds: 200),
                begin: const Offset(-0.5, 0),
                child: _buildProgressItem(
                  '오늘의 달성률',
                  todayProgress,
                  '$completedTodayGoals/$totalTodayGoals',
                  AppColors.dailyColor,
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              
              // 전체 활성 목표
              SlideInWidget(
                delay: const Duration(milliseconds: 400),
                begin: const Offset(0.5, 0),
                child: _buildProgressItem(
                  '활성 목표',
                  1.0,
                  '${activeGoals.length}개',
                  AppColors.activeColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    String title,
    double progress,
    String subtitle,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: progress),
          curve: Curves.easeInOut,
          builder: (context, animatedProgress, child) {
            return LinearProgressIndicator(
              value: animatedProgress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 작업',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall), // paddingMedium → paddingSmall
        Row(
          children: [
            Expanded(
              child: ScaleInWidget(
                delay: const Duration(milliseconds: 200),
                child: _buildQuickActionCard(
                  '전체 목표',
                  Icons.list,
                  AppColors.primaryColor,
                  () {
                    Navigator.of(context).pushWithSlideFromRight(
                      const GoalListScreen(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 6), // paddingSmall → 6px
            Expanded(
              child: ScaleInWidget(
                delay: const Duration(milliseconds: 300),
                child: _buildQuickActionCard(
                  '루틴',
                  Icons.repeat,
                  const Color(0xFF10B981), // Emerald
                  () {
                    Navigator.of(context).pushWithSlideFromRight(
                      const RoutineScreen(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 6), // paddingSmall → 6px
            Expanded(
              child: ScaleInWidget(
                delay: const Duration(milliseconds: 400),
                child: _buildQuickActionCard(
                  '진행중',
                  Icons.play_arrow,
                  AppColors.warningColor,
                  () async {
                    final goalProvider = context.read<GoalProvider>();
                    await goalProvider.loadActiveGoals();

                    if (context.mounted) {
                      Navigator.of(context).pushWithSlideFromRight(
                        const GoalListScreen(initialTabIndex: 1), // 진행중 탭
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 6), // paddingSmall → 6px
            Expanded(
              child: ScaleInWidget(
                delay: const Duration(milliseconds: 500),
                child: _buildQuickActionCard(
                  '완료됨',
                  Icons.check_circle,
                  AppColors.successColor,
                  () async {
                    final goalProvider = context.read<GoalProvider>();
                    await goalProvider.loadCompletedGoals();

                    if (context.mounted) {
                      Navigator.of(context).pushWithSlideFromRight(
                        const GoalListScreen(initialTabIndex: 2), // 완료 탭
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 6), // paddingSmall → 6px
            Expanded(
              child: ScaleInWidget(
                delay: const Duration(milliseconds: 600),
                child: _buildQuickActionCard(
                  '통계',
                  Icons.analytics,
                  AppColors.infoColor,
                  () {
                    Navigator.of(context).pushWithFade(
                      const StatisticsScreen(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AnimatedGoalCard(
      onTap: onTap,
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8, // paddingMedium (16) → 8
            horizontal: 4, // paddingSmall (8) → 4
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseAnimation(
                duration: const Duration(seconds: 2),
                minScale: 0.95,
                maxScale: 1.05,
                child: Icon(
                  icon,
                  size: 22, // 28 → 22
                  color: color,
                ),
              ),
              const SizedBox(height: 3), // 6 → 3
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisplayModeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '목표 표시 모드',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  '원하는 표시 모드를 선택하여 미리 확인해보세요',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),

                _buildModeOption(
                  '일반 모드',
                  '기본 스타일 - 모든 정보 표시',
                  Icons.view_headline,
                  GoalCardDisplayMode.normal,
                  _displayMode == GoalCardDisplayMode.normal,
                ),
                _buildModeOption(
                  '컴팩트 모드',
                  '한 줄 표시 - 가장 작은 공간 차지',
                  Icons.view_stream,
                  GoalCardDisplayMode.compact,
                  _displayMode == GoalCardDisplayMode.compact,
                ),
                _buildModeOption(
                  '리스트 모드',
                  '리스트 스타일 - 경계선 구분',
                  Icons.view_list,
                  GoalCardDisplayMode.list,
                  _displayMode == GoalCardDisplayMode.list,
                ),
                _buildModeOption(
                  '미니멀 모드',
                  '간소화 - 설명/진행률 제외',
                  Icons.view_agenda,
                  GoalCardDisplayMode.minimal,
                  _displayMode == GoalCardDisplayMode.minimal,
                ),

                const SizedBox(height: AppSizes.paddingSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption(
    String title,
    String description,
    IconData icon,
    GoalCardDisplayMode mode,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _displayMode = mode;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.textSecondaryColor,
              size: 28,
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
