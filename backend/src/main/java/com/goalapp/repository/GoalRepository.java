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
    
    // 상태별 목표 개수 조회 - EntityGraph 불필요
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
    
    // 알림이 활성화된 목표들 조회 - 필요시에만 EntityGraph 사용
    List<Goal> findByReminderEnabledTrue();
    
    // 알림이 비활성화된 목표들 조회 - 필요시에만 EntityGraph 사용
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
    
    // 특정 기간에 완료된 목표들 조회 - 단순 목록에는 EntityGraph 불필요
    @Query("SELECT g FROM Goal g WHERE g.status = 'COMPLETED' AND g.completedAt BETWEEN :startDate AND :endDate")
    List<Goal> findCompletedGoalsBetween(@Param("startDate") LocalDateTime startDate,
                                        @Param("endDate") LocalDateTime endDate);

    // ===== 만료 관련 쿼리 메서드 =====

    // 만료된 목표 조회 (ACTIVE 상태이면서 dueDate가 과거인 목표)
    @EntityGraph(attributePaths = {"subGoals"})
    @Query("SELECT g FROM Goal g WHERE g.dueDate < :now AND g.status = 'ACTIVE' AND g.isCompleted = false")
    List<Goal> findExpiredGoals(@Param("now") LocalDateTime now);

    // 만료 임박 목표 조회 (특정 시간 범위 내)
    @EntityGraph(attributePaths = {"subGoals"})
    @Query("SELECT g FROM Goal g WHERE g.dueDate > :now AND g.dueDate <= :threshold AND g.status = 'ACTIVE' AND g.isCompleted = false")
    List<Goal> findExpiringSoonGoals(@Param("now") LocalDateTime now, @Param("threshold") LocalDateTime threshold);

    // EXPIRED 상태이고 일정 시간 경과한 목표 조회 (자동 보관 대상)
    @EntityGraph(attributePaths = {"subGoals"})
    @Query("SELECT g FROM Goal g WHERE g.status = 'EXPIRED' AND g.updatedAt < :archiveThreshold")
    List<Goal> findExpiredGoalsForArchiving(@Param("archiveThreshold") LocalDateTime archiveThreshold);

    // 완료된 지 일정 시간 경과한 목표 조회 (자동 삭제 대상)
    @EntityGraph(attributePaths = {"subGoals"})
    @Query("SELECT g FROM Goal g WHERE g.status = 'COMPLETED' AND g.completedAt < :deleteThreshold")
    List<Goal> findOldCompletedGoals(@Param("deleteThreshold") LocalDateTime deleteThreshold);

    // ===== 성능 최적화: 상태 변경 전용 메서드 =====

    // 목표 완료 처리 - EntityGraph 없이 직접 업데이트 (빠른 성능)
    @Query("UPDATE Goal g SET g.isCompleted = true, g.completedAt = :completedAt, g.status = 'COMPLETED', g.updatedAt = :updatedAt WHERE g.id = :id")
    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.transaction.annotation.Transactional
    int updateGoalAsCompleted(@Param("id") Long id,
                              @Param("completedAt") LocalDateTime completedAt,
                              @Param("updatedAt") LocalDateTime updatedAt);

    // 목표 완료 취소 - EntityGraph 없이 직접 업데이트 (빠른 성능)
    @Query("UPDATE Goal g SET g.isCompleted = false, g.completedAt = null, g.status = 'ACTIVE', g.updatedAt = :updatedAt WHERE g.id = :id")
    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.transaction.annotation.Transactional
    int updateGoalAsIncomplete(@Param("id") Long id,
                                @Param("updatedAt") LocalDateTime updatedAt);

    // EntityGraph 없이 단순 조회 (완료/취소 후 업데이트된 데이터 반환용)
    @Query("SELECT g FROM Goal g WHERE g.id = :id")
    Optional<Goal> findByIdWithoutSubGoals(@Param("id") Long id);
}
