import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ApiEndpoints {
  // 기본 프로덕션 URL (Railway)
  static const String defaultProdBaseUrl = 'https://goal-management-app-production.up.railway.app/api';
  // 기본 개발용 URL
  static const String defaultDevBaseUrl = 'http://192.168.0.11:8080/api';
  
  // 저장된 서버 URL 가져오기
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final customUrl = prefs.getString('server_url');
    
    // 사용자가 설정한 URL이 있으면 사용
    if (customUrl != null && customUrl.isNotEmpty) {
      return customUrl;
    }
    
    // 없으면 기본 URL 사용
    return _getDefaultBaseUrl();
  }
  
  // 서버 URL 저장
  static Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
  }
  
  // 서버 URL 초기화 (기본값으로 복구)
  static Future<void> resetBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('server_url');
  }
  
  // 플랫폼별 기본 URL
  static String _getDefaultBaseUrl() {
    // 프로덕션 우선, 개발 환경에서 필요시 설정에서 변경 가능
    return defaultProdBaseUrl; // Railway 프로덕션 서버
    
    // 개발용 (설정에서 수동 변경 가능):
    // - Android 에뮬레이터: http://10.0.2.2:8080/api
    // - iOS 시뮬레이터: http://localhost:8080/api  
    // - 실제 기기: http://192.168.0.11:8080/api
  }
  
  // 현재는 프로덕션 URL을 기본으로 사용 (빠른 빌드를 위해 동기적 처리)
  // TODO: 설정 화면에서 URL 변경 기능을 구현할 때 비동기로 변경
  static String get goals => '$defaultProdBaseUrl/goals';
  
  static String goalById(int id) => '$goals/$id';
  
  static String completeGoal(int id) => '$goals/$id/complete';
  
  static String uncompleteGoal(int id) => '$goals/$id/uncomplete';
  
  static String goalChildren(int id) => '$goals/$id/children';
  
  static String get todayGoals => '$goals/today';
  
  static String get activeGoals => '$goals/status/ACTIVE';
  
  static String get completedGoals => '$goals/status/COMPLETED';
  
  static String get rootGoals => '$goals/root';
  
  static String goalsByType(String type) => '$goals/type/$type';
  
  static String availableSubTypes(String parentType) => '$goals/types/$parentType/available-subtypes';
  
  // 비동기 버전들 (설정 화면에서 사용할 예정)
  static Future<String> get goalsAsync async {
    final baseUrl = await getBaseUrl();
    return '$baseUrl/goals';
  }
}
