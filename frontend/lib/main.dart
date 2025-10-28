                                                                                                                                                import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme_complete.dart';
import 'core/services/app_logger.dart';
import 'core/services/fcm_service.dart';
import 'core/constants/api_endpoints.dart';
import 'data/providers/goal_provider.dart';
import 'data/providers/routine_provider.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 로거 초기화
  await logger.initialize();
  logger.info('App', '앱 시작');

  // API Endpoints 초기화 (Base URL 캐싱)
  await ApiEndpoints.initialize();

  // 현재 환경 및 서버 URL 로깅
  final environment = ApiEndpoints.currentEnvironment;
  final baseUrl = ApiEndpoints.goals.split('/goals').first;
  logger.info('App', '실행 환경: $environment');
  logger.info('App', '서버 URL: $baseUrl');

  // Firebase 초기화
  try {
    await Firebase.initializeApp();
    logger.info('App', '✅ Firebase 초기화 완료');

    // 백그라운드 메시지 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // FCM 서비스 초기화
    await FcmService().initialize();
    logger.info('App', '✅ FCM 서비스 초기화 완료');
  } catch (e, stackTrace) {
    logger.error('App', 'Firebase 초기화 실패', e, stackTrace);
    // Firebase 없이도 앱 실행 가능하도록 계속 진행
  }

  runApp(const GoalManagementApp());
}

class GoalManagementApp extends StatelessWidget {
  const GoalManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: '목표 관리 앱',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
            
            // 글로벌 애니메이션 설정
            builder: (context, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
