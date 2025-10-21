import 'package:flutter/material.dart';
import '../../../data/models/goal.dart';

/// 목표 만료 상태를 표시하는 배지 위젯
class GoalExpirationBadge extends StatelessWidget {
  final Goal goal;
  final bool showTime;

  const GoalExpirationBadge({
    super.key,
    required this.goal,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    // 만료 임박
    if (goal.isExpiringSoon) {
      return _buildBadge(
        icon: Icons.schedule,
        label: showTime ? goal.dueTimeText : '마감 임박',
        color: const Color(0xFFF59E0B), // Amber
        backgroundColor: const Color(0xFFFEF3C7),
      );
    }

    // 만료됨
    if (goal.isExpired) {
      return _buildBadge(
        icon: Icons.warning_amber,
        label: showTime ? goal.dueTimeText : '만료됨',
        color: const Color(0xFFEF4444), // Red
        backgroundColor: const Color(0xFFFEE2E2),
      );
    }

    // 보관됨
    if (goal.isArchived) {
      return _buildBadge(
        icon: Icons.archive,
        label: '보관됨',
        color: const Color(0xFF6B7280), // Gray
        backgroundColor: const Color(0xFFF3F4F6),
      );
    }

    // 마감일이 있지만 만료되지 않은 경우
    if (goal.dueDate != null && showTime) {
      return _buildBadge(
        icon: Icons.calendar_today,
        label: goal.dueTimeText,
        color: const Color(0xFF6B7280), // Gray
        backgroundColor: const Color(0xFFF3F4F6),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// 상태별 색상을 가진 간단한 배지
class GoalStatusBadge extends StatelessWidget {
  final Goal goal;

  const GoalStatusBadge({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: goal.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: goal.status.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            goal.status.icon,
            size: 14,
            color: goal.status.color,
          ),
          const SizedBox(width: 4),
          Text(
            goal.status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: goal.status.color,
            ),
          ),
        ],
      ),
    );
  }
}
