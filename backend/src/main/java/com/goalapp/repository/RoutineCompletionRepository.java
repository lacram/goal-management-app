package com.goalapp.repository;

import com.goalapp.entity.RoutineCompletion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface RoutineCompletionRepository extends JpaRepository<RoutineCompletion, Long> {

    /**
     * 특정 루틴의 완료 기록 조회
     */
    List<RoutineCompletion> findByRoutineIdOrderByCompletedAtDesc(Long routineId);

    /**
     * 특정 기간의 완료 기록 조회
     */
    @Query("SELECT rc FROM RoutineCompletion rc WHERE rc.routine.id = :routineId " +
           "AND rc.completedAt BETWEEN :startDate AND :endDate " +
           "ORDER BY rc.completedAt DESC")
    List<RoutineCompletion> findByRoutineIdAndDateRange(
            @Param("routineId") Long routineId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    /**
     * 오늘 완료한 루틴인지 확인 (오늘 자정 이후 완료된 기록 조회)
     */
    @Query("SELECT rc FROM RoutineCompletion rc WHERE rc.routine.id = :routineId " +
           "AND rc.completedAt >= :startOfDay " +
           "ORDER BY rc.completedAt DESC")
    Optional<RoutineCompletion> findTodayCompletion(
            @Param("routineId") Long routineId,
            @Param("startOfDay") LocalDateTime startOfDay
    );
}
