import 'package:shared_preferences/shared_preferences.dart';

class ApiEndpoints {
  // 기본 프로덕션 URL (Render)
  static const String defaultProdBaseUrl = 'https://goal-management-app.onrender.com/api';
  // 기본 개발용 URL (로컬 서버)
  static const String defaultDevBaseUrl = 'http://192.168.0.11:8080/api';
  // localhost URL (Windows 데스크톱)
  static const String localhostUrl = 'http://localhost:8080/api';

  // 빌드 타임에 환경 설정 (flutter run --dart-define=ENV=prod|dev|local)
  static const String buildEnvironment = String.fromEnvironment('ENV', defaultValue: 'dev');

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

  // 환경별 기본 URL 결정
  static String _getDefaultBaseUrl() {
    // 빌드 타임 환경 변수에 따라 URL 선택
    switch (buildEnvironment) {
      case 'prod':
        // 프로덕션: Railway 서버
        return defaultProdBaseUrl;
      case 'local':
        // 로컬호스트: Windows 데스크톱에서 테스트
        return localhostUrl;
      case 'dev':
      default:
        // 개발: 로컬 네트워크 서버 (모바일 기기에서 접근 가능)
        return defaultDevBaseUrl;
    }
  }

  // 현재 사용 중인 환경 확인
  static String get currentEnvironment => buildEnvironment;
  
  // 캐시된 base URL (앱 시작 시 초기화)
  static String? _cachedBaseUrl;

  // Base URL 초기화 (앱 시작 시 한 번만 호출)
  static Future<void> initialize() async {
    _cachedBaseUrl = await getBaseUrl();
  }

  // 캐시된 base URL 또는 기본값 반환
  static String get _baseUrl => _cachedBaseUrl ?? _getDefaultBaseUrl();

  // Goal 관련 엔드포인트
  static String get goals => '$_baseUrl/goals';

  static String goalById(int id) => '$_baseUrl/goals/$id';

  static String completeGoal(int id) => '$_baseUrl/goals/$id/complete';

  static String uncompleteGoal(int id) => '$_baseUrl/goals/$id/uncomplete';

  static String goalChildren(int id) => '$_baseUrl/goals/$id/children';

  static String get todayGoals => '$_baseUrl/goals/today';

  static String get activeGoals => '$_baseUrl/goals/status/ACTIVE';

  static String get completedGoals => '$_baseUrl/goals/status/COMPLETED';

  static String get rootGoals => '$_baseUrl/goals/root';

  static String goalsByType(String type) => '$_baseUrl/goals/type/$type';

  static String availableSubTypes(String parentType) => '$_baseUrl/goals/types/$parentType/available-subtypes';

  // 만료 관련 엔드포인트
  static String get expiredGoals => '$_baseUrl/goals/expired';

  static String expiringSoonGoals(int hours) => '$_baseUrl/goals/expiring-soon?hours=$hours';

  static String get archivedGoals => '$_baseUrl/goals/archived';

  static String expireGoal(int id) => '$_baseUrl/goals/$id/expire';

  static String archiveGoal(int id) => '$_baseUrl/goals/$id/archive';

  static String extendGoal(int id, int days) => '$_baseUrl/goals/$id/extend?days=$days';

  // Routine 관련 엔드포인트
  static String get routines => '$_baseUrl/routines';

  static String routineById(int id) => '$_baseUrl/routines/$id';

  static String get activeRoutines => '$_baseUrl/routines/active';

  static String get todayRoutines => '$_baseUrl/routines/today';

  static String completeRoutine(int id) => '$_baseUrl/routines/$id/complete';

  static String routineCompletions(int id) => '$_baseUrl/routines/$id/completions';

  // ===== FCM 관련 엔드포인트 =====

  // 디바이스 토큰 관리
  static String get deviceTokens => '$_baseUrl/device-tokens';

  static String deviceTokenById(int id) => '$_baseUrl/device-tokens/$id';

  static String get deviceTokenByToken => '$_baseUrl/device-tokens/by-token';

  static String get sendTestNotification => '$_baseUrl/device-tokens/test-notification';

  // 비동기 버전들 (설정 화면에서 사용할 예정)
  static Future<String> get goalsAsync async {
    final baseUrl = await getBaseUrl();
    return '$baseUrl/goals';
  }

  static Future<String> get routinesAsync async {
    final baseUrl = await getBaseUrl();
    return '$baseUrl/routines';
  }

  // Base URL 갱신 (설정 변경 시 호출)
  static Future<void> refreshBaseUrl() async {
    _cachedBaseUrl = await getBaseUrl();
  }
}
