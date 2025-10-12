import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/goal_provider.dart';
import '../../../data/models/goal.dart';
import '../../widgets/common/loading_widget.dart';

class CreateGoalScreen extends StatefulWidget {
  final Goal? parentGoal;
  final Goal? editGoal;
  final GoalType? initialType;

  const CreateGoalScreen({
    super.key,
    this.parentGoal,
    this.editGoal,
    this.initialType,
  });

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  GoalType _selectedType = GoalType.daily;
  Goal? _selectedParentGoal;
  DateTime? _selectedDueDate;
  int _selectedPriority = 1;
  bool _reminderEnabled = false;
  String? _reminderFrequency;
  
  List<GoalType> _availableTypes = GoalType.values;
  List<Goal> _parentGoals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeData() {
    // 편집 모드인 경우 기존 데이터로 초기화
    if (widget.editGoal != null) {
      final goal = widget.editGoal!;
      _titleController.text = goal.title;
      _descriptionController.text = goal.description ?? '';
      _selectedType = goal.type;
      _selectedDueDate = goal.dueDate;
      _selectedPriority = goal.priority;
      _reminderEnabled = goal.reminderEnabled;
      _reminderFrequency = goal.reminderFrequency;
    } else if (widget.initialType != null) {
      // 초기 타입이 지정된 경우
      _selectedType = widget.initialType!;
    }

    // 상위 목표가 지정된 경우
    if (widget.parentGoal != null) {
      _selectedParentGoal = widget.parentGoal;
      _loadAvailableSubTypes();
    } else {
      _loadParentGoals();
    }
  }

  Future<void> _loadAvailableSubTypes() async {
    if (_selectedParentGoal != null) {
      final goalProvider = context.read<GoalProvider>();
      final types = await goalProvider.getAvailableSubTypes(_selectedParentGoal!.type);
      setState(() {
        _availableTypes = types;
        if (types.isNotEmpty && !types.contains(_selectedType)) {
          _selectedType = types.first;
        }
      });
    }
  }

  Future<void> _loadParentGoals() async {
    final goalProvider = context.read<GoalProvider>();
    await goalProvider.loadAllGoals();
    setState(() {
      // 완료되지 않은 목표들만 상위 목표로 선택 가능
      _parentGoals = goalProvider.goals
          .where((goal) => !goal.isCompleted)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editGoal != null ? '목표 편집' : '새 목표'),
        actions: [
          if (widget.editGoal != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          if (_isLoading) {
            return const LoadingWidget(message: '목표를 저장하는 중...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 목표 제목
                  _buildTitleField(),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 목표 설명
                  _buildDescriptionField(),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 목표 타입
                  _buildTypeSelector(),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 상위 목표 (편집 모드가 아닌 경우만)
                  if (widget.editGoal == null) ...[
                    _buildParentGoalSelector(),
                    const SizedBox(height: AppSizes.paddingLarge),
                  ],

                  // 마감일
                  _buildDueDatePicker(),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 우선순위
                  _buildPrioritySelector(),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // 알림 설정
                  _buildReminderSettings(),
                  const SizedBox(height: AppSizes.paddingXLarge),

                  // 저장 버튼
                  _buildSaveButton(goalProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.goalTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '예: 매일 운동하기',
            prefixIcon: Icon(Icons.flag),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '목표 제목을 입력해주세요';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.goalDescription,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: '목표에 대한 자세한 설명을 입력하세요 (선택사항)',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.goalType,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              children: _availableTypes.map((type) {
                return RadioListTile<GoalType>(
                  title: Text(type.displayName),
                  subtitle: Text(_getTypeDescription(type)),
                  value: type,
                  groupValue: _selectedType,
                  onChanged: (GoalType? value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                  activeColor: type.color,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParentGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.parentGoal,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_tree),
            title: Text(_selectedParentGoal?.title ?? '상위 목표 없음'),
            subtitle: Text(_selectedParentGoal != null 
                ? '${_selectedParentGoal!.type.displayName} 목표'
                : '독립적인 목표로 생성됩니다'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showParentGoalSelector,
          ),
        ),
      ],
    );
  }

  Widget _buildDueDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.dueDate,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(_selectedDueDate != null 
                ? '${_selectedDueDate!.year}년 ${_selectedDueDate!.month}월 ${_selectedDueDate!.day}일'
                : '마감일 설정 없음'),
            subtitle: Text(_selectedDueDate != null 
                ? '마감일이 설정되었습니다'
                : '마감일을 설정하려면 탭하세요'),
            trailing: _selectedDueDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                      });
                    },
                  )
                : const Icon(Icons.arrow_forward_ios),
            onTap: _pickDueDate,
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.priority,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.priority_high),
                    const SizedBox(width: AppSizes.paddingSmall),
                    Expanded(
                      child: Text('우선순위: ${_getPriorityText(_selectedPriority)}'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Slider(
                  value: _selectedPriority.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _getPriorityText(_selectedPriority),
                  onChanged: (double value) {
                    setState(() {
                      _selectedPriority = value.toInt();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '알림 설정',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('알림 활성화'),
                subtitle: Text(_reminderEnabled 
                    ? '목표 리마인더를 받습니다'
                    : '알림을 받지 않습니다'),
                value: _reminderEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _reminderEnabled = value;
                    if (!value) {
                      _reminderFrequency = null;
                    }
                  });
                },
              ),
              if (_reminderEnabled) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(_reminderFrequency ?? '알림 주기 선택'),
                  subtitle: const Text('알림을 받을 주기를 선택하세요'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showReminderFrequencyDialog,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(GoalProvider goalProvider) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: () => _saveGoal(goalProvider),
        icon: Icon(widget.editGoal != null ? Icons.save : Icons.add),
        label: Text(widget.editGoal != null ? AppStrings.save : '목표 생성'),
      ),
    );
  }

  // 헬퍼 메서드들
  String _getTypeDescription(GoalType type) {
    switch (type) {
      case GoalType.lifetime:
        return '평생에 걸쳐 달성하고자 하는 목표';
      case GoalType.lifetimeSub:
        return '평생 목표를 달성하기 위한 하위 목표';
      case GoalType.yearly:
        return '1년 안에 달성할 목표';
      case GoalType.monthly:
        return '1개월 안에 달성할 목표';
      case GoalType.weekly:
        return '1주일 안에 달성할 목표';
      case GoalType.daily:
        return '하루 안에 달성할 목표';
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '낮음';
      case 2:
        return '보통';
      case 3:
        return '중간';
      case 4:
        return '높음';
      case 5:
        return '매우 높음';
      default:
        return '보통';
    }
  }

  // 액션 메서드들
  void _showParentGoalSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '상위 목표 선택',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedParentGoal = null;
                        _availableTypes = GoalType.values;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('없음'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _parentGoals.length,
                itemBuilder: (context, index) {
                  final goal = _parentGoals[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: goal.type.color,
                      child: Icon(
                        Icons.flag,
                        color: Colors.white,
                        size: AppSizes.iconSmall,
                      ),
                    ),
                    title: Text(goal.title),
                    subtitle: Text(goal.type.displayName),
                    onTap: () {
                      setState(() {
                        _selectedParentGoal = goal;
                      });
                      _loadAvailableSubTypes();
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _showReminderFrequencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 주기 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'DAILY',
            'WEEKLY',
            'MONTHLY',
          ].map((frequency) => RadioListTile<String>(
            title: Text(_getFrequencyDisplayName(frequency)),
            value: frequency,
            groupValue: _reminderFrequency,
            onChanged: (String? value) {
              setState(() {
                _reminderFrequency = value;
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  String _getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case 'DAILY':
        return '매일';
      case 'WEEKLY':
        return '매주';
      case 'MONTHLY':
        return '매월';
      default:
        return frequency;
    }
  }

  Future<void> _saveGoal(GoalProvider goalProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final goal = Goal(
        id: widget.editGoal?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        type: _selectedType,
        parentGoalId: _selectedParentGoal?.id,
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
        reminderEnabled: _reminderEnabled,
        reminderFrequency: _reminderFrequency,
      );

      bool success;
      if (widget.editGoal != null) {
        success = await goalProvider.updateGoal(widget.editGoal!.id!, goal);
      } else {
        success = await goalProvider.createGoal(goal);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editGoal != null 
                ? '목표가 수정되었습니다!' 
                : '새 목표가 생성되었습니다!'),
            backgroundColor: AppColors.activeColor,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(goalProvider.error ?? '오류가 발생했습니다'),
            backgroundColor: AppColors.failedColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppColors.failedColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 삭제'),
        content: const Text('이 목표를 삭제하시겠습니까?\n삭제된 목표는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteGoal();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.failedColor,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal() async {
    if (widget.editGoal?.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final goalProvider = context.read<GoalProvider>();
      final success = await goalProvider.deleteGoal(widget.editGoal!.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('목표가 삭제되었습니다'),
            backgroundColor: AppColors.activeColor,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(goalProvider.error ?? '삭제 중 오류가 발생했습니다'),
            backgroundColor: AppColors.failedColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppColors.failedColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
