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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;

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
                  // 인사말 섹션
                  _buildGreetingSection(),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 오늘의 목표 섹션
                  _buildTodayGoalsSection(goalProvider),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 진행률 요약 섹션
                  _buildProgressSummarySection(goalProvider),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 빠른 액션 섹션
                  _buildQuickActionsSection(),
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

  Widget _buildGreetingSection() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    String emoji;

    if (hour < 12) {
      greeting = '좋은 아침이에요!';
      emoji = '☀️';
    } else if (hour < 18) {
      greeting = '좋은 오후에요!';
      emoji = '🌤️';
    } else {
      greeting = '좋은 저녁이에요!';
      emoji = '🌙';
    }

    return AnimatedGoalCard(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      greeting,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  BounceInWidget(
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Text(
                '오늘도 목표를 향해 한 걸음씩 나아가세요!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ],
          ),
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

  Widget _buildProgressSummarySection(GoalProvider goalProvider) {
    final activeGoals = goalProvider.activeGoals;
    final todayGoals = goalProvider.todayGoals;
    
    final completedTodayGoals = todayGoals.where((goal) => goal.isCompleted).length;
    final totalTodayGoals = todayGoals.length;
    final todayProgress = totalTodayGoals > 0 ? completedTodayGoals / totalTodayGoals : 0.0;
    
    return AnimatedGoalCard(
      child: Card(
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
        const SizedBox(height: AppSizes.paddingMedium),
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
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: ScaleInWidget(
                delay: const Duration(milliseconds: 400),
                child: _buildQuickActionCard(
                  '진행중 목표',
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
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Row(
          children: [
            Expanded(
              child: ScaleInWidget(
                delay: const Duration(milliseconds: 600),
                child: _buildQuickActionCard(
                  '완료된 목표',
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
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: ScaleInWidget(
                delay: const Duration(milliseconds: 800),
                child: _buildQuickActionCard(
                  '통계 대시보드',
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
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            children: [
              PulseAnimation(
                duration: const Duration(seconds: 2),
                minScale: 0.95,
                maxScale: 1.05,
                child: Icon(
                  icon,
                  size: AppSizes.iconLarge,
                  color: color,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
