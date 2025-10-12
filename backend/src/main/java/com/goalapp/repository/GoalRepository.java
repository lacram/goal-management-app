package com.goalapp.repository;

import com.goalapp.entity.Goal;
import com.goalapp.entity.GoalStatus;
import com.goalapp.entity.GoalType;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface GoalRepository extends JpaRepository<Goal, Long> {
    
    // N+1 문제 해결: subGoals를 한 번에 로드
    @EntityGraph(attributePaths = {"subGoals"})
    @Override
    List<Goal> findAll();
    
    // findById에도 EntityGraph 적용
    @EntityGraph(attributePaths = {"subGoals"})
    @Override
    Optional<Goal> findById(Long id);
    
    // 상위 목표가 없는 루트 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    List<Goal> findByParentGoalIsNull();
    
    // 특정 타입의 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    List<Goal> findByType(GoalType type);
    
    // 특정 상태의 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    List<Goal> findByStatus(GoalStatus status);
    
    // 특정 타입과 상태로 조회
    @EntityGraph(attributePaths = {"subGoals"})
    List<Goal> findByTypeAndStatus(GoalType type, GoalStatus status);
    
    // 특정 상위 목표의 하위 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    @Query("SELECT g FROM Goal g WHERE g.parentGoal.id = :parentGoalId")
    List<Goal> findByParentGoalId(@Param("parentGoalId") Long parentGoalId);
    
    // 상태별 목표 개수 조회
    long countByStatus(GoalStatus status);
    
    // 마감일이 지난 미완료 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    @Query("SELECT g FROM Goal g WHERE g.dueDate < :currentDate AND g.status = 'ACTIVE'")
    List<Goal> findOverdueGoals(@Param("currentDate") LocalDateTime currentDate);
    
    // 오늘 마감인 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    @Query("SELECT g FROM Goal g WHERE DATE(g.dueDate) = DATE(:today) AND g.status = 'ACTIVE'")
    List<Goal> findGoalsDueToday(@Param("today") LocalDateTime today);
    
    // 특정 기간 내 생성된 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    @Query("SELECT g FROM Goal g WHERE g.createdAt BETWEEN :startDate AND :endDate")
    List<Goal> findGoalsCreatedBetween(@Param("startDate") LocalDateTime startDate, 
                                      @Param("endDate") LocalDateTime endDate);
    
    // 우선순위별 정렬된 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    List<Goal> findByParentGoalIsNullOrderByPriorityDesc();
    
    // 모든 목표를 우선순위 순으로 조회
    @EntityGraph(attributePaths = {"subGoals"})
    List<Goal> findAllByOrderByPriorityDesc();
    
    // 알림이 활성화된 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    List<Goal> findByReminderEnabledTrue();
    
    // 알림이 비활성화된 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    List<Goal> findByReminderEnabledFalse();
    
    // 제목으로 목표 검색
    @EntityGraph(attributePaths = {"subGoals"})
    @Query("SELECT g FROM Goal g WHERE g.title LIKE %:keyword% OR g.description LIKE %:keyword%")
    List<Goal> searchGoalsByKeyword(@Param("keyword") String keyword);
    
    // 오늘의 목표들 조회 (활성 + 오늘 완료된 목표)
    @EntityGraph(attributePaths = {"subGoals"})
    @Query("SELECT g FROM Goal g WHERE " +
           "(g.type = 'DAILY' AND g.createdAt >= :startOfDay AND g.createdAt < :endOfDay) " +
           "OR (g.dueDate >= :startOfDay AND g.dueDate < :endOfDay) " +
           "OR (g.status = 'COMPLETED' AND g.completedAt >= :startOfDay AND g.completedAt < :endOfDay)")
    List<Goal> findTodayGoals(@Param("startOfDay") LocalDateTime startOfDay,
                             @Param("endOfDay") LocalDateTime endOfDay);
    
    // 목표일 범위로 조회
    @EntityGraph(attributePaths = {"subGoals"})
    List<Goal> findByDueDateBetween(LocalDateTime startDate, LocalDateTime endDate);
    
    // 특정 우선순위의 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    List<Goal> findByPriority(Integer priority);
    
    // 우선순위가 특정 값 이상인 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    List<Goal> findByPriorityGreaterThanEqual(Integer priority);
    
    // 특정 기간에 완료된 목표들 조회
    @EntityGraph(attributePaths = {"subGoals"})
    @Query("SELECT g FROM Goal g WHERE g.status = 'COMPLETED' AND g.completedAt BETWEEN :startDate AND :endDate")
    List<Goal> findCompletedGoalsBetween(@Param("startDate") LocalDateTime startDate,
                                        @Param("endDate") LocalDateTime endDate);
}
