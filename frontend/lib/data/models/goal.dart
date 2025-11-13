import 'package:flutter/material.dart';

enum GoalType {
  lifetime('LIFETIME', '평생목표'),
  lifetimeSub('LIFETIME_SUB', '평생목표 하위'),
  yearly('YEARLY', '년단위'),
  monthly('MONTHLY', '월단위'),
  weekly('WEEKLY', '주단위'),
  daily('DAILY', '일단위');

  const GoalType(this.value, this.displayName);
  final String value;
  final String displayName;
  
  Color get color {
    switch (this) {
      case GoalType.lifetime:
        return const Color(0xFF8B5CF6); // Purple
      case GoalType.lifetimeSub:
        return const Color(0xFFA78BFA); // Light Purple
      case GoalType.yearly:
        return const Color(0xFF3B82F6); // Blue
      case GoalType.monthly:
        return const Color(0xFF06B6D4); // Cyan
      case GoalType.weekly:
        return const Color(0xFF10B981); // Emerald
      case GoalType.daily:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  static GoalType fromString(String value) {
    return GoalType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => GoalType.daily,
    );
  }
}

enum GoalStatus {
  active('ACTIVE', '진행중'),
  completed('COMPLETED', '완료'),
  expired('EXPIRED', '만료됨'),
  archived('ARCHIVED', '보관됨'),
  failed('FAILED', '실패'),
  postponed('POSTPONED', '연기');

  const GoalStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  Color get color {
    switch (this) {
      case GoalStatus.active:
        return const Color(0xFF10B981); // Green
      case GoalStatus.completed:
        return const Color(0xFF6B7280); // Gray
      case GoalStatus.expired:
        return const Color(0xFFEF4444); // Red
      case GoalStatus.archived:
        return const Color(0xFF94A3B8); // Slate Gray
      case GoalStatus.failed:
        return const Color(0xFFDC2626); // Dark Red
      case GoalStatus.postponed:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  IconData get icon {
    switch (this) {
      case GoalStatus.active:
        return Icons.play_circle_outline;
      case GoalStatus.completed:
        return Icons.check_circle;
      case GoalStatus.expired:
        return Icons.warning_amber;
      case GoalStatus.archived:
        return Icons.archive;
      case GoalStatus.failed:
        return Icons.cancel;
      case GoalStatus.postponed:
        return Icons.schedule;
    }
  }

  static GoalStatus fromString(String value) {
    return GoalStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => GoalStatus.active,
    );
  }
}

class Goal {
  final int? id;
  final String title;
  final String? description;
  final GoalType type;
  final GoalStatus status;
  final int? parentGoalId;
  final List<Goal> subGoals;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final bool isCompleted;
  final int priority;
  final bool reminderEnabled;
  final String? reminderFrequency;
  final double progressPercentage;

  Goal({
    this.id,
    required this.title,
    this.description,
    required this.type,
    this.status = GoalStatus.active,
    this.parentGoalId,
    this.subGoals = const [],
    this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.isCompleted = false,
    this.priority = 1,
    this.reminderEnabled = false,
    this.reminderFrequency,
    this.progressPercentage = 0.0,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      type: GoalType.fromString(json['type'] ?? 'DAILY'),
      status: GoalStatus.fromString(json['status'] ?? 'ACTIVE'),
      parentGoalId: json['parentGoalId'],
      subGoals: (json['subGoals'] as List<dynamic>?)
          ?.map((subGoal) => Goal.fromJson(subGoal))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'] ?? 1,
      reminderEnabled: json['reminderEnabled'] ?? false,
      reminderFrequency: json['reminderFrequency'],
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.value,
      'status': status.value,
      'parentGoalId': parentGoalId,
      'subGoals': subGoals.map((goal) => goal.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'reminderEnabled': reminderEnabled,
      'reminderFrequency': reminderFrequency,
      'progressPercentage': progressPercentage,
    };
  }

  Goal copyWith({
    int? id,
    String? title,
    String? description,
    GoalType? type,
    GoalStatus? status,
    int? parentGoalId,
    List<Goal>? subGoals,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? completedAt,
    bool? isCompleted,
    int? priority,
    bool? reminderEnabled,
    String? reminderFrequency,
    double? progressPercentage,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      parentGoalId: parentGoalId ?? this.parentGoalId,
      subGoals: subGoals ?? this.subGoals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }


  // 만료 여부 확인
  bool get isExpired {
    return status == GoalStatus.expired;
  }

  // 보관 여부 확인
  bool get isArchived {
    return status == GoalStatus.archived;
  }

  // 만료 임박 여부 확인 (24시간 이내)
  bool get isExpiringSoon {
    if (dueDate == null || isCompleted || status != GoalStatus.active) {
      return false;
    }
    final now = DateTime.now();
    final hoursUntilDue = dueDate!.difference(now).inHours;
    return hoursUntilDue > 0 && hoursUntilDue <= 24;
  }

  // 마감일까지 남은 시간 텍스트
  String get dueTimeText {
    if (dueDate == null) return '';

    final now = DateTime.now();
    final difference = dueDate!.difference(now);

    if (difference.isNegative) {
      final daysPast = difference.inDays.abs();
      if (daysPast == 0) {
        return '오늘 마감';
      } else if (daysPast == 1) {
        return '어제 마감';
      } else {
        return '$daysPast일 전 마감';
      }
    } else {
      final daysLeft = difference.inDays;
      final hoursLeft = difference.inHours;

      if (daysLeft == 0) {
        if (hoursLeft == 0) {
          return '곧 마감';
        } else {
          return '$hoursLeft시간 남음';
        }
      } else if (daysLeft == 1) {
        return '내일 마감';
      } else {
        return '$daysLeft일 남음';
      }
    }
  }

  // 상태 배지 색상
  Color get statusBadgeColor {
    if (isExpiringSoon) {
      return const Color(0xFFF59E0B); // Amber (경고)
    }
    return status.color;
  }

  @override
  String toString() {
    return 'Goal(id: $id, title: $title, type: ${type.displayName}, '
           'status: ${status.displayName}, isCompleted: $isCompleted)';
  }
}