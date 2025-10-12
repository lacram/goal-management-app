package com.goalapp.service;

import com.goalapp.entity.Goal;
import com.goalapp.entity.GoalStatus;
import com.goalapp.entity.GoalType;
import com.goalapp.repository.GoalRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.goalapp.exception.GoalNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class GoalService {

    private final GoalRepository goalRepository;

    /**
     * 모든 목표 조회
     */
    public List<Goal> getAllGoals() {
        return goalRepository.findAll();
    }

    /**
     * ID로 목표 조회
     */
    public Goal getGoalById(Long goalId) {
        return goalRepository.findById(goalId)
                .orElseThrow(() -> new GoalNotFoundException("Goal not found with id: " + goalId));
    }
    
    /**
     * ID로 목표 조회 (subGoals 포함)
     */
    public Goal getGoalByIdWithSubGoals(Long goalId) {
        Goal goal = goalRepository.findById(goalId)
                .orElseThrow(() -> new GoalNotFoundException("Goal not found with id: " + goalId));
        // EntityGraph로 subGoals가 이미 로드됨
        goal.getSubGoals().size(); // 로드 강제
        return goal;
    }

    /**
     * 목표 생성
     */
    @Transactional
    public Goal createGoal(Goal goal) {
        goal.setCreatedAt(LocalDateTime.now());
        goal.setStatus(GoalStatus.ACTIVE);
        
        Goal savedGoal = goalRepository.save(goal);
        log.info("Goal created: {}", savedGoal.getTitle());
        
        return savedGoal;
    }

    /**
     * 목표 수정
     */
    @Transactional
    public Goal updateGoal(Long goalId, Goal updatedGoal) {
        Goal existingGoal = getGoalById(goalId);
        
        // 수정 가능한 필드들만 업데이트
        if (updatedGoal.getTitle() != null) {
            existingGoal.setTitle(updatedGoal.getTitle());
        }
        if (updatedGoal.getDescription() != null) {
            existingGoal.setDescription(updatedGoal.getDescription());
        }
        if (updatedGoal.getPriority() != 0) {
            existingGoal.setPriority(updatedGoal.getPriority());
        }
        if (updatedGoal.getDueDate() != null) {
            existingGoal.setDueDate(updatedGoal.getDueDate());
        }
        if (updatedGoal.getReminderFrequency() != null) {
            existingGoal.setReminderFrequency(updatedGoal.getReminderFrequency());
        }
        
        existingGoal.setUpdatedAt(LocalDateTime.now());
        
        Goal savedGoal = goalRepository.save(existingGoal);
        log.info("Goal updated: {}", savedGoal.getTitle());
        
        return savedGoal;
    }

    /**
     * 목표 삭제
     */
    @Transactional
    public void deleteGoal(Long goalId) {
        Goal goal = getGoalById(goalId);
        goalRepository.delete(goal);
        log.info("Goal deleted: {}", goal.getTitle());
    }

    /**
     * 목표 완료 처리
     */
    @Transactional
    public Goal completeGoal(Long goalId) {
        Goal goal = getGoalById(goalId);
        goal.markAsCompleted(); // 메서드 사용으로 모든 필드 일관성 있게 설정
        
        Goal savedGoal = goalRepository.save(goal);
        log.info("Goal completed: {}", savedGoal.getTitle());
        
        return savedGoal;
    }

    /**
     * 목표 완료 취소
     */
    @Transactional
    public Goal uncompleteGoal(Long goalId) {
        Goal goal = getGoalById(goalId);
        goal.markAsIncomplete(); // 메서드 사용으로 모든 필드 일관성 있게 설정
        
        Goal savedGoal = goalRepository.save(goal);
        log.info("Goal uncompleted: {}", savedGoal.getTitle());
        
        return savedGoal;
    }

    /**
     * 타입별 목표 조회
     */
    public List<Goal> getGoalsByType(GoalType type) {
        return goalRepository.findByType(type);
    }

    /**
     * 상태별 목표 조회
     */
    public List<Goal> getGoalsByStatus(GoalStatus status) {
        return goalRepository.findByStatus(status);
    }

    /**
     * 하위 목표들 조회
     */
    public List<Goal> getChildGoals(Long parentGoalId) {
        return goalRepository.findByParentGoalId(parentGoalId);
    }

    /**
     * 최상위 목표들 조회 (부모가 없는 목표들)
     */
    public List<Goal> getRootGoals() {
        return goalRepository.findByParentGoalIsNull();
    }

    /**
     * 오늘의 목표들 조회 (활성 + 오늘 완료된 목표)
     */
    public List<Goal> getTodayGoals() {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1);
        return goalRepository.findTodayGoals(startOfDay, endOfDay);
    }

    /**
     * 목표 진행률 계산
     */
    public double calculateProgressPercentage(Goal goal) {
        if (goal == null) {
            return 0.0;
        }
        
        // 하위 목표가 있는 경우
        List<Goal> children = goalRepository.findByParentGoalId(goal.getId());
        if (!children.isEmpty()) {
            long completedChildren = children.stream()
                    .mapToLong(child -> child.getStatus() == GoalStatus.COMPLETED ? 1 : 0)
                    .sum();
            return (double) completedChildren / children.size() * 100.0;
        }
        
        // 하위 목표가 없는 경우 (리프 노드)
        return goal.getStatus() == GoalStatus.COMPLETED ? 100.0 : 0.0;
    }

    /**
     * 특정 목표 타입에서 생성 가능한 하위 타입들 반환
     */
    public List<GoalType> getAvailableSubTypes(GoalType parentType) {
        return switch (parentType) {
            case LIFETIME -> List.of(GoalType.LIFETIME_SUB);
            case LIFETIME_SUB -> List.of(GoalType.YEARLY, GoalType.MONTHLY, GoalType.WEEKLY, GoalType.DAILY);
            case YEARLY -> List.of(GoalType.MONTHLY, GoalType.WEEKLY, GoalType.DAILY);
            case MONTHLY -> List.of(GoalType.WEEKLY, GoalType.DAILY);
            case WEEKLY -> List.of(GoalType.DAILY);
            case DAILY -> List.of(); // DAILY는 하위 목표를 가질 수 없음
        };
    }
}