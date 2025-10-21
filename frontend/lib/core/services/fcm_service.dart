import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app_logger.dart';
import 'api_service.dart';

/// FCM 푸시 알림 서비스
///
/// Firebase Cloud Messaging을 통한 푸시 알림 수신 및 처리
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final AppLogger _logger = AppLogger();

  String? _fcmToken;

  /// 현재 FCM 토큰 가져오기
  String? get fcmToken => _fcmToken;

  /// FCM 초기화
  Future<void> initialize() async {
    try {
      _logger.info('FCM', '🔔 Initializing FCM service...');

      // 알림 권한 요청
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      _logger.info('FCM', '📢 Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.info('FCM', '✅ User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        _logger.info('FCM', '⚠️ User granted provisional notification permission');
      } else {
        _logger.warning('FCM', '❌ User declined notification permission');
        return;
      }

      // 로컬 알림 초기화
      await _initializeLocalNotifications();

      // FCM 토큰 가져오기
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        _logger.info('FCM', '✅ FCM Token obtained: ${_fcmToken!.substring(0, 20)}...');

        // TODO: 서버에 FCM 토큰 등록
        // await ApiService().registerFcmToken(_fcmToken!);
      } else {
        _logger.error('FCM', '❌ Failed to obtain FCM token');
      }

      // 토큰 갱신 리스너
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _logger.info('FCM', '🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
        _fcmToken = newToken;

        // TODO: 서버에 새 토큰 업데이트
        // await ApiService().registerFcmToken(newToken);
      });

      // 포그라운드 메시지 리스너
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 백그라운드에서 알림 클릭 시
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageClick);

      // 앱이 종료된 상태에서 알림으로 실행된 경우
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessageClick(initialMessage);
      }

      _logger.info('FCM', '✅ FCM service initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('FCM', '❌ FCM initialization failed', e, stackTrace);
    }
  }

  /// 로컬 알림 초기화
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleLocalNotificationClick,
    );

    _logger.info('FCM', '✅ Local notifications initialized');
  }

  /// 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    _logger.info('FCM', '🔔 Foreground message received: ${message.notification?.title}');

    if (message.notification != null) {
      _showLocalNotification(message);
    }

    // 메시지 데이터 처리
    if (message.data.isNotEmpty) {
      _logger.info('FCM', '📦 Message data: ${message.data}');
      _handleNotificationData(message.data);
    }
  }

  /// 백그라운드 메시지 클릭 처리
  void _handleBackgroundMessageClick(RemoteMessage message) {
    _logger.info('FCM', '👆 Background message clicked: ${message.notification?.title}');

    if (message.data.isNotEmpty) {
      _handleNotificationData(message.data);
    }
  }

  /// 로컬 알림 클릭 처리
  void _handleLocalNotificationClick(NotificationResponse response) {
    _logger.info('FCM', '👆 Local notification clicked: ${response.payload}');

    if (response.payload != null) {
      // TODO: 알림 클릭 시 해당 목표 상세 화면으로 이동
      // Navigator.pushNamed(context, '/goal-detail', arguments: goalId);
    }
  }

  /// 알림 데이터 처리
  void _handleNotificationData(Map<String, dynamic> data) {
    final String? type = data['type'];

    switch (type) {
      case 'GOAL_EXPIRING':
        final String? goalTitle = data['goal_title'];
        final String? hoursLeft = data['hours_left'];
        _logger.info('FCM', '⏰ Goal expiring: $goalTitle ($hoursLeft hours left)');

        // TODO: 목표 만료 임박 처리
        break;

      case 'GOAL_EXPIRED':
        final String? goalTitle = data['goal_title'];
        _logger.info('FCM', '⚠️ Goal expired: $goalTitle');

        // TODO: 목표 만료 처리
        break;

      case 'GOAL_ARCHIVED':
        final String? goalTitle = data['goal_title'];
        _logger.info('FCM', '📦 Goal archived: $goalTitle');

        // TODO: 목표 보관 처리
        break;

      default:
        _logger.info('FCM', 'ℹ️ Unknown notification type: $type');
    }
  }

  /// 로컬 알림 표시
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'goal_notifications', // 채널 ID
      '목표 알림', // 채널 이름
      channelDescription: '목표 만료 및 완료 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['goal_id']?.toString(),
    );

    _logger.info('FCM', '📬 Local notification shown: ${notification.title}');
  }

  /// 테스트 알림 전송 요청
  Future<bool> sendTestNotification(String goalTitle, int hoursLeft) async {
    try {
      if (_fcmToken == null) {
        _logger.error('FCM', '❌ FCM token not available');
        return false;
      }

      _logger.info('FCM', '🧪 Sending test notification...');
      final result = await ApiService().sendTestNotification(_fcmToken!, goalTitle, hoursLeft);

      if (result) {
        _logger.info('FCM', '✅ Test notification sent successfully');
      } else {
        _logger.error('FCM', '❌ Failed to send test notification');
      }

      return result;
    } catch (e, stackTrace) {
      _logger.error('FCM', '❌ Test notification error', e, stackTrace);
      return false;
    }
  }

  /// FCM 토큰 새로고침
  Future<void> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = await _firebaseMessaging.getToken();

      if (_fcmToken != null) {
        _logger.info('FCM', '✅ FCM Token refreshed: ${_fcmToken!.substring(0, 20)}...');

        // TODO: 서버에 새 토큰 업데이트
        // await ApiService().registerFcmToken(_fcmToken!);
      }
    } catch (e, stackTrace) {
      _logger.error('FCM', '❌ Token refresh failed', e, stackTrace);
    }
  }
}

/// 백그라운드 메시지 핸들러 (top-level 함수여야 함)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = AppLogger();
  logger.info('FCM', '🔔 Background message received: ${message.notification?.title}');

  // 백그라운드에서 받은 메시지 처리
  if (message.data.isNotEmpty) {
    logger.info('FCM', '📦 Background message data: ${message.data}');
  }
}
