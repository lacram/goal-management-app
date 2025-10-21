package com.goalapp.controller;

import com.goalapp.dto.request.CreateGoalRequest;
import com.goalapp.dto.request.UpdateGoalRequest;
import com.goalapp.dto.response.GoalResponse;
import com.goalapp.entity.Goal;
import com.goalapp.entity.GoalStatus;
import com.goalapp.entity.GoalType;
import com.goalapp.service.GoalService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/goals")
@RequiredArgsConstructor
@Slf4j
public class GoalController {

    private final GoalService goalService;

    /**
     * 전체 목표 목록 조회
     */
    @GetMapping
    public ResponseEntity<List<GoalResponse>> getAllGoals() {
        List<Goal> goals = goalService.getAllGoals();
        List<GoalResponse> responses = goals.stream()
                .map(GoalResponse::fromWithoutSubGoals)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 타입별 목표 조회 - {goalId}보다 먼저 정의
     */
    @GetMapping("/type/{type}")
    public ResponseEntity<List<GoalResponse>> getGoalsByType(@PathVariable GoalType type) {
        List<Goal> goals = goalService.getGoalsByType(type);
        List<GoalResponse> responses = goals.stream()
                .map(GoalResponse::fromWithoutSubGoals)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 특정 타입에서 생성 가능한 하위 타입들 조회
     */
    @GetMapping("/types/{type}/available-subtypes")
    public ResponseEntity<List<GoalType>> getAvailableSubTypes(@PathVariable GoalType type) {
        log.debug("Getting available subtypes for: {}", type);
        List<GoalType> availableSubTypes = goalService.getAvailableSubTypes(type);
        return ResponseEntity.ok(availableSubTypes);
    }

    /**
     * 상태별 목표 조회 - {goalId}보다 먼저 정의
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<List<GoalResponse>> getGoalsByStatus(@PathVariable GoalStatus status) {
        List<Goal> goals = goalService.getGoalsByStatus(status);
        List<GoalResponse> responses = goals.stream()
                .map(GoalResponse::fromWithoutSubGoals)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 최상위 목표들 조회 - {goalId}보다 먼저 정의
     */
    @GetMapping("/root")
    public ResponseEntity<List<GoalResponse>> getRootGoals() {
        List<Goal> rootGoals = goalService.getRootGoals();
        List<GoalResponse> responses = rootGoals.stream()
                .map(GoalResponse::fromWithoutSubGoals)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 오늘의 목표들 조회 - {goalId}보다 먼저 정의
     */
    @GetMapping("/today")
    public ResponseEntity<List<GoalResponse>> getTodayGoals() {
        List<Goal> todayGoals = goalService.getTodayGoals();
        List<GoalResponse> responses = todayGoals.stream()
                .map(GoalResponse::fromWithoutSubGoals)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 목표 상세 조회 - 구체적인 경로들 이후에 정의
     */
    @GetMapping("/{goalId}")
    public ResponseEntity<GoalResponse> getGoal(@PathVariable Long goalId) {
        Goal goal = goalService.getGoalByIdWithSubGoals(goalId);
        return ResponseEntity.ok(GoalResponse.from(goal));
    }

    /**
     * 하위 목표들 조회
     */
    @GetMapping("/{goalId}/children")
    public ResponseEntity<List<GoalResponse>> getChildGoals(@PathVariable Long goalId) {
        List<Goal> childGoals = goalService.getChildGoals(goalId);
        List<GoalResponse> responses = childGoals.stream()
                .map(GoalResponse::fromWithoutSubGoals)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 목표 진행률 조회
     */
    @GetMapping("/{goalId}/progress")
    public ResponseEntity<Map<String, Object>> getGoalProgress(@PathVariable Long goalId) {
        Goal goal = goalService.getGoalById(goalId);
        double progressPercentage = goalService.calculateProgressPercentage(goal);
        
        Map<String, Object> response = new HashMap<>();
        response.put("goalId", goalId);
        response.put("progressPercentage", progressPercentage);
        
        return ResponseEntity.ok(response);
    }

    /**
     * 목표 생성
     */
    @PostMapping
    public ResponseEntity<GoalResponse> createGoal(@Valid @RequestBody CreateGoalRequest request) {
        log.info("Creating goal: {}", request.getTitle());
        
        Goal goal = Goal.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .type(request.getType())
                .priority(request.getPriority())
                .reminderEnabled(request.isReminderEnabled())
                .reminderFrequency(request.getReminderFrequency())
                .dueDate(request.getDueDate())
                .build();
                
        // 부모 목표 설정
        if (request.getParentGoalId() != null) {
            Goal parentGoal = goalService.getGoalById(request.getParentGoalId());
            goal.setParentGoal(parentGoal);
        }
        
        Goal savedGoal = goalService.createGoal(goal);
        return ResponseEntity.status(HttpStatus.CREATED).body(GoalResponse.fromWithoutSubGoals(savedGoal));
    }

    /**
     * 목표 수정
     */
    @PutMapping("/{goalId}")
    public ResponseEntity<GoalResponse> updateGoal(
            @PathVariable Long goalId,
            @Valid @RequestBody UpdateGoalRequest request) {
        log.info("Updating goal: {}", goalId);
        
        Goal updateData = Goal.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .priority(request.getPriority() != null ? request.getPriority() : 0)
                .dueDate(request.getDueDate())
                .reminderFrequency(request.getReminderFrequency())
                .build();
        
        Goal updatedGoal = goalService.updateGoal(goalId, updateData);
        return ResponseEntity.ok(GoalResponse.fromWithoutSubGoals(updatedGoal));
    }

    /**
     * 목표 삭제
     */
    @DeleteMapping("/{goalId}")
    public ResponseEntity<Void> deleteGoal(@PathVariable Long goalId) {
        log.info("Deleting goal: {}", goalId);
        goalService.deleteGoal(goalId);
        return ResponseEntity.noContent().build();
    }


    /**
     * 목표 완료 처리
     */
    @PatchMapping("/{goalId}/complete")
    public ResponseEntity<GoalResponse> completeGoal(@PathVariable Long goalId) {
        log.info("Completing goal: {}", goalId);
        Goal completedGoal = goalService.completeGoal(goalId);
        return ResponseEntity.ok(GoalResponse.fromWithoutSubGoals(completedGoal));
    }

    /**
     * 목표 완료 취소
     */
    @PatchMapping("/{goalId}/uncomplete")
    public ResponseEntity<GoalResponse> uncompleteGoal(@PathVariable Long goalId) {
        log.info("Uncompleting goal: {}", goalId);
        Goal uncompletedGoal = goalService.uncompleteGoal(goalId);
        return ResponseEntity.ok(GoalResponse.fromWithoutSubGoals(uncompletedGoal));
    }

    // ===== 만료 관련 API =====

    /**
     * 만료된 목표들 조회
     */
    @GetMapping("/expired")
    public ResponseEntity<List<GoalResponse>> getExpiredGoals() {
        List<Goal> expiredGoals = goalService.getExpiredGoals();
        List<GoalResponse> responses = expiredGoals.stream()
                .map(GoalResponse::from)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 만료 임박 목표들 조회
     * @param hours 만료 몇 시간 전까지의 목표를 조회할지 (기본: 24시간)
     */
    @GetMapping("/expiring-soon")
    public ResponseEntity<List<GoalResponse>> getExpiringSoonGoals(
            @RequestParam(defaultValue = "24") int hours) {
        List<Goal> expiringSoon = goalService.getExpiringSoonGoals(hours);
        List<GoalResponse> responses = expiringSoon.stream()
                .map(GoalResponse::from)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 보관된 목표들 조회
     */
    @GetMapping("/archived")
    public ResponseEntity<List<GoalResponse>> getArchivedGoals() {
        List<Goal> archivedGoals = goalService.getArchivedGoals();
        List<GoalResponse> responses = archivedGoals.stream()
                .map(GoalResponse::from)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 목표 수동 만료 처리
     */
    @PostMapping("/{goalId}/expire")
    public ResponseEntity<GoalResponse> expireGoal(@PathVariable Long goalId) {
        log.info("Expiring goal: {}", goalId);
        Goal expiredGoal = goalService.expireGoal(goalId);
        return ResponseEntity.ok(GoalResponse.fromWithoutSubGoals(expiredGoal));
    }

    /**
     * 목표 보관 처리
     */
    @PostMapping("/{goalId}/archive")
    public ResponseEntity<GoalResponse> archiveGoal(@PathVariable Long goalId) {
        log.info("Archiving goal: {}", goalId);
        Goal archivedGoal = goalService.archiveGoal(goalId);
        return ResponseEntity.ok(GoalResponse.fromWithoutSubGoals(archivedGoal));
    }

    /**
     * 목표 기간 연장
     * @param goalId 목표 ID
     * @param days 연장할 일수
     */
    @PostMapping("/{goalId}/extend")
    public ResponseEntity<GoalResponse> extendGoalDueDate(
            @PathVariable Long goalId,
            @RequestParam int days) {
        log.info("Extending goal due date: {} by {} days", goalId, days);
        Goal extendedGoal = goalService.extendGoalDueDate(goalId, days);
        return ResponseEntity.ok(GoalResponse.fromWithoutSubGoals(extendedGoal));
    }
}
