import 'package:flutter/material.dart';

enum RoutineFrequency {
  daily('DAILY', '매일'),
  weekly('WEEKLY', '주간'),
  monthly('MONTHLY', '월간');

  const RoutineFrequency(this.value, this.displayName);
  final String value;
  final String displayName;

  Color get color {
    switch (this) {
      case RoutineFrequency.daily:
        return const Color(0xFFF59E0B); // Amber
      case RoutineFrequency.weekly:
        return const Color(0xFF10B981); // Emerald
      case RoutineFrequency.monthly:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  IconData get icon {
    switch (this) {
      case RoutineFrequency.daily:
        return Icons.wb_sunny; // 해 아이콘
      case RoutineFrequency.weekly:
        return Icons.date_range; // 달력 아이콘
      case RoutineFrequency.monthly:
        return Icons.calendar_month; // 월 아이콘
    }
  }

  static RoutineFrequency fromString(String value) {
    return RoutineFrequency.values.firstWhere(
      (freq) => freq.value == value,
      orElse: () => RoutineFrequency.daily,
    );
  }
}

class Routine {
  final int? id;
  final String title;
  final String? description;
  final RoutineFrequency frequency;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool completedToday;

  Routine({
    this.id,
    required this.title,
    this.description,
    required this.frequency,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.completedToday = false,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      frequency: RoutineFrequency.fromString(json['frequency'] ?? 'DAILY'),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      completedToday: json['completedToday'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'frequency': frequency.value,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedToday': completedToday,
    };
  }

  Routine copyWith({
    int? id,
    String? title,
    String? description,
    RoutineFrequency? frequency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? completedToday,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedToday: completedToday ?? this.completedToday,
    );
  }

  @override
  String toString() {
    return 'Routine(id: $id, title: $title, frequency: ${frequency.displayName}, completedToday: $completedToday)';
  }
}

class RoutineCompletion {
  final int? id;
  final int routineId;
  final DateTime completedAt;
  final String? note;

  RoutineCompletion({
    this.id,
    required this.routineId,
    required this.completedAt,
    this.note,
  });

  factory RoutineCompletion.fromJson(Map<String, dynamic> json) {
    return RoutineCompletion(
      id: json['id'],
      routineId: json['routineId'],
      completedAt: DateTime.parse(json['completedAt']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routineId': routineId,
      'completedAt': completedAt.toIso8601String(),
      'note': note,
    };
  }

  @override
  String toString() {
    return 'RoutineCompletion(id: $id, routineId: $routineId, completedAt: $completedAt)';
  }
}
