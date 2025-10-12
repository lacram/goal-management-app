import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/goal.dart';
import '../animations/animated_card.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  final Function(Goal)? onCompleteToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showProgress;
  final bool showSubGoals;
  final bool isSubGoal;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onCompleteToggle,
    this.onEdit,
    this.onDelete,
    this.showProgress = true,
    this.showSubGoals = false,
    this.isSubGoal = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedGoalCard(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (제목, 타입, 액션)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 완료 체크박스
                  if (onCompleteToggle != null)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSizes.paddingSmall),
                      child: Checkbox(
                        value: goal.isCompleted,
                        onChanged: (_) => onCompleteToggle!(goal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                  
                  // 제목과 설명
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: goal.isCompleted 
                                ? TextDecoration.lineThrough 
                                : TextDecoration.none,
                            color: goal.isCompleted 
                                ? AppColors.textSecondaryColor 
                                : AppColors.textPrimaryColor,
                          ),
                        ),
                        if (goal.description != null && goal.description!.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.paddingSmall),
                          Text(
                            goal.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // 액션 버튼들
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('편집'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('삭제'),
                              ],
                            ),
                          ),
                      ],
                      child: const Icon(Icons.more_vert),
                    ),
                ],
              ),
              
              const SizedBox(height: AppSizes.paddingMedium),
              
              // 메타 정보 (타입, 마감일, 진행률)
              Row(
                children: [
                  // 목표 타입 칩
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getGoalTypeColor(goal.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      goal.type.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getGoalTypeColor(goal.type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: AppSizes.paddingSmall),
                  
                  // 우선순위
                  if (goal.priority > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.failedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Text(
                        '높음',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.failedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // 마감일
                  if (goal.dueDate != null)
                    Text(
                      DateFormat('MM/dd').format(goal.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getDueDateColor(goal.dueDate!),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              
              // 진행률 (하위 목표가 있는 경우)
              if (showProgress && goal.subGoals.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingMedium),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: goal.progressPercentage / 100,
                        backgroundColor: AppColors.dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getGoalTypeColor(goal.type),
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    Text(
                      '${goal.progressPercentage.toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getGoalTypeColor(GoalType type) {
    switch (type) {
      case GoalType.lifetime:
        return AppColors.lifetimeColor;
      case GoalType.lifetimeSub:
        return AppColors.lifetimeSubColor;
      case GoalType.yearly:
        return AppColors.yearlyColor;
      case GoalType.monthly:
        return AppColors.monthlyColor;
      case GoalType.weekly:
        return AppColors.weeklyColor;
      case GoalType.daily:
        return AppColors.dailyColor;
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return AppColors.failedColor; // 지난 마감일
    } else if (difference <= 1) {
      return AppColors.postponedColor; // 임박한 마감일
    } else {
      return AppColors.textSecondaryColor; // 일반 마감일
    }
  }
}