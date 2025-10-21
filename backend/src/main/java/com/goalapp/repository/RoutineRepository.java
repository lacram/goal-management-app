package com.goalapp.repository;

import com.goalapp.entity.Routine;
import com.goalapp.entity.RoutineFrequency;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RoutineRepository extends JpaRepository<Routine, Long> {

    /**
     * 활성화된 루틴만 조회
     */
    List<Routine> findByIsActiveTrueOrderByCreatedAtDesc();

    /**
     * 주기별 루틴 조회
     */
    List<Routine> findByFrequencyAndIsActiveTrueOrderByCreatedAtDesc(RoutineFrequency frequency);

    /**
     * 전체 루틴 조회 (활성/비활성 모두)
     */
    List<Routine> findAllByOrderByCreatedAtDesc();
}
