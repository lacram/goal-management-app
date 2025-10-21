import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../../data/models/routine.dart';

class RoutineApiService {
  /// 전체 루틴 조회
  Future<List<Routine>> getAllRoutines() async {
    final url = ApiEndpoints.routines;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Routine.fromJson(json)).toList();
    } else {
      throw Exception('루틴 조회 실패: ${response.statusCode}');
    }
  }

  /// 활성화된 루틴만 조회
  Future<List<Routine>> getActiveRoutines() async {
    final url = ApiEndpoints.activeRoutines;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Routine.fromJson(json)).toList();
    } else {
      throw Exception('활성 루틴 조회 실패: ${response.statusCode}');
    }
  }

  /// 오늘의 루틴 조회
  Future<List<Routine>> getTodayRoutines() async {
    final url = ApiEndpoints.todayRoutines;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Routine.fromJson(json)).toList();
    } else {
      throw Exception('오늘의 루틴 조회 실패: ${response.statusCode}');
    }
  }

  /// 루틴 상세 조회
  Future<Routine> getRoutineById(int id) async {
    final url = ApiEndpoints.routineById(id);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      return Routine.fromJson(jsonData);
    } else {
      throw Exception('루틴 상세 조회 실패: ${response.statusCode}');
    }
  }

  /// 루틴 생성
  Future<Routine> createRoutine(Routine routine) async {
    final url = ApiEndpoints.routines;
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(routine.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      return Routine.fromJson(jsonData);
    } else {
      throw Exception('루틴 생성 실패: ${response.statusCode}');
    }
  }

  /// 루틴 수정
  Future<Routine> updateRoutine(int id, Routine routine) async {
    final url = ApiEndpoints.routineById(id);
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(routine.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      return Routine.fromJson(jsonData);
    } else {
      throw Exception('루틴 수정 실패: ${response.statusCode}');
    }
  }

  /// 루틴 삭제
  Future<void> deleteRoutine(int id) async {
    final url = ApiEndpoints.routineById(id);
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('루틴 삭제 실패: ${response.statusCode}');
    }
  }

  /// 루틴 완료 체크
  Future<RoutineCompletion> completeRoutine(int id, {String? note}) async {
    final url = ApiEndpoints.completeRoutine(id);
    final body = note != null ? json.encode({'note': note}) : '{}';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      return RoutineCompletion.fromJson(jsonData);
    } else {
      throw Exception('루틴 완료 체크 실패: ${response.statusCode}');
    }
  }

  /// 루틴 완료 취소
  Future<void> uncompleteRoutine(int id) async {
    final url = ApiEndpoints.completeRoutine(id);
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('루틴 완료 취소 실패: ${response.statusCode}');
    }
  }

  /// 루틴 완료 히스토리 조회
  Future<List<RoutineCompletion>> getRoutineCompletions(int id) async {
    final url = ApiEndpoints.routineCompletions(id);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => RoutineCompletion.fromJson(json)).toList();
    } else {
      throw Exception('완료 히스토리 조회 실패: ${response.statusCode}');
    }
  }
}
