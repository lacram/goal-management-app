import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/goal.dart';
import '../goal_widgets/goal_card.dart';
import '../animations/animated_widgets.dart';

class DraggableGoalList extends StatefulWidget {
  final List<Goal> goals;
  final Function(List<Goal>) onReorder;
  final Function(Goal)? onGoalTap;
  final Function(Goal)? onCompleteToggle;
  final Function(Goal)? onEdit;
  final Function(Goal)? onDelete;
  final bool showProgress;
  final bool isDragEnabled;

  const DraggableGoalList({
    super.key,
    required this.goals,
    required this.onReorder,
    this.onGoalTap,
    this.onCompleteToggle,
    this.onEdit,
    this.onDelete,
    this.showProgress = true,
    this.isDragEnabled = true,
  });

  @override
  State<DraggableGoalList> createState() => _DraggableGoalListState();
}

class _DraggableGoalListState extends State<DraggableGoalList>
    with TickerProviderStateMixin {
  late List<Goal> _goals;
  int? _draggedIndex;
  late AnimationController _dragFeedbackController;
  late Animation<double> _dragFeedbackAnimation;

  @override
  void initState() {
    super.initState();
    _goals = List.from(widget.goals);
    
    _dragFeedbackController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _dragFeedbackAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _dragFeedbackController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(DraggableGoalList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.goals != oldWidget.goals) {
      setState(() {
        _goals = List.from(widget.goals);
      });
    }
  }

  @override
  void dispose() {
    _dragFeedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDragEnabled) {
      return _buildNormalList();
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: _onReorder,
      proxyDecorator: _proxyDecorator,
      itemCount: _goals.length,
      itemBuilder: (context, index) {
        final goal = _goals[index];
        
        return SlideInWidget(
          key: ValueKey(goal.id),
          delay: Duration(milliseconds: index * 50),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
            child: _buildDraggableGoalCard(goal, index),
          ),
        );
      },
    );
  }

  Widget _buildNormalList() {
    return StaggeredListAnimation(
      children: _goals.asMap().entries.map((entry) {
        final index = entry.key;
        final goal = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
          child: GoalCard(
            goal: goal,
            onTap: () => widget.onGoalTap?.call(goal),
            onCompleteToggle: widget.onCompleteToggle,
            onEdit: () => widget.onEdit?.call(goal),
            onDelete: () => widget.onDelete?.call(goal),
            showProgress: widget.showProgress,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDraggableGoalCard(Goal goal, int index) {
    return Material(
      elevation: _draggedIndex == index ? 8 : 2,
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: _draggedIndex == index
              ? Border.all(
                  color: AppColors.primaryColor,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            // 드래그 핸들
            if (widget.isDragEnabled)
              Container(
                width: 40,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                child: ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ),
            
            // 목표 카드
            Expanded(
              child: GoalCard(
                goal: goal,
                onTap: () => widget.onGoalTap?.call(goal),
                onCompleteToggle: widget.onCompleteToggle,
                onEdit: () => widget.onEdit?.call(goal),
                onDelete: () => widget.onDelete?.call(goal),
                showProgress: widget.showProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _dragFeedbackAnimation.value,
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      _draggedIndex = null;
      
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      final goal = _goals.removeAt(oldIndex);
      _goals.insert(newIndex, goal);
    });
    
    // 애니메이션 효과
    _dragFeedbackController.forward().then((_) {
      _dragFeedbackController.reverse();
    });
    
    // 부모에게 순서 변경 알림
    widget.onReorder(_goals);
    
    // 햅틱 피드백
    _showReorderFeedback();
  }

  void _showReorderFeedback() {
    // 스낵바로 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('목표 순서가 변경되었습니다'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSizes.paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
    );
  }
}

// 드래그 가능한 목표 타일 컴포넌트
class DraggableGoalTile extends StatefulWidget {
  final Goal goal;
  final int index;
  final VoidCallback? onTap;
  final Function(Goal)? onCompleteToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDragging;

  const DraggableGoalTile({
    super.key,
    required this.goal,
    required this.index,
    this.onTap,
    this.onCompleteToggle,
    this.onEdit,
    this.onDelete,
    this.isDragging = false,
  });

  @override
  State<DraggableGoalTile> createState() => _DraggableGoalTileState();
}

class _DraggableGoalTileState extends State<DraggableGoalTile>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSmall,
                vertical: AppSizes.paddingSmall / 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
                    blurRadius: _isHovered ? 8 : 4,
                    offset: Offset(0, _isHovered ? 4 : 2),
                  ),
                ],
              ),
              child: Material(
                elevation: widget.isDragging ? 8 : (_isHovered ? 4 : 2),
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    border: widget.isDragging
                        ? Border.all(
                            color: AppColors.primaryColor,
                            width: 2,
                          )
                        : null,
                  ),
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 드래그 핸들
                        ReorderableDragStartListener(
                          index: widget.index,
                          child: Icon(
                            Icons.drag_handle,
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingSmall),
                        // 완료 체크박스
                        Checkbox(
                          value: widget.goal.isCompleted,
                          onChanged: (_) => widget.onCompleteToggle?.call(widget.goal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      widget.goal.title,
                      style: TextStyle(
                        decoration: widget.goal.isCompleted 
                            ? TextDecoration.lineThrough 
                            : TextDecoration.none,
                        color: widget.goal.isCompleted 
                            ? AppColors.textSecondaryColor 
                            : AppColors.textPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: widget.goal.description != null
                        ? Text(
                            widget.goal.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 목표 타입 표시
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.goal.type.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Text(
                            widget.goal.type.displayName,
                            style: TextStyle(
                              color: widget.goal.type.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingSmall),
                        // 액션 메뉴
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                widget.onEdit?.call();
                                break;
                              case 'delete':
                                widget.onDelete?.call();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            if (widget.onEdit != null)
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
                            if (widget.onDelete != null)
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
                    onTap: widget.onTap,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }
}
