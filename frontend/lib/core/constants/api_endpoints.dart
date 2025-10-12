import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ApiEndpoints {
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
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api'; // Android 에뮬레이터
    } else if (Platform.isIOS) {
      return 'http://localhost:8080/api'; // iOS 시뮬레이터
    } else {
      return defaultDevBaseUrl; // 실제 기기
    }
  }
  
  // 동적으로 엔드포인트 생성
  static Future<String> get goals async {
    final baseUrl = await getBaseUrl();
    return '$baseUrl/goals';
  }
  
  static Future<String> goalById(int id) async {
    final goalsUrl = await goals;
    return '$goalsUrl/$id';
  }
  
  static Future<String> completeGoal(int id) async {
    final goalsUrl = await goals;
    return '$goalsUrl/$id/complete';
  }
  
  static Future<String> uncompleteGoal(int id) async {
    final goalsUrl = await goals;
    return '$goalsUrl/$id/uncomplete';
  }
  
  static Future<String> goalChildren(int id) async {
    final goalsUrl = await goals;
    return '$goalsUrl/$id/children';
  }
  
  static Future<String> get todayGoals async {
    final goalsUrl = await goals;
    return '$goalsUrl/today';
  }
  
  static Future<String> get activeGoals async {
    final goalsUrl = await goals;
    return '$goalsUrl/status/ACTIVE';
  }
  
  static Future<String> get completedGoals async {
    final goalsUrl = await goals;
    return '$goalsUrl/status/COMPLETED';
  }
  
  static Future<String> get rootGoals async {
    final goalsUrl = await goals;
    return '$goalsUrl/root';
  }
  
  static Future<String> goalsByType(String type) async {
    final goalsUrl = await goals;
    return '$goalsUrl/type/$type';
  }
  
  static Future<String> availableSubTypes(String parentType) async {
    final goalsUrl = await goals;
    return '$goalsUrl/types/$parentType/available-subtypes';
  }
}
