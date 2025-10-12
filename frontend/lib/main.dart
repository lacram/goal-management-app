                                                                                                                                                import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme_complete.dart';
import 'core/services/app_logger.dart';
import 'data/providers/goal_provider.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 로거 초기화
  await logger.initialize();
  logger.info('App', '앱 시작');
  
  runApp(const GoalManagementApp());
}

class GoalManagementApp extends StatelessWidget {
  const GoalManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoalProvider()),
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
