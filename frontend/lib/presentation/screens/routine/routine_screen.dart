import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../data/providers/routine_provider.dart';
import '../../../data/models/routine.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/routine_widgets/routine_card.dart';
import '../../widgets/animations/animated_widgets.dart';
import 'create_routine_screen.dart';
import 'routine_detail_screen.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> with TickerProviderStateMixin {
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
    final routineProvider = context.read<RoutineProvider>();
    await routineProvider.loadTodayRoutines();
  }

  Future<void> _refreshData() async {
    final routineProvider = context.read<RoutineProvider>();
    await routineProvider.refreshAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInWidget(
          delay: const Duration(milliseconds: 200),
          child: const Text(AppStrings.routines),
        ),
        elevation: 0,
      ),
      body: Consumer<RoutineProvider>(
        builder: (context, routineProvider, child) {
          if (routineProvider.isLoading && routineProvider.todayRoutines.isEmpty) {
            return const LoadingWidget();
          }

          if (routineProvider.error != null) {
            return CustomErrorWidget(
              message: routineProvider.error!,
              onRetry: _loadInitialData,
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 오늘의 루틴 섹션
                  _buildTodayRoutinesSection(routineProvider),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 완료 현황
                  _buildCompletionSummary(routineProvider),
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
              const CreateRoutineScreen(),
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

  Widget _buildTodayRoutinesSection(RoutineProvider routineProvider) {
    final todayRoutines = routineProvider.todayRoutines;
    final activeRoutines = todayRoutines.where((r) => !r.completedToday).toList();
    final completedRoutines = todayRoutines.where((r) => r.completedToday).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.todayRoutines,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (todayRoutines.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: Text(
                  '${completedRoutines.length}/${todayRoutines.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),

        if (todayRoutines.isEmpty)
          FadeInWidget(
            delay: const Duration(milliseconds: 400),
            child: Card(
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
                        '루틴이 없습니다',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        '새로운 루틴을 추가해보세요!',
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

        // 활성 루틴
        if (activeRoutines.isNotEmpty) ...[
          Text(
            '진행 중',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryColor,
                ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          ...activeRoutines.map((routine) => RoutineCard(
                routine: routine,
                onTap: () {
                  Navigator.of(context).pushWithSlideAndFade(
                    RoutineDetailScreen(routine: routine),
                  );
                },
                onCompleteToggle: (completed) async {
                  if (completed) {
                    await routineProvider.completeRoutine(routine.id!);
                  } else {
                    await routineProvider.uncompleteRoutine(routine.id!);
                  }
                  await routineProvider.loadTodayRoutines();
                },
                onEdit: () async {
                  final result = await Navigator.of(context).pushWithSlideFromRight(
                    CreateRoutineScreen(editRoutine: routine),
                  );
                  if (result == true) {
                    _loadInitialData();
                  }
                },
                onDelete: () => _showDeleteConfirmDialog(context, routine),
              )),
        ],

        // 완료된 루틴
        if (completedRoutines.isNotEmpty) ...[
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
                '오늘 완료한 루틴',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.successColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          ...completedRoutines.map((routine) => Opacity(
                opacity: 0.7,
                child: RoutineCard(
                  routine: routine,
                  onTap: () {
                    Navigator.of(context).pushWithSlideAndFade(
                      RoutineDetailScreen(routine: routine),
                    );
                  },
                  onCompleteToggle: (completed) async {
                    if (completed) {
                      await routineProvider.completeRoutine(routine.id!);
                    } else {
                      await routineProvider.uncompleteRoutine(routine.id!);
                    }
                    await routineProvider.loadTodayRoutines();
                  },
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildCompletionSummary(RoutineProvider routineProvider) {
    final todayRoutines = routineProvider.todayRoutines;
    final completedCount = todayRoutines.where((r) => r.completedToday).length;
    final totalCount = todayRoutines.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 달성률',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '완료',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$completedCount/$totalCount',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryColor,
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
                  backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  minHeight: 8,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, Routine routine) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('루틴 삭제'),
        content: Text('\'${routine.title}\' 루틴을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final routineProvider = context.read<RoutineProvider>();
      await routineProvider.deleteRoutine(routine.id!);
      await routineProvider.loadTodayRoutines();
    }
  }
}
