package com.goalapp.service;

import com.goalapp.entity.Routine;
import com.goalapp.entity.RoutineCompletion;
import com.goalapp.entity.RoutineFrequency;
import com.goalapp.repository.RoutineCompletionRepository;
import com.goalapp.repository.RoutineRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class RoutineService {

    private final RoutineRepository routineRepository;
    private final RoutineCompletionRepository completionRepository;

    /**
     * 전체 루틴 조회
     */
    public List<Routine> getAllRoutines() {
        return routineRepository.findAllByOrderByCreatedAtDesc();
    }

    /**
     * 활성화된 루틴만 조회
     */
    public List<Routine> getActiveRoutines() {
        return routineRepository.findByIsActiveTrueOrderByCreatedAtDesc();
    }

    /**
     * 루틴 상세 조회
     */
    public Routine getRoutineById(Long id) {
        return routineRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("루틴을 찾을 수 없습니다: " + id));
    }

    /**
     * 주기별 루틴 조회
     */
    public List<Routine> getRoutinesByFrequency(RoutineFrequency frequency) {
        return routineRepository.findByFrequencyAndIsActiveTrueOrderByCreatedAtDesc(frequency);
    }

    /**
     * 오늘의 루틴 조회 (매일 루틴 + 주간 루틴 + 월간 루틴)
     */
    public List<Routine> getTodayRoutines() {
        return getActiveRoutines();
    }

    /**
     * 루틴 생성
     */
    @Transactional
    public Routine createRoutine(Routine routine) {
        validateRoutine(routine);
        log.info("루틴 생성: {}", routine.getTitle());
        return routineRepository.save(routine);
    }

    /**
     * 루틴 유효성 검증
     */
    private void validateRoutine(Routine routine) {
        if (routine.getTitle() == null || routine.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("루틴 제목은 필수입니다");
        }
        if (routine.getFrequency() == null) {
            throw new IllegalArgumentException("반복 주기는 필수입니다");
        }
    }

    /**
     * 루틴 수정
     */
    @Transactional
    public Routine updateRoutine(Long id, Routine updateData) {
        Routine routine = getRoutineById(id);

        if (updateData.getTitle() != null) {
            routine.setTitle(updateData.getTitle());
        }
        if (updateData.getDescription() != null) {
            routine.setDescription(updateData.getDescription());
        }
        if (updateData.getFrequency() != null) {
            routine.setFrequency(updateData.getFrequency());
        }

        log.info("루틴 수정: {}", routine.getTitle());
        return routineRepository.save(routine);
    }

    /**
     * 루틴 삭제
     */
    @Transactional
    public void deleteRoutine(Long id) {
        Routine routine = getRoutineById(id);
        log.info("루틴 삭제: {}", routine.getTitle());
        routineRepository.delete(routine);
    }

    /**
     * 루틴 활성화/비활성화
     */
    @Transactional
    public Routine toggleRoutineActive(Long id) {
        Routine routine = getRoutineById(id);
        routine.setActive(!routine.isActive());
        log.info("루틴 활성화 토글: {} -> {}", routine.getTitle(), routine.isActive());
        return routineRepository.save(routine);
    }

    /**
     * 루틴 완료 체크
     */
    @Transactional
    public RoutineCompletion completeRoutine(Long routineId, String note) {
        Routine routine = getRoutineById(routineId);

        // 오늘 이미 완료했는지 확인
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        Optional<RoutineCompletion> todayCompletion = completionRepository.findTodayCompletion(routineId, startOfDay);
        if (todayCompletion.isPresent()) {
            log.warn("루틴 이미 오늘 완료됨: {}", routine.getTitle());
            return todayCompletion.get();
        }

        RoutineCompletion completion = RoutineCompletion.builder()
                .routine(routine)
                .note(note)
                .build();

        log.info("루틴 완료: {}", routine.getTitle());
        return completionRepository.save(completion);
    }

    /**
     * 루틴 완료 취소 (오늘 완료 기록 삭제)
     */
    @Transactional
    public void uncompleteRoutine(Long routineId) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        Optional<RoutineCompletion> todayCompletion = completionRepository.findTodayCompletion(routineId, startOfDay);

        if (todayCompletion.isPresent()) {
            log.info("루틴 완료 취소: routineId={}", routineId);
            completionRepository.delete(todayCompletion.get());
        } else {
            log.warn("오늘 완료 기록이 없습니다: routineId={}", routineId);
        }
    }

    /**
     * 루틴 완료 히스토리 조회
     */
    public List<RoutineCompletion> getRoutineCompletions(Long routineId) {
        return completionRepository.findByRoutineIdOrderByCompletedAtDesc(routineId);
    }

    /**
     * 특정 기간의 완료 히스토리 조회
     */
    public List<RoutineCompletion> getRoutineCompletionsByDateRange(
            Long routineId, LocalDate startDate, LocalDate endDate) {
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
        return completionRepository.findByRoutineIdAndDateRange(routineId, startDateTime, endDateTime);
    }

    /**
     * 오늘 완료 여부 확인
     */
    public boolean isCompletedToday(Long routineId) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        return completionRepository.findTodayCompletion(routineId, startOfDay).isPresent();
    }
}
