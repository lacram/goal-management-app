import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../models/goal.dart';
import '../notification_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService = NotificationService();
  
  String? _fcmToken;
  bool _isInitialized = false;

  /// FCM 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Firebase 초기화
      if (!Firebase.apps.isNotEmpty) {
        await Firebase.initializeApp();
      }

      // 알림 권한 요청
      await _requestPermissions();
      
      // FCM 토큰 가져오기
      await _getFCMToken();
      
      // 메시지 핸들러 설정
      _setupMessageHandlers();
      
      // 로컬 알림 초기화
      await _notificationService.initialize();
      
      _isInitialized = true;
      debugPrint('FCM Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing FCM Service: $e');
    }
  }

  /// 알림 권한 요청
  Future<bool> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission for notifications');
        return true;
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission for notifications');
        return true;
      } else {
        debugPrint('User declined or has not accepted permission for notifications');
        return false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// FCM 토큰 가져오기
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
      
      // 토큰 새로고침 리스너
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        debugPrint('FCM Token refreshed: $token');
        // 서버에 새 토큰 전송
        _sendTokenToServer(token);
      });
      
      if (_fcmToken != null) {
        await _sendTokenToServer(_fcmToken!);
      }
      
      return _fcmToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// 서버에 FCM 토큰 전송
  Future<void> _sendTokenToServer(String token) async {
    try {
      // 실제 구현에서는 백엔드 API에 토큰 저장
      debugPrint('Sending FCM token to server: $token');
      
      // 예시: HTTP 요청으로 서버에 토큰 전송
      // final response = await http.post(
      //   Uri.parse('${ApiEndpoints.baseUrl}/fcm/token'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'token': token, 'platform': Platform.operatingSystem}),
      // );
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }

  /// 메시지 핸들러 설정
  void _setupMessageHandlers() {
    // 포그라운드 메시지 처리
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // 백그라운드 메시지 탭 처리
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // 앱이 종료된 상태에서 알림 탭으로 실행된 경우 처리
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });
  }

  /// 포그라운드 메시지 처리
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');
    
    // 로컬 알림으로 표시
    await _showLocalNotification(message);
  }

  /// 백그라운드 메시지 처리
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Received background message: ${message.messageId}');
    
    // 메시지 타입에 따른 처리
    final messageType = message.data['type'];
    
    switch (messageType) {
      case 'goal_reminder':
        await _handleGoalReminderMessage(message);
        break;
      case 'goal_deadline':
        await _handleGoalDeadlineMessage(message);
        break;
      case 'goal_completion':
        await _handleGoalCompletionMessage(message);
        break;
      case 'weekly_report':
        await _handleWeeklyReportMessage(message);
        break;
      default:
        debugPrint('Unknown message type: $messageType');
    }
  }

  /// 로컬 알림 표시
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'goal_notifications',
        '목표 알림',
        channelDescription: '목표 관련 푸시 알림',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? '목표 관리',
        message.notification?.body ?? '새로운 알림이 있습니다',
        notificationDetails,
        payload: message.data['payload'],
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// 목표 리마인더 메시지 처리
  Future<void> _handleGoalReminderMessage(RemoteMessage message) async {
    final goalId = message.data['goalId'];
    debugPrint('Goal reminder for goal ID: $goalId');
    
    // 목표 상세 화면으로 네비게이션
    // NavigationService.navigateToGoalDetail(goalId);
  }

  /// 목표 마감일 메시지 처리
  Future<void> _handleGoalDeadlineMessage(RemoteMessage message) async {
    final goalId = message.data['goalId'];
    final daysLeft = message.data['daysLeft'];
    debugPrint('Goal deadline for goal ID: $goalId, days left: $daysLeft');
    
    // 목표 목록 화면으로 네비게이션
    // NavigationService.navigateToGoalList(filter: 'deadline');
  }

  /// 목표 완료 축하 메시지 처리
  Future<void> _handleGoalCompletionMessage(RemoteMessage message) async {
    final goalId = message.data['goalId'];
    debugPrint('Goal completion celebration for goal ID: $goalId');
    
    // 통계 화면으로 네비게이션
    // NavigationService.navigateToStatistics();
  }

  /// 주간 리포트 메시지 처리
  Future<void> _handleWeeklyReportMessage(RemoteMessage message) async {
    debugPrint('Weekly report message received');
    
    // 통계 화면으로 네비게이션
    // NavigationService.navigateToStatistics();
  }

  /// 목표 리마인더 푸시 알림 스케줄링 (서버 요청)
  Future<void> scheduleGoalReminderPush(Goal goal) async {
    if (_fcmToken == null) {
      debugPrint('FCM token not available');
      return;
    }

    try {
      // 서버에 푸시 알림 스케줄링 요청
      final scheduleData = {
        'fcmToken': _fcmToken,
        'goalId': goal.id,
        'goalTitle': goal.title,
        'reminderType': 'goal_reminder',
        'scheduleTime': _getNextReminderTime(goal).toIso8601String(),
        'repeatInterval': goal.reminderFrequency,
      };

      debugPrint('Scheduling push notification: $scheduleData');
      
      // 실제 구현에서는 백엔드 API 호출
      // final response = await http.post(
      //   Uri.parse('${ApiEndpoints.baseUrl}/fcm/schedule'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(scheduleData),
      // );
    } catch (e) {
      debugPrint('Error scheduling goal reminder push: $e');
    }
  }

  /// 마감일 푸시 알림 스케줄링
  Future<void> scheduleDeadlinePush(Goal goal) async {
    if (_fcmToken == null || goal.dueDate == null) return;

    try {
      final now = DateTime.now();
      final dueDate = goal.dueDate!;
      
      // 마감일 하루 전 알림
      final oneDayBefore = dueDate.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(now)) {
        await _scheduleSpecificDeadlinePush(goal, oneDayBefore, 1);
      }
      
      // 마감일 당일 알림
      if (dueDate.isAfter(now)) {
        await _scheduleSpecificDeadlinePush(goal, dueDate, 0);
      }
    } catch (e) {
      debugPrint('Error scheduling deadline push: $e');
    }
  }

  /// 특정 마감일 푸시 알림 스케줄링
  Future<void> _scheduleSpecificDeadlinePush(Goal goal, DateTime scheduleTime, int daysLeft) async {
    final scheduleData = {
      'fcmToken': _fcmToken,
      'goalId': goal.id,
      'goalTitle': goal.title,
      'reminderType': 'goal_deadline',
      'scheduleTime': scheduleTime.toIso8601String(),
      'daysLeft': daysLeft,
    };

    debugPrint('Scheduling deadline push notification: $scheduleData');
    
    // 백엔드 API 호출
    // await _sendScheduleRequest(scheduleData);
  }

  /// 목표 완료 축하 푸시 알림
  Future<void> sendGoalCompletionPush(Goal goal) async {
    if (_fcmToken == null) return;

    try {
      final notificationData = {
        'fcmToken': _fcmToken,
        'goalId': goal.id,
        'goalTitle': goal.title,
        'reminderType': 'goal_completion',
        'sendImmediately': true,
      };

      debugPrint('Sending goal completion push: $notificationData');
      
      // 백엔드 API 호출
      // await _sendImmediateNotification(notificationData);
    } catch (e) {
      debugPrint('Error sending goal completion push: $e');
    }
  }

  /// 주간 리포트 푸시 알림
  Future<void> sendWeeklyReportPush(Map<String, dynamic> reportData) async {
    if (_fcmToken == null) return;

    try {
      final notificationData = {
        'fcmToken': _fcmToken,
        'reminderType': 'weekly_report',
        'reportData': reportData,
        'sendImmediately': true,
      };

      debugPrint('Sending weekly report push: $notificationData');
      
      // 백엔드 API 호출
      // await _sendImmediateNotification(notificationData);
    } catch (e) {
      debugPrint('Error sending weekly report push: $e');
    }
  }

  /// 푸시 알림 구독 토픽 관리
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// 푸시 알림 취소
  Future<void> cancelGoalPushNotifications(int goalId) async {
    try {
      // 서버에 푸시 알림 취소 요청
      final cancelData = {
        'fcmToken': _fcmToken,
        'goalId': goalId,
        'action': 'cancel_all',
      };

      debugPrint('Cancelling push notifications for goal: $goalId');
      
      // 백엔드 API 호출
      // await _sendCancelRequest(cancelData);
    } catch (e) {
      debugPrint('Error cancelling goal push notifications: $e');
    }
  }

  /// 모든 푸시 알림 취소
  Future<void> cancelAllPushNotifications() async {
    try {
      final cancelData = {
        'fcmToken': _fcmToken,
        'action': 'cancel_all',
      };

      debugPrint('Cancelling all push notifications');
      
      // 백엔드 API 호출
      // await _sendCancelRequest(cancelData);
    } catch (e) {
      debugPrint('Error cancelling all push notifications: $e');
    }
  }

  /// 헬퍼 메서드들
  DateTime _getNextReminderTime(Goal goal) {
    final now = DateTime.now();
    
    switch (goal.reminderFrequency) {
      case 'DAILY':
        return DateTime(now.year, now.month, now.day + 1, 9, 0);
      case 'WEEKLY':
        return now.add(const Duration(days: 7));
      case 'MONTHLY':
        return DateTime(now.year, now.month + 1, now.day, 9, 0);
      default:
        return now.add(const Duration(hours: 1));
    }
  }

  /// FCM 토큰 가져오기 (외부에서 사용)
  String? get fcmToken => _fcmToken;
  
  /// 초기화 상태 확인
  bool get isInitialized => _isInitialized;
}

// 백그라운드 메시지 핸들러 (글로벌 함수로 정의)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase 초기화
  await Firebase.initializeApp();
  
  debugPrint('Handling background message: ${message.messageId}');
  
  // 백그라운드에서도 로컬 알림 표시
  const androidDetails = AndroidNotificationDetails(
    'background_notifications',
    '백그라운드 알림',
    channelDescription: '백그라운드에서 받은 알림',
    importance: Importance.high,
    priority: Priority.high,
  );

  const notificationDetails = NotificationDetails(android: androidDetails);
  
  final notifications = FlutterLocalNotificationsPlugin();
  await notifications.show(
    message.hashCode,
    message.notification?.title ?? '목표 관리',
    message.notification?.body ?? '새로운 알림',
    notificationDetails,
  );
}

// FCM 서비스 초기화 (main.dart에서 호출)
Future<void> initializeFCM() async {
  // 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // FCM 서비스 초기화
  await FCMService().initialize();
}
