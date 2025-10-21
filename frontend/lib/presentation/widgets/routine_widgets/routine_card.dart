import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/routine.dart';
import '../animations/animated_card.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback? onTap;
  final Function(bool)? onCompleteToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final EdgeInsetsGeometry? margin;

  const RoutineCard({
    super.key,
    required this.routine,
    this.onTap,
    this.onCompleteToggle,
    this.onEdit,
    this.onDelete,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedGoalCard(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: AppSizes.paddingSmall),
        child: Card(
          color: routine.completedToday
              ? Colors.grey[100]
              : AppColors.cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            side: BorderSide(
              color: routine.frequency.color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                children: [
                  // 완료 체크박스
                  _buildCheckbox(context),
                  const SizedBox(width: AppSizes.paddingMedium),

                  // 루틴 정보
                  Expanded(
                    child: _buildRoutineInfo(context),
                  ),

                  // 주기 아이콘
                  _buildFrequencyIcon(),

                  // 액션 버튼들
                  if (onEdit != null || onDelete != null)
                    _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: () => onCompleteToggle?.call(!routine.completedToday),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: routine.completedToday
              ? routine.frequency.color
              : Colors.transparent,
          border: Border.all(
            color: routine.completedToday
                ? routine.frequency.color
                : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: routine.completedToday
            ? const Icon(
                Icons.check,
                size: 20,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildRoutineInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 루틴 제목
        Text(
          routine.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                decoration: routine.completedToday
                    ? TextDecoration.lineThrough
                    : null,
                color: routine.completedToday
                    ? AppColors.textSecondaryColor
                    : AppColors.textPrimaryColor,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // 루틴 설명 (있는 경우)
        if (routine.description != null && routine.description!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            routine.description!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryColor,
                  decoration: routine.completedToday
                      ? TextDecoration.lineThrough
                      : null,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // 주기 텍스트
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              routine.frequency.icon,
              size: 14,
              color: routine.frequency.color,
            ),
            const SizedBox(width: 4),
            Text(
              routine.frequency.displayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: routine.frequency.color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequencyIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: routine.frequency.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Icon(
        routine.frequency.icon,
        color: routine.frequency.color,
        size: 24,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: AppColors.textSecondaryColor,
            onPressed: onEdit,
            tooltip: AppStrings.edit,
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            color: AppColors.errorColor,
            onPressed: onDelete,
            tooltip: AppStrings.delete,
          ),
      ],
    );
  }
}
