import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/goal.dart';
import '../animations/animated_card.dart';

enum GoalCardDisplayMode {
  normal,   // 기본 스타일 (현재)
  compact,  // 한 줄 컴팩트
  list,     // 리스트 스타일
  minimal,  // 최소 정보만
}

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  final Function(Goal)? onCompleteToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showProgress;
  final bool showSubGoals;
  final bool isSubGoal;
  final GoalCardDisplayMode displayMode;
  final EdgeInsets? margin;
  final bool enableAnimation;

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
    this.displayMode = GoalCardDisplayMode.normal,
    this.margin,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (displayMode) {
      case GoalCardDisplayMode.compact:
        return _buildCompactMode(context);
      case GoalCardDisplayMode.list:
        return _buildListMode(context);
      case GoalCardDisplayMode.minimal:
        return _buildMinimalMode(context);
      case GoalCardDisplayMode.normal:
      default:
        return _buildNormalMode(context);
    }
  }

  Widget _buildNormalMode(BuildContext context) {
    final card = Card(
        margin: margin ?? const EdgeInsets.symmetric(
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
      );

    return enableAnimation
        ? AnimatedGoalCard(onTap: onTap, child: card)
        : GestureDetector(onTap: onTap, child: card);
  }

  Widget _buildCompactMode(BuildContext context) {
    return AnimatedGoalCard(
      onTap: onTap,
      child: Card(
        margin: margin ?? const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: 2,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSmall,
            vertical: 8,
          ),
          child: Row(
            children: [
              // 체크박스
              if (onCompleteToggle != null)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Checkbox(
                    value: goal.isCompleted,
                    onChanged: (_) => onCompleteToggle!(goal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                  ),
                ),
              const SizedBox(width: 8),

              // 제목
              Expanded(
                child: Text(
                  goal.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: goal.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: goal.isCompleted
                        ? AppColors.textSecondaryColor
                        : AppColors.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 타입 칩
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getGoalTypeColor(goal.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  goal.type.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getGoalTypeColor(goal.type),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),

              // 마감일
              if (goal.dueDate != null) ...[
                const SizedBox(width: 8),
                Text(
                  DateFormat('MM/dd').format(goal.dueDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getDueDateColor(goal.dueDate!),
                    fontSize: 11,
                  ),
                ),
              ],

              // 메뉴
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(width: 4),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
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
                              Icon(Icons.edit, size: 18),
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
                              Icon(Icons.delete, size: 18),
                              SizedBox(width: 8),
                              Text('삭제'),
                            ],
                          ),
                        ),
                    ],
                    child: const Icon(Icons.more_vert, size: 18),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListMode(BuildContext context) {
    return AnimatedGoalCard(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // 체크박스
            if (onCompleteToggle != null)
              SizedBox(
                width: 32,
                height: 32,
                child: Checkbox(
                  value: goal.isCompleted,
                  onChanged: (_) => onCompleteToggle!(goal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                ),
              ),
            const SizedBox(width: 12),

            // 제목과 메타정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: goal.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: goal.isCompleted
                          ? AppColors.textSecondaryColor
                          : AppColors.textPrimaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // 타입
                      Text(
                        goal.type.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getGoalTypeColor(goal.type),
                          fontSize: 11,
                        ),
                      ),

                      // 마감일
                      if (goal.dueDate != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MM/dd').format(goal.dueDate!),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getDueDateColor(goal.dueDate!),
                            fontSize: 11,
                          ),
                        ),
                      ],

                      // 진행률
                      if (showProgress && goal.subGoals.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: goal.progressPercentage / 100,
                            backgroundColor: AppColors.dividerColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getGoalTypeColor(goal.type),
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${goal.progressPercentage.toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // 메뉴
            if (onEdit != null || onDelete != null)
              SizedBox(
                width: 32,
                height: 32,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
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
                            Icon(Icons.edit, size: 18),
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
                            Icon(Icons.delete, size: 18),
                            SizedBox(width: 8),
                            Text('삭제'),
                          ],
                        ),
                      ),
                  ],
                  child: const Icon(Icons.more_vert, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalMode(BuildContext context) {
    return AnimatedGoalCard(
      onTap: onTap,
      child: Card(
        margin: margin ?? const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSmall,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 체크박스
                  if (onCompleteToggle != null)
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Checkbox(
                        value: goal.isCompleted,
                        onChanged: (_) => onCompleteToggle!(goal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                  if (onCompleteToggle != null)
                    const SizedBox(width: 8),

                  // 제목
                  Expanded(
                    child: Text(
                      goal.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: goal.isCompleted
                            ? AppColors.textSecondaryColor
                            : AppColors.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // 메뉴
                  if (onEdit != null || onDelete != null)
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
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
                                  Icon(Icons.edit, size: 18),
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
                                  Icon(Icons.delete, size: 18),
                                  SizedBox(width: 8),
                                  Text('삭제'),
                                ],
                              ),
                            ),
                        ],
                        child: const Icon(Icons.more_vert, size: 18),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 6),

              // 메타 정보만
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getGoalTypeColor(goal.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      goal.type.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getGoalTypeColor(goal.type),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  if (goal.priority > 1) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.failedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '높음',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.failedColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  if (goal.dueDate != null)
                    Text(
                      DateFormat('MM/dd').format(goal.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getDueDateColor(goal.dueDate!),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
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