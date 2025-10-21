package com.goalapp.controller;

import com.goalapp.dto.request.CreateRoutineRequest;
import com.goalapp.dto.request.UpdateRoutineRequest;
import com.goalapp.dto.request.CompleteRoutineRequest;
import com.goalapp.dto.response.RoutineResponse;
import com.goalapp.dto.response.RoutineCompletionResponse;
import com.goalapp.entity.Routine;
import com.goalapp.entity.RoutineCompletion;
import com.goalapp.entity.RoutineFrequency;
import com.goalapp.service.RoutineService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/routines")
@RequiredArgsConstructor
@Slf4j
public class RoutineController {

    private final RoutineService routineService;

    /**
     * 전체 루틴 조회
     */
    @GetMapping
    public ResponseEntity<List<RoutineResponse>> getAllRoutines() {
        List<Routine> routines = routineService.getAllRoutines();
        List<RoutineResponse> responses = routines.stream()
                .map(RoutineResponse::from)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 활성화된 루틴만 조회
     */
    @GetMapping("/active")
    public ResponseEntity<List<RoutineResponse>> getActiveRoutines() {
        List<Routine> routines = routineService.getActiveRoutines();
        List<RoutineResponse> responses = routines.stream()
                .map(RoutineResponse::from)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 오늘의 루틴 조회
     */
    @GetMapping("/today")
    public ResponseEntity<List<RoutineResponse>> getTodayRoutines() {
        List<Routine> routines = routineService.getTodayRoutines();
        List<RoutineResponse> responses = routines.stream()
                .map(routine -> {
                    RoutineResponse response = RoutineResponse.from(routine);
                    response.setCompletedToday(routineService.isCompletedToday(routine.getId()));
                    return response;
                })
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 주기별 루틴 조회
     */
    @GetMapping("/frequency/{frequency}")
    public ResponseEntity<List<RoutineResponse>> getRoutinesByFrequency(
            @PathVariable RoutineFrequency frequency) {
        List<Routine> routines = routineService.getRoutinesByFrequency(frequency);
        List<RoutineResponse> responses = routines.stream()
                .map(RoutineResponse::from)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 루틴 상세 조회
     */
    @GetMapping("/{routineId}")
    public ResponseEntity<RoutineResponse> getRoutine(@PathVariable Long routineId) {
        Routine routine = routineService.getRoutineById(routineId);
        RoutineResponse response = RoutineResponse.from(routine);
        response.setCompletedToday(routineService.isCompletedToday(routineId));
        return ResponseEntity.ok(response);
    }

    /**
     * 루틴 완료 히스토리 조회
     */
    @GetMapping("/{routineId}/completions")
    public ResponseEntity<List<RoutineCompletionResponse>> getRoutineCompletions(
            @PathVariable Long routineId) {
        List<RoutineCompletion> completions = routineService.getRoutineCompletions(routineId);
        List<RoutineCompletionResponse> responses = completions.stream()
                .map(RoutineCompletionResponse::from)
                .toList();
        return ResponseEntity.ok(responses);
    }

    /**
     * 루틴 생성
     */
    @PostMapping
    public ResponseEntity<RoutineResponse> createRoutine(
            @Valid @RequestBody CreateRoutineRequest request) {
        log.info("루틴 생성: {}", request.getTitle());

        Routine routine = Routine.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .frequency(request.getFrequency())
                .isActive(true)
                .build();

        Routine savedRoutine = routineService.createRoutine(routine);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(RoutineResponse.from(savedRoutine));
    }

    /**
     * 루틴 수정
     */
    @PutMapping("/{routineId}")
    public ResponseEntity<RoutineResponse> updateRoutine(
            @PathVariable Long routineId,
            @Valid @RequestBody UpdateRoutineRequest request) {
        log.info("루틴 수정: {}", routineId);

        Routine updateData = Routine.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .frequency(request.getFrequency())
                .build();

        Routine updatedRoutine = routineService.updateRoutine(routineId, updateData);
        return ResponseEntity.ok(RoutineResponse.from(updatedRoutine));
    }

    /**
     * 루틴 삭제
     */
    @DeleteMapping("/{routineId}")
    public ResponseEntity<Void> deleteRoutine(@PathVariable Long routineId) {
        log.info("루틴 삭제: {}", routineId);
        routineService.deleteRoutine(routineId);
        return ResponseEntity.noContent().build();
    }

    /**
     * 루틴 활성화/비활성화
     */
    @PatchMapping("/{routineId}/toggle-active")
    public ResponseEntity<RoutineResponse> toggleRoutineActive(@PathVariable Long routineId) {
        log.info("루틴 활성화 토글: {}", routineId);
        Routine routine = routineService.toggleRoutineActive(routineId);
        return ResponseEntity.ok(RoutineResponse.from(routine));
    }

    /**
     * 루틴 완료 체크
     */
    @PostMapping("/{routineId}/complete")
    public ResponseEntity<RoutineCompletionResponse> completeRoutine(
            @PathVariable Long routineId,
            @RequestBody(required = false) CompleteRoutineRequest request) {
        log.info("루틴 완료: {}", routineId);

        String note = (request != null) ? request.getNote() : null;
        RoutineCompletion completion = routineService.completeRoutine(routineId, note);

        return ResponseEntity.ok(RoutineCompletionResponse.from(completion));
    }

    /**
     * 루틴 완료 취소
     */
    @DeleteMapping("/{routineId}/complete")
    public ResponseEntity<Void> uncompleteRoutine(@PathVariable Long routineId) {
        log.info("루틴 완료 취소: {}", routineId);
        routineService.uncompleteRoutine(routineId);
        return ResponseEntity.noContent().build();
    }
}
