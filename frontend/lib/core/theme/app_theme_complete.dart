import 'package:flutter/material.dart';

class DarkModeColors {
  // Primary Colors - Dark Mode
  static const Color primaryColor = Color(0xFF818CF8); // Lighter Indigo
  static const Color primaryLightColor = Color(0xFF9CA3FF);
  static const Color primaryDarkColor = Color(0xFF6366F1);
  
  // Secondary Colors - Dark Mode
  static const Color secondaryColor = Color(0xFF34D399); // Lighter Emerald
  static const Color secondaryLightColor = Color(0xFF6EE7B7);
  static const Color secondaryDarkColor = Color(0xFF10B981);
  
  // Goal Type Colors - Dark Mode
  static const Color lifetimeColor = Color(0xFFA78BFA); // Lighter Purple
  static const Color lifetimeSubColor = Color(0xFFC4B5FD);
  static const Color yearlyColor = Color(0xFF60A5FA); // Lighter Blue
  static const Color monthlyColor = Color(0xFF22D3EE); // Lighter Cyan
  static const Color weeklyColor = Color(0xFF34D399); // Lighter Emerald
  static const Color dailyColor = Color(0xFFFBBF24); // Lighter Amber
  
  // Status Colors - Dark Mode
  static const Color activeColor = Color(0xFF34D399); // Lighter Green
  static const Color completedColor = Color(0xFF9CA3AF); // Lighter Gray
  static const Color failedColor = Color(0xFFF87171); // Lighter Red
  static const Color postponedColor = Color(0xFFFBBF24); // Lighter Amber
  static const Color successColor = Color(0xFF34D399); // Lighter Green
  static const Color warningColor = Color(0xFFFBBF24); // Lighter Amber
  static const Color errorColor = Color(0xFFF87171); // Lighter Red
  static const Color infoColor = Color(0xFF60A5FA); // Lighter Blue
  
  // Background Colors - Dark Mode
  static const Color backgroundColor = Color(0xFF0F172A); // Dark Slate
  static const Color surfaceColor = Color(0xFF1E293B); // Darker Slate
  static const Color cardColor = Color(0xFF334155); // Medium Slate
  static const Color dividerColor = Color(0xFF475569); // Light Slate
  
  // Text Colors - Dark Mode
  static const Color textPrimaryColor = Color(0xFFF8FAFC); // Light Slate
  static const Color textSecondaryColor = Color(0xFFCBD5E1); // Gray Slate
  static const Color textDisabledColor = Color(0xFF64748B); // Medium Slate
  
  // Additional Dark Mode Colors
  static const Color overlayColor = Color(0xFF0F172A); // Dark overlay
  static const Color borderColor = Color(0xFF475569); // Border color
  static const Color shadowColor = Color(0xFF000000); // Shadow color
}

class AppThemes {
  // Light Theme (기존)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF6366F1),
        unselectedItemColor: Color(0xFF6B7280),
        elevation: 8,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
  
  // Dark Theme (개선된 버전)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DarkModeColors.primaryColor,
        brightness: Brightness.dark,
        surface: DarkModeColors.surfaceColor,
        onSurface: DarkModeColors.textPrimaryColor,
      ),
      
      // Scaffold Theme
      scaffoldBackgroundColor: DarkModeColors.backgroundColor,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: DarkModeColors.surfaceColor,
        foregroundColor: DarkModeColors.textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: DarkModeColors.textPrimaryColor,
        ),
        shadowColor: DarkModeColors.shadowColor.withOpacity(0.3),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: DarkModeColors.cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: DarkModeColors.shadowColor.withOpacity(0.3),
        surfaceTintColor: DarkModeColors.primaryColor.withOpacity(0.05),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DarkModeColors.primaryColor,
          foregroundColor: DarkModeColors.backgroundColor,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 4,
          shadowColor: DarkModeColors.shadowColor.withOpacity(0.3),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DarkModeColors.primaryColor,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DarkModeColors.primaryColor,
          side: BorderSide(color: DarkModeColors.primaryColor),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DarkModeColors.primaryColor,
        foregroundColor: DarkModeColors.backgroundColor,
        elevation: 6,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: DarkModeColors.surfaceColor,
        selectedItemColor: DarkModeColors.primaryColor,
        unselectedItemColor: DarkModeColors.textSecondaryColor,
        elevation: 8,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkModeColors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: DarkModeColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: DarkModeColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DarkModeColors.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: const TextStyle(color: DarkModeColors.textSecondaryColor),
        labelStyle: const TextStyle(color: DarkModeColors.textSecondaryColor),
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        tileColor: DarkModeColors.cardColor,
        textColor: DarkModeColors.textPrimaryColor,
        iconColor: DarkModeColors.textSecondaryColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: DarkModeColors.dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: DarkModeColors.textSecondaryColor,
        size: 24,
      ),
      
      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: DarkModeColors.primaryColor,
        size: 24,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: DarkModeColors.textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          color: DarkModeColors.textPrimaryColor,
        ),
        bodySmall: TextStyle(
          color: DarkModeColors.textSecondaryColor,
        ),
        labelLarge: TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: DarkModeColors.textSecondaryColor,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: DarkModeColors.textSecondaryColor,
        ),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DarkModeColors.primaryColor,
        linearTrackColor: DarkModeColors.dividerColor,
        circularTrackColor: DarkModeColors.dividerColor,
      ),
      
      // Slider Theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: DarkModeColors.primaryColor,
        inactiveTrackColor: DarkModeColors.dividerColor,
        thumbColor: DarkModeColors.primaryColor,
        overlayColor: DarkModeColors.primaryColor,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return DarkModeColors.primaryColor;
          }
          return DarkModeColors.textSecondaryColor;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return DarkModeColors.primaryColor.withOpacity(0.5);
          }
          return DarkModeColors.dividerColor;
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return DarkModeColors.primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(DarkModeColors.backgroundColor),
        side: const BorderSide(color: DarkModeColors.borderColor),
      ),
      
      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return DarkModeColors.primaryColor;
          }
          return DarkModeColors.textSecondaryColor;
        }),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: DarkModeColors.cardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: const TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: DarkModeColors.textPrimaryColor,
          fontSize: 16,
        ),
      ),
      
      // Snack Bar Theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: DarkModeColors.surfaceColor,
        contentTextStyle: TextStyle(
          color: DarkModeColors.textPrimaryColor,
        ),
        actionTextColor: DarkModeColors.primaryColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: DarkModeColors.primaryColor,
        unselectedLabelColor: DarkModeColors.textSecondaryColor,
        indicatorColor: DarkModeColors.primaryColor,
        dividerColor: DarkModeColors.dividerColor,
      ),
      
      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: DarkModeColors.surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
    );
  }
}

// 테마 관리를 위한 Provider
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }
}
