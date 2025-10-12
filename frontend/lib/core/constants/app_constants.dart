import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color primaryLightColor = Color(0xFF818CF8);
  static const Color primaryDarkColor = Color(0xFF4F46E5);
  
  // Secondary Colors
  static const Color secondaryColor = Color(0xFF10B981); // Emerald
  static const Color secondaryLightColor = Color(0xFF34D399);
  static const Color secondaryDarkColor = Color(0xFF059669);
  
  // Goal Type Colors
  static const Color lifetimeColor = Color(0xFF8B5CF6); // Purple
  static const Color lifetimeSubColor = Color(0xFFA78BFA);
  static const Color yearlyColor = Color(0xFF3B82F6); // Blue
  static const Color monthlyColor = Color(0xFF06B6D4); // Cyan
  static const Color weeklyColor = Color(0xFF10B981); // Emerald
  static const Color dailyColor = Color(0xFFF59E0B); // Amber
  
  // Status Colors
  static const Color activeColor = Color(0xFF10B981); // Green
  static const Color completedColor = Color(0xFF6B7280); // Gray
  static const Color failedColor = Color(0xFFEF4444); // Red
  static const Color postponedColor = Color(0xFFF59E0B); // Amber
  static const Color successColor = Color(0xFF10B981); // Green
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color infoColor = Color(0xFF3B82F6); // Blue
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE5E7EB);
  
  // Text Colors
  static const Color textPrimaryColor = Color(0xFF111827);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color textDisabledColor = Color(0xFF9CA3AF);
  
  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF111827);
  static const Color darkSurfaceColor = Color(0xFF1F2937);
  static const Color darkCardColor = Color(0xFF374151);
  static const Color darkTextPrimaryColor = Color(0xFFF9FAFB);
  static const Color darkTextSecondaryColor = Color(0xFFD1D5DB);
}

class AppSizes {
  // Padding & Margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  
  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  
  // Button Heights
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  
  // Card Heights
  static const double cardHeight = 80.0;
  static const double cardHeightLarge = 120.0;
}

class AppStrings {
  // App
  static const String appTitle = '목표 관리 앱';
  
  // Navigation
  static const String homeTab = '홈';
  static const String goalsTab = '목표';
  static const String statisticsTab = '통계';
  static const String settingsTab = '설정';
  
  // Home
  static const String todayGoals = '오늘의 목표';
  static const String thisWeekProgress = '이번 주 진행률';
  static const String thisMonthProgress = '이번 달 진행률';
  static const String addNewGoal = '새 목표 추가';
  
  // Goals
  static const String allGoals = '전체 목표';
  static const String activeGoals = '진행중';
  static const String completedGoals = '완료됨';
  static const String lifetimeGoals = '평생 목표';
  static const String yearlyGoals = '년 단위';
  static const String monthlyGoals = '월 단위';
  static const String weeklyGoals = '주 단위';
  static const String dailyGoals = '일 단위';
  
  // Goal Form
  static const String goalTitle = '목표 제목';
  static const String goalDescription = '목표 설명';
  static const String goalType = '목표 타입';
  static const String parentGoal = '상위 목표';
  static const String dueDate = '마감일';
  static const String priority = '우선순위';
  static const String reminderEnabled = '알림 활성화';
  static const String reminderFrequency = '알림 주기';
  
  // Actions
  static const String save = '저장';
  static const String cancel = '취소';
  static const String edit = '편집';
  static const String delete = '삭제';
  static const String complete = '완료';
  static const String uncomplete = '완료 취소';
  
  // Status
  static const String loading = '로딩 중...';
  static const String noData = '데이터가 없습니다';
  static const String error = '오류가 발생했습니다';
}