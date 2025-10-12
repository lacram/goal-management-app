import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/goal.dart';
import '../goal_widgets/goal_card.dart';

class GoalTreeView extends StatefulWidget {
  final List<Goal> goals;
  final Function(Goal)? onTap;
  final Function(Goal)? onCompleteToggle;
  final Function(Goal)? onEdit;
  final Function(Goal)? onDelete;

  const GoalTreeView({
    super.key,
    required this.goals,
    this.onTap,
    this.onCompleteToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<GoalTreeView> createState() => _GoalTreeViewState();
}

class _GoalTreeViewState extends State<GoalTreeView> {
  final Set<int> _expandedGoals = {};

  @override
  Widget build(BuildContext context) {
    // 최상위 목표들만 필터링 (parentGoalId가 null인 것들)
    final rootGoals = widget.goals.where((goal) => goal.parentGoalId == null).toList();
    
    if (rootGoals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Text(
            '목표가 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: rootGoals.length,
      itemBuilder: (context, index) {
        return _buildGoalTreeItem(rootGoals[index], 0);
      },
    );
  }

  Widget _buildGoalTreeItem(Goal goal, int level) {
    final hasChildren = _getChildGoals(goal.id!).isNotEmpty;
    final isExpanded = _expandedGoals.contains(goal.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: level * 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 확장/축소 버튼
              if (hasChildren)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedGoals.remove(goal.id);
                        } else {
                          _expandedGoals.add(goal.id!);
                        }
                      });
                    },
                    padding: EdgeInsets.zero,
                  ),
                )
              else
                const SizedBox(width: 40),
              
              // 목표 카드
              Expanded(
                child: GoalCard(
                  goal: goal,
                  onTap: widget.onTap != null ? () => widget.onTap!(goal) : null,
                  onCompleteToggle: widget.onCompleteToggle,
                  onEdit: widget.onEdit != null ? () => widget.onEdit!(goal) : null,
                  onDelete: widget.onDelete != null ? () => widget.onDelete!(goal) : null,
                  showProgress: hasChildren,
                ),
              ),
            ],
          ),
        ),
        
        // 하위 목표들
        if (hasChildren && isExpanded) ...[
          const SizedBox(height: AppSizes.paddingSmall),
          ..._getChildGoals(goal.id!).map((childGoal) {
            return _buildGoalTreeItem(childGoal, level + 1);
          }),
        ],
        
        const SizedBox(height: AppSizes.paddingSmall),
      ],
    );
  }

  List<Goal> _getChildGoals(int parentId) {
    return widget.goals.where((goal) => goal.parentGoalId == parentId).toList();
  }
}
