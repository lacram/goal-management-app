import 'package:flutter/foundation.dart';
import '../../core/services/routine_api_service.dart';
import '../../core/services/app_logger.dart';
import '../models/routine.dart';

class RoutineProvider extends ChangeNotifier {
  final RoutineApiService _apiService = RoutineApiService();

  // 상태 변수들
  List<Routine> _routines = [];
  List<Routine> _activeRoutines = [];
  List<Routine> _todayRoutines = [];
  bool _isLoading = false;
  String? _error;

  // 캐싱을 위한 마지막 로드 시간
  DateTime? _lastLoadTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  // Getters
  List<Routine> get routines => _routines;
  List<Routine> get activeRoutines => _activeRoutines;
  List<Routine> get todayRoutines => _todayRoutines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // API Service getter for external access
  RoutineApiService get apiService => _apiService;

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 에러 상태 설정
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // 전체 루틴 조회
  Future<void> loadAllRoutines({bool forceRefresh = false}) async {
    // 캐시 체크
    if (!forceRefresh &&
        _lastLoadTime != null &&
        DateTime.now().difference(_lastLoadTime!) < _cacheTimeout &&
        _routines.isNotEmpty) {
      logger.info('RoutineProvider', '캐시된 루틴 데이터 사용');
      return;
    }

    try {
      logger.info('RoutineProvider', '전체 루틴 로드 시작');
      _setLoading(true);
      _setError(null);
      _routines = await _apiService.getAllRoutines();
      _lastLoadTime = DateTime.now();
      logger.info('RoutineProvider', '전체 루틴 로드 성공: ${_routines.length}개');
      notifyListeners();
    } catch (e, stackTrace) {
      _setError('루틴을 불러오는데 실패했습니다: $e');
      logger.error('RoutineProvider', '전체 루틴 로드 실패', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  // 활성화된 루틴만 조회
  Future<void> loadActiveRoutines() async {
    try {
      _setLoading(true);
      _setError(null);
      _activeRoutines = await _apiService.getActiveRoutines();
      notifyListeners();
    } catch (e) {
      _setError('활성 루틴을 불러오는데 실패했습니다: $e');
      debugPrint('loadActiveRoutines error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 오늘의 루틴 조회
  Future<void> loadTodayRoutines() async {
    try {
      _setLoading(true);
      _setError(null);
      _todayRoutines = await _apiService.getTodayRoutines();
      notifyListeners();
    } catch (e) {
      _setError('오늘의 루틴을 불러오는데 실패했습니다: $e');
      debugPrint('loadTodayRoutines error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 루틴 생성
  Future<bool> createRoutine(Routine routine) async {
    try {
      _setLoading(true);
      _setError(null);

      final newRoutine = await _apiService.createRoutine(routine);
      _routines.add(newRoutine);

      if (newRoutine.isActive) {
        _activeRoutines.add(newRoutine);
        _todayRoutines.add(newRoutine);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('루틴 생성에 실패했습니다: $e');
      debugPrint('createRoutine error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 루틴 수정
  Future<bool> updateRoutine(int id, Routine routine) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedRoutine = await _apiService.updateRoutine(id, routine);

      // 리스트에서 루틴 업데이트
      _updateRoutineInLists(updatedRoutine);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('루틴 수정에 실패했습니다: $e');
      debugPrint('updateRoutine error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 루틴 삭제
  Future<bool> deleteRoutine(int id) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.deleteRoutine(id);

      // 모든 리스트에서 해당 루틴 제거
      _routines.removeWhere((routine) => routine.id == id);
      _activeRoutines.removeWhere((routine) => routine.id == id);
      _todayRoutines.removeWhere((routine) => routine.id == id);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('루틴 삭제에 실패했습니다: $e');
      debugPrint('deleteRoutine error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 루틴 완료 체크
  Future<bool> completeRoutine(int id, {String? note}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.completeRoutine(id, note: note);

      // 루틴을 완료 상태로 업데이트
      _updateRoutineCompletionStatus(id, true);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('루틴 완료 처리에 실패했습니다: $e');
      debugPrint('completeRoutine error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 루틴 완료 취소
  Future<bool> uncompleteRoutine(int id) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.uncompleteRoutine(id);

      // 루틴을 미완료 상태로 업데이트
      _updateRoutineCompletionStatus(id, false);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('루틴 완료 취소에 실패했습니다: $e');
      debugPrint('uncompleteRoutine error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 루틴 완료 히스토리 조회
  Future<List<RoutineCompletion>> getRoutineCompletions(int id) async {
    try {
      return await _apiService.getRoutineCompletions(id);
    } catch (e) {
      _setError('완료 히스토리 조회에 실패했습니다: $e');
      debugPrint('getRoutineCompletions error: $e');
      return [];
    }
  }

  // 리스트에서 루틴 업데이트 헬퍼 메서드
  void _updateRoutineInLists(Routine updatedRoutine) {
    final routineId = updatedRoutine.id;

    _updateRoutineInList(_routines, updatedRoutine, routineId);
    _updateRoutineInList(_activeRoutines, updatedRoutine, routineId);
    _updateRoutineInList(_todayRoutines, updatedRoutine, routineId);
  }

  // 단일 리스트 업데이트 헬퍼
  void _updateRoutineInList(List<Routine> list, Routine updatedRoutine, int? routineId) {
    final index = list.indexWhere((routine) => routine.id == routineId);
    if (index != -1) {
      list[index] = updatedRoutine;
    }
  }

  // 루틴 완료 상태 업데이트
  void _updateRoutineCompletionStatus(int id, bool completedToday) {
    for (var i = 0; i < _routines.length; i++) {
      if (_routines[i].id == id) {
        _routines[i] = _routines[i].copyWith(completedToday: completedToday);
      }
    }
    for (var i = 0; i < _activeRoutines.length; i++) {
      if (_activeRoutines[i].id == id) {
        _activeRoutines[i] = _activeRoutines[i].copyWith(completedToday: completedToday);
      }
    }
    for (var i = 0; i < _todayRoutines.length; i++) {
      if (_todayRoutines[i].id == id) {
        _todayRoutines[i] = _todayRoutines[i].copyWith(completedToday: completedToday);
      }
    }
  }

  // 에러 초기화
  void clearError() {
    _setError(null);
  }

  // 전체 데이터 새로고침
  Future<void> refreshAllData() async {
    try {
      _setLoading(true);
      _setError(null);

      // 캐시 초기화
      _lastLoadTime = null;

      // 병렬 로딩으로 성능 향상
      final results = await Future.wait([
        _apiService.getAllRoutines(),
        _apiService.getActiveRoutines(),
        _apiService.getTodayRoutines(),
      ]);

      _routines = results[0];
      _activeRoutines = results[1];
      _todayRoutines = results[2];
      _lastLoadTime = DateTime.now();

      notifyListeners();
    } catch (e, stackTrace) {
      _setError('데이터 새로고침에 실패했습니다: $e');
      logger.error('RoutineProvider', '전체 데이터 새로고침 실패', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }
}
