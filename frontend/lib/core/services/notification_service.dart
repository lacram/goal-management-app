// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
// import 'package:timezone/timezone.dart' as tz;
import '../../data/models/goal.dart';

/// 알림 서비스 (임시 비활성화 - 빌드 이슈 해결 후 재활성화 예정)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isInitialized = true;
      debugPrint('NotificationService initialized (disabled mode)');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// 알림 권한 요청
  Future<bool> requestPermissions() async {
    debugPrint('NotificationService: requestPermissions (disabled)');
    return true;
  }

  /// 목표 리마인더 알림 스케줄링
  Future<void> scheduleGoalReminder(Goal goal) async {
    debugPrint('NotificationService: scheduleGoalReminder (disabled) - ${goal.title}');
  }

  /// 마감일 알림 스케줄링
  Future<void> scheduleDueDateReminder(Goal goal) async {
    debugPrint('NotificationService: scheduleDueDateReminder (disabled) - ${goal.title}');
  }

  /// 목표 완료 축하 알림
  Future<void> showGoalCompletionNotification(Goal goal) async {
    debugPrint('NotificationService: showGoalCompletionNotification (disabled) - ${goal.title}');
  }

  /// 주간 진행률 알림
  Future<void> scheduleWeeklyProgressReminder() async {
    debugPrint('NotificationService: scheduleWeeklyProgressReminder (disabled)');
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    debugPrint('NotificationService: cancelAllNotifications (disabled)');
  }

  /// 목표 삭제시 관련 알림 제거
  Future<void> cancelGoalNotifications(int goalId) async {
    debugPrint('NotificationService: cancelGoalNotifications (disabled) - $goalId');
  }
}
