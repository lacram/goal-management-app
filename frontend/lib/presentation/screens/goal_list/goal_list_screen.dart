import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/goal_provider.dart';
import '../../../data/models/goal.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/goal_widgets/goal_card.dart';
import '../../widgets/goal_widgets/goal_tree_view.dart';
import '../goal/create_goal_screen.dart';
import '../goal/goal_detail_screen.dart';

class GoalListScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const GoalListScreen({super.key, this.initialTabIndex = 0});

  @override
  State<GoalListScreen> createState() => _GoalListScreenState();
}

class _GoalListScreenState extends State<GoalListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  GoalType? _selectedType;
  GoalStatus? _selectedStatus;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.createdAtDesc;
  GoalCardDisplayMode _displayMode = GoalCardDisplayMode.compact; // 컴팩트 모드를 기본값으로 설정

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    // 빌드 완료 후 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final goalProvider = context.read<GoalProvider>();
    await goalProvider.loadAllGoals();
  }

  Future<void> _refreshData() async {
    final goalProvider = context.read<GoalProvider>();
    await goalProvider.refreshAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 목표'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_agenda),
            tooltip: '표시 모드',
            onPressed: _showDisplayModeSelector,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체', icon: Icon(Icons.list)),
            Tab(text: '진행중', icon: Icon(Icons.play_arrow)),
            Tab(text: '완료', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          if (goalProvider.isLoading && goalProvider.allGoals.isEmpty) {
            return const LoadingWidget();
          }

          if (goalProvider.error != null) {
            return CustomErrorWidget(
              message: goalProvider.error!,
              onRetry: _loadData,
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTreeView(goalProvider.allGoals), // 전체 탭은 트리 뷰
              _buildGoalsList(goalProvider.activeGoals),
              _buildGoalsList(goalProvider.completedGoals),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGoalScreen(),
            ),
          );

          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTreeView(List<Goal> goals) {
    List<Goal> filteredGoals = _applyFilters(goals);

    if (filteredGoals.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: _buildSummaryCard(filteredGoals),
          ),
          Expanded(
            child: GoalTreeView(
              goals: filteredGoals,
              displayMode: _displayMode,
              onTap: _navigateToGoalDetail,
              onCompleteToggle: _toggleGoalCompletion,
              onEdit: _editGoal,
              onDelete: _deleteGoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(List<Goal> goals) {
    List<Goal> filteredGoals = _applyFilters(goals);

    if (filteredGoals.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: filteredGoals.length + 1, // +1 for summary card
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSizes.paddingSmall),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSummaryCard(filteredGoals);
          }

          final goal = filteredGoals[index - 1];
          return GoalCard(
            goal: goal,
            displayMode: _displayMode,
            onTap: () => _navigateToGoalDetail(goal),
            onCompleteToggle: (goal) => _toggleGoalCompletion(goal),
            onEdit: () => _editGoal(goal),
            onDelete: () => _deleteGoal(goal),
            showProgress: true,
            showSubGoals: true,
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Goal> goals) {
    final completedCount = goals.where((goal) => goal.isCompleted).length;
    final totalCount = goals.length;
    final progressPercent = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '목표 현황',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('전체', totalCount, AppColors.primaryColor),
                _buildStatItem('완료', completedCount, AppColors.successColor),
                _buildStatItem(
                  '진행중',
                  totalCount - completedCount,
                  AppColors.warningColor,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            LinearProgressIndicator(
              value: progressPercent,
              backgroundColor: AppColors.primaryColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              minHeight: 8,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              '달성률: ${(progressPercent * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: AppColors.textSecondaryColor,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            Text(
              '목표가 없습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              '새로운 목표를 추가해서 시작해보세요!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGoalScreen(),
                  ),
                );

                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('목표 추가'),
            ),
          ],
        ),
      ),
    );
  }

  List<Goal> _applyFilters(List<Goal> goals) {
    List<Goal> filtered = List.from(goals);

    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((goal) {
        return goal.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (goal.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // 타입 필터
    if (_selectedType != null) {
      filtered = filtered.where((goal) => goal.type == _selectedType).toList();
    }

    // 상태 필터
    if (_selectedStatus != null) {
      filtered = filtered.where((goal) => goal.status == _selectedStatus).toList();
    }

    // 정렬
    switch (_sortOption) {
      case SortOption.titleAsc:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleDesc:
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.createdAtAsc:
        filtered.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
        break;
      case SortOption.createdAtDesc:
        filtered.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        break;
      case SortOption.dueDate:
        filtered.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortOption.priority:
        filtered.sort((a, b) => b.priority.compareTo(a.priority));
        break;
    }

    return filtered;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 검색'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '목표 제목 또는 설명을 입력하세요',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('초기화'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('필터'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '목표 타입',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              DropdownButton<GoalType?>(
                value: _selectedType,
                isExpanded: true,
                hint: const Text('모든 타입'),
                items: [
                  const DropdownMenuItem<GoalType?>(
                    value: null,
                    child: Text('모든 타입'),
                  ),
                  ...GoalType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  )),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Text(
                '목표 상태',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              DropdownButton<GoalStatus?>(
                value: _selectedStatus,
                isExpanded: true,
                hint: const Text('모든 상태'),
                items: [
                  const DropdownMenuItem<GoalStatus?>(
                    value: null,
                    child: Text('모든 상태'),
                  ),
                  ...GoalStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  )),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    _selectedStatus = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _selectedType = null;
                  _selectedStatus = null;
                });
                setState(() {
                  _selectedType = null;
                  _selectedStatus = null;
                });
                Navigator.pop(context);
              },
              child: const Text('초기화'),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('적용'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정렬'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SortOption.values.map((option) {
            return RadioListTile<SortOption>(
              title: Text(option.displayName),
              value: option,
              groupValue: _sortOption,
              onChanged: (value) {
                setState(() {
                  _sortOption = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _navigateToGoalDetail(Goal goal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(goal: goal),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _toggleGoalCompletion(Goal goal) async {
    final goalProvider = context.read<GoalProvider>();
    if (goal.isCompleted) {
      await goalProvider.uncompleteGoal(goal.id!);
    } else {
      await goalProvider.completeGoal(goal.id!);
    }
  }

  void _editGoal(Goal goal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGoalScreen(editGoal: goal),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _deleteGoal(Goal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 삭제'),
        content: Text('정말로 "${goal.title}" 목표를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorColor,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final goalProvider = context.read<GoalProvider>();
      await goalProvider.deleteGoal(goal.id!);
    }
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

enum SortOption {
  titleAsc('제목 오름차순'),
  titleDesc('제목 내림차순'),
  createdAtAsc('생성일 오름차순'),
  createdAtDesc('생성일 내림차순'),
  dueDate('마감일 순'),
  priority('우선순위 순');

  const SortOption(this.displayName);
  final String displayName;
}
