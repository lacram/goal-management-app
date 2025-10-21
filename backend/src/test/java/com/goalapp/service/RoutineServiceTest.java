package com.goalapp.service;

import com.goalapp.entity.Routine;
import com.goalapp.entity.RoutineCompletion;
import com.goalapp.entity.RoutineFrequency;
import com.goalapp.repository.RoutineCompletionRepository;
import com.goalapp.repository.RoutineRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class RoutineServiceTest {

    @Mock
    private RoutineRepository routineRepository;

    @Mock
    private RoutineCompletionRepository completionRepository;

    @InjectMocks
    private RoutineService routineService;

    private Routine testRoutine;

    @BeforeEach
    void setUp() {
        testRoutine = Routine.builder()
                .id(1L)
                .title("아침 조깅")
                .description("매일 30분 조깅")
                .frequency(RoutineFrequency.DAILY)
                .isActive(true)
                .build();
    }

    @Test
    void getAllRoutines_성공() {
        // given
        List<Routine> routines = Arrays.asList(testRoutine);
        when(routineRepository.findAllByOrderByCreatedAtDesc()).thenReturn(routines);

        // when
        List<Routine> result = routineService.getAllRoutines();

        // then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getTitle()).isEqualTo("아침 조깅");
        verify(routineRepository).findAllByOrderByCreatedAtDesc();
    }

    @Test
    void getActiveRoutines_성공() {
        // given
        List<Routine> activeRoutines = Arrays.asList(testRoutine);
        when(routineRepository.findByIsActiveTrueOrderByCreatedAtDesc()).thenReturn(activeRoutines);

        // when
        List<Routine> result = routineService.getActiveRoutines();

        // then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).isActive()).isTrue();
        verify(routineRepository).findByIsActiveTrueOrderByCreatedAtDesc();
    }

    @Test
    void getRoutineById_성공() {
        // given
        when(routineRepository.findById(1L)).thenReturn(Optional.of(testRoutine));

        // when
        Routine result = routineService.getRoutineById(1L);

        // then
        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(1L);
        assertThat(result.getTitle()).isEqualTo("아침 조깅");
    }

    @Test
    void getRoutineById_존재하지않는ID() {
        // given
        when(routineRepository.findById(999L)).thenReturn(Optional.empty());

        // when & then
        assertThatThrownBy(() -> routineService.getRoutineById(999L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("루틴을 찾을 수 없습니다");
    }

    @Test
    void createRoutine_성공() {
        // given
        Routine newRoutine = Routine.builder()
                .title("영어 공부")
                .frequency(RoutineFrequency.DAILY)
                .build();

        when(routineRepository.save(any(Routine.class))).thenReturn(newRoutine);

        // when
        Routine result = routineService.createRoutine(newRoutine);

        // then
        assertThat(result).isNotNull();
        assertThat(result.getTitle()).isEqualTo("영어 공부");
        verify(routineRepository).save(newRoutine);
    }

    @Test
    void updateRoutine_성공() {
        // given
        when(routineRepository.findById(1L)).thenReturn(Optional.of(testRoutine));
        when(routineRepository.save(any(Routine.class))).thenReturn(testRoutine);

        Routine updateData = Routine.builder()
                .title("저녁 조깅")
                .description("저녁 30분 조깅")
                .frequency(RoutineFrequency.WEEKLY)
                .build();

        // when
        Routine result = routineService.updateRoutine(1L, updateData);

        // then
        assertThat(result.getTitle()).isEqualTo("저녁 조깅");
        assertThat(result.getDescription()).isEqualTo("저녁 30분 조깅");
        assertThat(result.getFrequency()).isEqualTo(RoutineFrequency.WEEKLY);
        verify(routineRepository).save(testRoutine);
    }

    @Test
    void deleteRoutine_성공() {
        // given
        when(routineRepository.findById(1L)).thenReturn(Optional.of(testRoutine));
        doNothing().when(routineRepository).delete(testRoutine);

        // when
        routineService.deleteRoutine(1L);

        // then
        verify(routineRepository).delete(testRoutine);
    }

    @Test
    void toggleRoutineActive_성공() {
        // given
        when(routineRepository.findById(1L)).thenReturn(Optional.of(testRoutine));
        when(routineRepository.save(any(Routine.class))).thenReturn(testRoutine);

        // when
        Routine result = routineService.toggleRoutineActive(1L);

        // then
        assertThat(result.isActive()).isFalse(); // true에서 false로 토글됨
        verify(routineRepository).save(testRoutine);
    }

    @Test
    void completeRoutine_성공() {
        // given
        when(routineRepository.findById(1L)).thenReturn(Optional.of(testRoutine));
        when(completionRepository.findTodayCompletion(1L)).thenReturn(Optional.empty());

        RoutineCompletion completion = RoutineCompletion.builder()
                .id(1L)
                .routine(testRoutine)
                .note("완료!")
                .build();

        when(completionRepository.save(any(RoutineCompletion.class))).thenReturn(completion);

        // when
        RoutineCompletion result = routineService.completeRoutine(1L, "완료!");

        // then
        assertThat(result).isNotNull();
        assertThat(result.getNote()).isEqualTo("완료!");
        verify(completionRepository).save(any(RoutineCompletion.class));
    }

    @Test
    void completeRoutine_이미완료된경우() {
        // given
        when(routineRepository.findById(1L)).thenReturn(Optional.of(testRoutine));

        RoutineCompletion existingCompletion = RoutineCompletion.builder()
                .id(1L)
                .routine(testRoutine)
                .build();

        when(completionRepository.findTodayCompletion(1L)).thenReturn(Optional.of(existingCompletion));

        // when
        RoutineCompletion result = routineService.completeRoutine(1L, "완료!");

        // then
        assertThat(result).isEqualTo(existingCompletion);
        verify(completionRepository, never()).save(any());
    }

    @Test
    void uncompleteRoutine_성공() {
        // given
        RoutineCompletion completion = RoutineCompletion.builder()
                .id(1L)
                .routine(testRoutine)
                .build();

        when(completionRepository.findTodayCompletion(1L)).thenReturn(Optional.of(completion));
        doNothing().when(completionRepository).delete(completion);

        // when
        routineService.uncompleteRoutine(1L);

        // then
        verify(completionRepository).delete(completion);
    }

    @Test
    void isCompletedToday_완료됨() {
        // given
        RoutineCompletion completion = RoutineCompletion.builder()
                .id(1L)
                .routine(testRoutine)
                .build();

        when(completionRepository.findTodayCompletion(1L)).thenReturn(Optional.of(completion));

        // when
        boolean result = routineService.isCompletedToday(1L);

        // then
        assertThat(result).isTrue();
    }

    @Test
    void isCompletedToday_미완료() {
        // given
        when(completionRepository.findTodayCompletion(1L)).thenReturn(Optional.empty());

        // when
        boolean result = routineService.isCompletedToday(1L);

        // then
        assertThat(result).isFalse();
    }

    @Test
    void getRoutinesByFrequency_성공() {
        // given
        List<Routine> dailyRoutines = Arrays.asList(testRoutine);
        when(routineRepository.findByFrequencyAndIsActiveTrueOrderByCreatedAtDesc(RoutineFrequency.DAILY))
                .thenReturn(dailyRoutines);

        // when
        List<Routine> result = routineService.getRoutinesByFrequency(RoutineFrequency.DAILY);

        // then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getFrequency()).isEqualTo(RoutineFrequency.DAILY);
    }

    @Test
    void getRoutineCompletions_성공() {
        // given
        RoutineCompletion completion1 = RoutineCompletion.builder().id(1L).routine(testRoutine).build();
        RoutineCompletion completion2 = RoutineCompletion.builder().id(2L).routine(testRoutine).build();
        List<RoutineCompletion> completions = Arrays.asList(completion1, completion2);

        when(completionRepository.findByRoutineIdOrderByCompletedAtDesc(1L)).thenReturn(completions);

        // when
        List<RoutineCompletion> result = routineService.getRoutineCompletions(1L);

        // then
        assertThat(result).hasSize(2);
        verify(completionRepository).findByRoutineIdOrderByCompletedAtDesc(1L);
    }
}
