import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/goal_provider.dart';
import '../../../data/models/goal.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/goal_widgets/goal_card.dart';
import '../goal/create_goal_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({
    super.key,
    required this.goal,
  });

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late Goal _currentGoal;
  List<Goal> _subGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentGoal = widget.goal;
    _loadGoalDetails();
  }

  Future<void> _loadGoalDetails() async {
    setState(() => _isLoading = true);
    
    try {
      final goalProvider = context.read<GoalProvider>();
      
      // 최신 목표 정보 로드
      _currentGoal = await goalProvider.apiService.getGoal(_currentGoal.id!);
      
      // 하위 목표들 로드
      _subGoals = await goalProvider.apiService.getGoalChildren(_currentGoal.id!);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('목표 정보를 불러오는데 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('목표 상세'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editGoal,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteGoal();
                  break;
                case 'add_sub':
                  _addSubGoal();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_sub',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 8),
                    Text('하위 목표 추가'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('삭제', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadGoalDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 목표 기본 정보
                    _buildGoalInfoCard(),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // 진행률 정보
                    _buildProgressCard(),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // 목표 상태 및 액션
                    _buildStatusCard(),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // 하위 목표들
                    if (_subGoals.isNotEmpty || _canHaveSubGoals())
                      _buildSubGoalsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGoalInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목과 타입
            Row(
              children: [
                Expanded(
                  child: Text(
                    _currentGoal.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _currentGoal.type.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Text(
                    _currentGoal.type.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _currentGoal.type.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // 설명
            if (_currentGoal.description != null && _currentGoal.description!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.paddingMedium),
              Text(
                _currentGoal.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],

            const SizedBox(height: AppSizes.paddingLarge),

            // 목표 정보 그리드
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '우선순위',
                    _getPriorityText(_currentGoal.priority),
                    Icons.flag,
                    _getPriorityColor(_currentGoal.priority),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: _buildInfoItem(
                    '상태',
                    _currentGoal.status.displayName,
                    Icons.info,
                    _getStatusColor(_currentGoal.status),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '생성일',
                    _formatDate(_currentGoal.createdAt ?? DateTime.now()),
                    Icons.calendar_today,
                    AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: _buildInfoItem(
                    '마감일',
                    _currentGoal.dueDate != null 
                        ? _formatDate(_currentGoal.dueDate!)
                        : '설정 안함',
                    Icons.schedule,
                    _currentGoal.dueDate != null
                        ? (_currentGoal.dueDate!.isBefore(DateTime.now())
                            ? AppColors.errorColor
                            : AppColors.textSecondaryColor)
                        : AppColors.textSecondaryColor,
                  ),
                ),
              ],
            ),

            if (_currentGoal.completedAt != null) ...[
              const SizedBox(height: AppSizes.paddingMedium),
              _buildInfoItem(
                '완료일',
                _formatDate(_currentGoal.completedAt!),
                Icons.check_circle,
                AppColors.successColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final progressPercent = _currentGoal.progressPercentage / 100;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '진행률',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            
            // 진행률 바
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _currentGoal.isCompleted 
                          ? AppColors.successColor 
                          : AppColors.primaryColor,
                    ),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Text(
                  '${(progressPercent * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _currentGoal.isCompleted 
                        ? AppColors.successColor 
                        : AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSizes.paddingMedium),
            
            // 하위 목표 통계
            if (_subGoals.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '하위 목표',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${_subGoals.where((g) => g.isCompleted).length}/${_subGoals.length} 완료',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ] else if (_currentGoal.isCompleted) ...[
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.successColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '목표 달성 완료!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '목표 관리',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleCompletion,
                    icon: Icon(
                      _currentGoal.isCompleted 
                          ? Icons.restart_alt 
                          : Icons.check_circle,
                    ),
                    label: Text(
                      _currentGoal.isCompleted ? '완료 취소' : '완료 처리',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentGoal.isCompleted 
                          ? AppColors.warningColor 
                          : AppColors.successColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _editGoal,
                    icon: const Icon(Icons.edit),
                    label: const Text('편집'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '하위 목표',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_canHaveSubGoals())
              TextButton.icon(
                onPressed: _addSubGoal,
                icon: const Icon(Icons.add),
                label: const Text('추가'),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        
        if (_subGoals.isEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.add_task,
                      size: 48,
                      color: AppColors.textSecondaryColor,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    Text(
                      '하위 목표가 없습니다',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    if (_canHaveSubGoals()) ...[
                      Text(
                        '하위 목표를 추가해보세요!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      ElevatedButton.icon(
                        onPressed: _addSubGoal,
                        icon: const Icon(Icons.add),
                        label: const Text('하위 목표 추가'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          ...List.generate(_subGoals.length, (index) {
            final subGoal = _subGoals[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _subGoals.length - 1 
                    ? AppSizes.paddingSmall 
                    : 0,
              ),
              child: GoalCard(
                goal: subGoal,
                onTap: () => _navigateToSubGoal(subGoal),
                onCompleteToggle: (goal) => _toggleSubGoalCompletion(goal),
                onEdit: () => _editSubGoal(subGoal),
                onDelete: () => _deleteSubGoal(subGoal),
                showProgress: true,
                isSubGoal: true,
              ),
            );
          }),
        ],
      ],
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '낮음';
      case 2:
        return '보통';
      case 3:
        return '높음';
      default:
        return '보통';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.successColor;
      case 2:
        return AppColors.warningColor;
      case 3:
        return AppColors.errorColor;
      default:
        return AppColors.warningColor;
    }
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return AppColors.primaryColor;
      case GoalStatus.completed:
        return AppColors.successColor;
      case GoalStatus.expired:
        return AppColors.errorColor;
      case GoalStatus.archived:
        return const Color(0xFF6B7280); // Gray
      case GoalStatus.failed:
        return AppColors.errorColor;
      case GoalStatus.postponed:
        return AppColors.warningColor;
    }
  }

  bool _canHaveSubGoals() {
    return _currentGoal.type != GoalType.daily;
  }

  // Action methods
  Future<void> _toggleCompletion() async {
    try {
      final goalProvider = context.read<GoalProvider>();
      if (_currentGoal.isCompleted) {
        await goalProvider.uncompleteGoal(_currentGoal.id!);
      } else {
        await goalProvider.completeGoal(_currentGoal.id!);
      }
      await _loadGoalDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('목표 상태 변경에 실패했습니다: $e')),
        );
      }
    }
  }

  void _editGoal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGoalScreen(editGoal: _currentGoal),
      ),
    );

    if (result == true) {
      await _loadGoalDetails();
    }
  }

  void _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 삭제'),
        content: Text('정말로 "${_currentGoal.title}" 목표를 삭제하시겠습니까?'),
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
      try {
        final goalProvider = context.read<GoalProvider>();
        await goalProvider.deleteGoal(_currentGoal.id!);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('목표 삭제에 실패했습니다: $e')),
          );
        }
      }
    }
  }

  void _addSubGoal() async {
    if (!_canHaveSubGoals()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일간 목표는 하위 목표를 가질 수 없습니다')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGoalScreen(parentGoal: _currentGoal),
      ),
    );

    if (result == true) {
      await _loadGoalDetails();
    }
  }

  void _navigateToSubGoal(Goal subGoal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(goal: subGoal),
      ),
    );

    if (result == true) {
      await _loadGoalDetails();
    }
  }

  Future<void> _toggleSubGoalCompletion(Goal subGoal) async {
    try {
      final goalProvider = context.read<GoalProvider>();
      if (subGoal.isCompleted) {
        await goalProvider.uncompleteGoal(subGoal.id!);
      } else {
        await goalProvider.completeGoal(subGoal.id!);
      }
      await _loadGoalDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('하위 목표 상태 변경에 실패했습니다: $e')),
        );
      }
    }
  }

  void _editSubGoal(Goal subGoal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGoalScreen(editGoal: subGoal),
      ),
    );

    if (result == true) {
      await _loadGoalDetails();
    }
  }

  void _deleteSubGoal(Goal subGoal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('하위 목표 삭제'),
        content: Text('정말로 "${subGoal.title}" 하위 목표를 삭제하시겠습니까?'),
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
      try {
        final goalProvider = context.read<GoalProvider>();
        await goalProvider.deleteGoal(subGoal.id!);
        await _loadGoalDetails();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('하위 목표 삭제에 실패했습니다: $e')),
          );
        }
      }
    }
  }
}
