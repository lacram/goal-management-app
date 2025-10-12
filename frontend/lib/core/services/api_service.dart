import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../../data/models/goal.dart';
import '../services/app_logger.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 10);

  // GET 요청 헬퍼
  Future<http.Response> _get(String url) async {
    try {
      logger.networkRequest('GET', url);
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);
      logger.networkResponse(response.statusCode, url);
      return response;
    } catch (e, stackTrace) {
      logger.networkError(url, e, stackTrace);
      throw Exception('네트워크 오류: $e');
    }
  }

  // POST 요청 헬퍼
  Future<http.Response> _post(String url, Map<String, dynamic> body) async {
    try {
      logger.networkRequest('POST', url, body);
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout);
      logger.networkResponse(response.statusCode, url);
      return response;
    } catch (e, stackTrace) {
      logger.networkError(url, e, stackTrace);
      throw Exception('네트워크 오류: $e');
    }
  }

  // PUT 요청 헬퍼
  Future<http.Response> _put(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout);
      return response;
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // PATCH 요청 헬퍼
  Future<http.Response> _patch(String url) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);
      return response;
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // DELETE 요청 헬퍼
  Future<http.Response> _delete(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);
      return response;
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 응답 처리 헬퍼
  T _handleResponse<T>(http.Response response, T Function(dynamic) parser) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return parser(null);
      }
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      return parser(decodedBody);
    } else {
      throw Exception('API 오류 ${response.statusCode}: ${response.body}');
    }
  }

  // 모든 목표 조회
  Future<List<Goal>> getAllGoals() async {
    final response = await _get(ApiEndpoints.goals);
    return _handleResponse(response, (data) {
      return (data as List).map((json) => Goal.fromJson(json)).toList();
    });
  }

  // 목표 상세 조회
  Future<Goal> getGoal(int id) async {
    final response = await _get(ApiEndpoints.goalById(id));
    return _handleResponse(response, (data) => Goal.fromJson(data));
  }

  // 목표 생성
  Future<Goal> createGoal(Goal goal) async {
    final body = {
      'title': goal.title,
      'description': goal.description,
      'type': goal.type.value,
      'parentGoalId': goal.parentGoalId,
      'dueDate': goal.dueDate?.toIso8601String(),
      'priority': goal.priority,
      'reminderEnabled': goal.reminderEnabled,
      'reminderFrequency': goal.reminderFrequency,
    };

    final response = await _post(ApiEndpoints.goals, body);
    return _handleResponse(response, (data) => Goal.fromJson(data));
  }

  // 목표 수정
  Future<Goal> updateGoal(int id, Goal goal) async {
    final body = {
      'title': goal.title,
      'description': goal.description,
      'dueDate': goal.dueDate?.toIso8601String(),
      'priority': goal.priority,
      'reminderEnabled': goal.reminderEnabled,
      'reminderFrequency': goal.reminderFrequency,
    };

    final response = await _put(ApiEndpoints.goalById(id), body);
    return _handleResponse(response, (data) => Goal.fromJson(data));
  }

  // 목표 삭제
  Future<void> deleteGoal(int id) async {
    final response = await _delete(ApiEndpoints.goalById(id));
    _handleResponse(response, (_) => null);
  }

  // 목표 완료 처리
  Future<Goal> completeGoal(int id) async {
    final response = await _patch(ApiEndpoints.completeGoal(id));
    return _handleResponse(response, (data) => Goal.fromJson(data));
  }

  // 목표 완료 취소
  Future<Goal> uncompleteGoal(int id) async {
    final response = await _patch(ApiEndpoints.uncompleteGoal(id));
    return _handleResponse(response, (data) => Goal.fromJson(data));
  }

  // 오늘의 목표 조회
  Future<List<Goal>> getTodayGoals() async {
    final response = await _get(ApiEndpoints.todayGoals);
    return _handleResponse(response, (data) {
      return (data as List).map((json) => Goal.fromJson(json)).toList();
    });
  }

  // 진행중인 목표 조회
  Future<List<Goal>> getActiveGoals() async {
    final response = await _get(ApiEndpoints.activeGoals);
    return _handleResponse(response, (data) {
      return (data as List).map((json) => Goal.fromJson(json)).toList();
    });
  }

  // 완료된 목표 조회
  Future<List<Goal>> getCompletedGoals() async {
    final response = await _get(ApiEndpoints.completedGoals);
    return _handleResponse(response, (data) {
      return (data as List).map((json) => Goal.fromJson(json)).toList();
    });
  }

  // 최상위 목표 조회
  Future<List<Goal>> getRootGoals() async {
    final response = await _get(ApiEndpoints.rootGoals);
    return _handleResponse(response, (data) {
      return (data as List).map((json) => Goal.fromJson(json)).toList();
    });
  }

  // 타입별 목표 조회
  Future<List<Goal>> getGoalsByType(GoalType type) async {
    final response = await _get(ApiEndpoints.goalsByType(type.value));
    return _handleResponse(response, (data) {
      return (data as List).map((json) => Goal.fromJson(json)).toList();
    });
  }

  // 하위 목표 조회
  Future<List<Goal>> getGoalChildren(int parentId) async {
    final response = await _get(ApiEndpoints.goalChildren(parentId));
    return _handleResponse(response, (data) {
      return (data as List).map((json) => Goal.fromJson(json)).toList();
    });
  }

  // 생성 가능한 하위 타입 조회
  Future<List<GoalType>> getAvailableSubTypes(GoalType parentType) async {
    final response = await _get(ApiEndpoints.availableSubTypes(parentType.value));
    return _handleResponse(response, (data) {
      return (data as List).map((typeString) => GoalType.fromString(typeString)).toList();
    });
  }
}