import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/routine_provider.dart';
import '../../../data/models/routine.dart';

class CreateRoutineScreen extends StatefulWidget {
  final Routine? editRoutine;

  const CreateRoutineScreen({super.key, this.editRoutine});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  RoutineFrequency _selectedFrequency = RoutineFrequency.daily;

  bool get isEditMode => widget.editRoutine != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _titleController.text = widget.editRoutine!.title;
      _descriptionController.text = widget.editRoutine!.description ?? '';
      _selectedFrequency = widget.editRoutine!.frequency;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final routineProvider = context.read<RoutineProvider>();

    final routine = Routine(
      id: widget.editRoutine?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      frequency: _selectedFrequency,
    );

    bool success;
    if (isEditMode) {
      success = await routineProvider.updateRoutine(widget.editRoutine!.id!, routine);
    } else {
      success = await routineProvider.createRoutine(routine);
    }

    if (success && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(routineProvider.error ?? '루틴 저장에 실패했습니다'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '루틴 편집' : AppStrings.addNewRoutine),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            // 루틴 제목
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppStrings.routineTitle,
                hintText: '예: 아침 조깅, 영어 공부',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '루틴 제목을 입력해주세요';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // 루틴 메모
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppStrings.routineDescription,
                hintText: '간단한 메모를 입력하세요 (선택사항)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // 반복 주기 선택
            Text(
              AppStrings.routineFrequency,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            _buildFrequencySelector(),
            const SizedBox(height: AppSizes.paddingXLarge),

            // 저장 버튼
            ElevatedButton(
              onPressed: _saveRoutine,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              child: Text(
                isEditMode ? '수정 완료' : AppStrings.save,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      children: RoutineFrequency.values.map((frequency) {
        final isSelected = _selectedFrequency == frequency;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFrequency = frequency;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: isSelected
                  ? frequency.color.withOpacity(0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? frequency.color : AppColors.dividerColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(
                  frequency.icon,
                  color: isSelected ? frequency.color : AppColors.textSecondaryColor,
                  size: 28,
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        frequency.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? frequency.color
                                  : AppColors.textPrimaryColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getFrequencyDescription(frequency),
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
                    color: frequency.color,
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getFrequencyDescription(RoutineFrequency frequency) {
    switch (frequency) {
      case RoutineFrequency.daily:
        return '매일 반복되는 루틴';
      case RoutineFrequency.weekly:
        return '주간 반복되는 루틴';
      case RoutineFrequency.monthly:
        return '월간 반복되는 루틴';
    }
  }
}
