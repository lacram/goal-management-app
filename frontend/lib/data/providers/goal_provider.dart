import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/services/app_logger.dart';
import '../models/goal.dart';

class GoalProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // 상태 변수들
  List<Goal> _goals = [];
  List<Goal> _todayGoals = [];
  List<Goal> _activeGoals = [];
  List<Goal> _completedGoals = [];
  bool _isLoading = false;
  String? _error;
  
  // 캐싱을 위한 마지막 로드 시간
  DateTime? _lastLoadTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  // Getters
  List<Goal> get goals => _goals;
  List<Goal> get allGoals => _goals;
  List<Goal> get todayGoals => _todayGoals;
  List<Goal> get activeGoals => _activeGoals;
  List<Goal> get completedGoals => _completedGoals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // API Service getter for external access
  ApiService get apiService => _apiService;

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

  // 모든 목표 조회 - 캐싱 기능 추가
  Future<void> loadAllGoals({bool forceRefresh = false}) async {
    // 캐시 체크: 강제 새로고침이 아니고 최근에 로드했다면 스킵
    if (!forceRefresh && _lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < _cacheTimeout &&
        _goals.isNotEmpty) {
      logger.info('GoalProvider', '캐시된 목표 데이터 사용');
      return;
    }
    
    try {
      logger.info('GoalProvider', '모든 목표 로드 시작');
      _setLoading(true);
      _setError(null);
      _goals = await _apiService.getAllGoals();
      _lastLoadTime = DateTime.now();
      logger.info('GoalProvider', '모든 목표 로드 성공: ${_goals.length}개');
      notifyListeners();
    } catch (e, stackTrace) {
      _setError('목표를 불러오는데 실패했습니다: $e');
      logger.error('GoalProvider', '모든 목표 로드 실패', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  // 오늘의 목표 조회
  Future<void> loadTodayGoals() async {
    try {
      _setLoading(true);
      _setError(null);
      _todayGoals = await _apiService.getTodayGoals();
      notifyListeners();
    } catch (e) {
      _setError('오늘의 목표를 불러오는데 실패했습니다: $e');
      debugPrint('loadTodayGoals error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 진행중인 목표 조회
  Future<void> loadActiveGoals() async {
    try {
      _setLoading(true);
      _setError(null);
      _activeGoals = await _apiService.getActiveGoals();
      notifyListeners();
    } catch (e) {
      _setError('진행중인 목표를 불러오는데 실패했습니다: $e');
      debugPrint('loadActiveGoals error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 완료된 목표 조회
  Future<void> loadCompletedGoals() async {
    try {
      _setLoading(true);
      _setError(null);
      _completedGoals = await _apiService.getCompletedGoals();
      notifyListeners();
    } catch (e) {
      _setError('완료된 목표를 불러오는데 실패했습니다: $e');
      debugPrint('loadCompletedGoals error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 새로운 목표 생성
  Future<bool> createGoal(Goal goal) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final newGoal = await _apiService.createGoal(goal);
      _goals.add(newGoal);
      
      // 관련 리스트도 업데이트
      if (newGoal.type == GoalType.daily) {
        _todayGoals.add(newGoal);
      }
      if (!newGoal.isCompleted) {
        _activeGoals.add(newGoal);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('목표 생성에 실패했습니다: $e');
      debugPrint('createGoal error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 목표 수정
  Future<bool> updateGoal(int id, Goal goal) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final updatedGoal = await _apiService.updateGoal(id, goal);
      
      // 리스트에서 목표 업데이트
      _updateGoalInLists(updatedGoal);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('목표 수정에 실패했습니다: $e');
      debugPrint('updateGoal error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 목표 삭제
  Future<bool> deleteGoal(int id) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _apiService.deleteGoal(id);
      
      // 모든 리스트에서 해당 목표 제거
      _goals.removeWhere((goal) => goal.id == id);
      _todayGoals.removeWhere((goal) => goal.id == id);
      _activeGoals.removeWhere((goal) => goal.id == id);
      _completedGoals.removeWhere((goal) => goal.id == id);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('목표 삭제에 실패했습니다: $e');
      debugPrint('deleteGoal error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 목표 완료 처리 - 낙관적 업데이트 적용 (즉시 UI 반영)
  Future<bool> completeGoal(int id) async {
    try {
      // 1. 원본 목표 찾기
      final originalGoal = _goals.firstWhere(
        (goal) => goal.id == id,
        orElse: () => throw Exception('Goal not found'),
      );

      // 2. 낙관적 업데이트: 즉시 UI에 반영 (API 응답 전)
      final optimisticGoal = originalGoal.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        status: GoalStatus.completed,
      );

      // UI 즉시 업데이트 (로딩 상태 없이)
      _updateGoalInLists(optimisticGoal);
      _activeGoals.removeWhere((goal) => goal.id == id);
      if (!_completedGoals.any((goal) => goal.id == id)) {
        _completedGoals.add(optimisticGoal);
      }
      notifyListeners(); // 1번만 호출 (즉시 UI 업데이트)

      logger.info('GoalProvider', '낙관적 업데이트 완료: ${optimisticGoal.title}');

      // 3. 백그라운드에서 API 호출 (사용자는 이미 완료된 UI 확인)
      final completedGoal = await _apiService.completeGoal(id);

      // 4. 서버 응답으로 최종 확정 (데이터 일관성 보장)
      _updateGoalInLists(completedGoal);
      notifyListeners(); // 2번째 호출 (서버 데이터로 확정)

      logger.info('GoalProvider', '서버 완료 확정: ${completedGoal.title}');
      return true;
    } catch (e, stackTrace) {
      // 5. 실패 시 롤백 (원래 상태로 복구)
      logger.error('GoalProvider', '목표 완료 실패 - 롤백 시작', e, stackTrace);

      // 백업된 목표로 복구
      final backupGoalFromError = _completedGoals.firstWhere(
        (goal) => goal.id == id,
        orElse: () => throw Exception('Backup goal not found'),
      );

      _updateGoalInLists(backupGoalFromError.copyWith(
        isCompleted: false,
        completedAt: null,
        status: GoalStatus.active,
      ));
      _completedGoals.removeWhere((goal) => goal.id == id);
      if (!_activeGoals.any((goal) => goal.id == id)) {
        _activeGoals.add(backupGoalFromError);
      }

      _setError('목표 완료 처리에 실패했습니다: $e');
      notifyListeners(); // 롤백 후 UI 업데이트
      return false;
    }
  }

  // 목표 완료 취소 - 낙관적 업데이트 적용 (즉시 UI 반영)
  Future<bool> uncompleteGoal(int id) async {
    try {
      // 1. 원본 목표 찾기
      final originalGoal = _goals.firstWhere(
        (goal) => goal.id == id,
        orElse: () => throw Exception('Goal not found'),
      );

      // 2. 낙관적 업데이트: 즉시 UI에 반영 (API 응답 전)
      final optimisticGoal = originalGoal.copyWith(
        isCompleted: false,
        completedAt: null,
        status: GoalStatus.active,
      );

      // UI 즉시 업데이트 (로딩 상태 없이)
      _updateGoalInLists(optimisticGoal);
      _completedGoals.removeWhere((goal) => goal.id == id);
      if (!_activeGoals.any((goal) => goal.id == id)) {
        _activeGoals.add(optimisticGoal);
      }
      notifyListeners(); // 1번만 호출 (즉시 UI 업데이트)

      logger.info('GoalProvider', '낙관적 업데이트 완료 (취소): ${optimisticGoal.title}');

      // 3. 백그라운드에서 API 호출
      final uncompletedGoal = await _apiService.uncompleteGoal(id);

      // 4. 서버 응답으로 최종 확정
      _updateGoalInLists(uncompletedGoal);
      notifyListeners(); // 2번째 호출 (서버 데이터로 확정)

      logger.info('GoalProvider', '서버 완료 취소 확정: ${uncompletedGoal.title}');
      return true;
    } catch (e, stackTrace) {
      // 5. 실패 시 롤백 (원래 상태로 복구)
      logger.error('GoalProvider', '목표 완료 취소 실패 - 롤백 시작', e, stackTrace);

      // 백업된 목표로 복구
      final backupGoalFromError = _activeGoals.firstWhere(
        (goal) => goal.id == id,
        orElse: () => throw Exception('Backup goal not found'),
      );

      _updateGoalInLists(backupGoalFromError.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        status: GoalStatus.completed,
      ));
      _activeGoals.removeWhere((goal) => goal.id == id);
      if (!_completedGoals.any((goal) => goal.id == id)) {
        _completedGoals.add(backupGoalFromError);
      }

      _setError('목표 완료 취소에 실패했습니다: $e');
      notifyListeners(); // 롤백 후 UI 업데이트
      return false;
    }
  }

  // 타입별 목표 조회
  Future<List<Goal>> getGoalsByType(GoalType type) async {
    try {
      return await _apiService.getGoalsByType(type);
    } catch (e) {
      _setError('타입별 목표 조회에 실패했습니다: $e');
      debugPrint('getGoalsByType error: $e');
      return [];
    }
  }

  // 하위 목표 조회
  Future<List<Goal>> getGoalChildren(int parentId) async {
    try {
      return await _apiService.getGoalChildren(parentId);
    } catch (e) {
      _setError('하위 목표 조회에 실패했습니다: $e');
      debugPrint('getGoalChildren error: $e');
      return [];
    }
  }

  // 생성 가능한 하위 타입 조회
  Future<List<GoalType>> getAvailableSubTypes(GoalType parentType) async {
    try {
      return await _apiService.getAvailableSubTypes(parentType);
    } catch (e) {
      debugPrint('getAvailableSubTypes error: $e');
      return [];
    }
  }

  // 리스트에서 목표 업데이트 헬퍼 메서드 - 최적화
  void _updateGoalInLists(Goal updatedGoal) {
    final goalId = updatedGoal.id;
    
    // 전체 목표 리스트 업데이트
    _updateGoalInList(_goals, updatedGoal, goalId);
    
    // 오늘의 목표 리스트 업데이트
    _updateGoalInList(_todayGoals, updatedGoal, goalId);
    
    // 활성 목표 리스트 업데이트
    _updateGoalInList(_activeGoals, updatedGoal, goalId);
    
    // 완료된 목표 리스트 업데이트
    _updateGoalInList(_completedGoals, updatedGoal, goalId);
  }
  
  // 단일 리스트 업데이트 헬퍼
  void _updateGoalInList(List<Goal> list, Goal updatedGoal, int? goalId) {
    final index = list.indexWhere((goal) => goal.id == goalId);
    if (index != -1) {
      list[index] = updatedGoal;
    }
  }

  // 에러 초기화
  void clearError() {
    _setError(null);
  }

  // 전체 데이터 새로고침 - 효율적인 방식 + 캐시 초기화
  Future<void> refreshAllData() async {
    try {
      _setLoading(true);
      _setError(null);
      
      // 캐시 초기화
      _lastLoadTime = null;
      
      // 병렬 로딩으로 성능 향상
      final results = await Future.wait([
        _apiService.getAllGoals(),
        _apiService.getTodayGoals(),
        _apiService.getActiveGoals(),
        _apiService.getCompletedGoals(),
      ]);
      
      _goals = results[0];
      _todayGoals = results[1];
      _activeGoals = results[2];
      _completedGoals = results[3];
      _lastLoadTime = DateTime.now();
      
      notifyListeners();
    } catch (e, stackTrace) {
      _setError('데이터 새로고침에 실패했습니다: $e');
      logger.error('GoalProvider', '전체 데이터 새로고침 실패', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }
}