package com.goalapp.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.goalapp.dto.request.CreateRoutineRequest;
import com.goalapp.dto.request.UpdateRoutineRequest;
import com.goalapp.entity.Routine;
import com.goalapp.entity.RoutineCompletion;
import com.goalapp.entity.RoutineFrequency;
import com.goalapp.service.RoutineService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(RoutineController.class)
class RoutineControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
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
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
    }

    @Test
    void getAllRoutines_성공() throws Exception {
        // given
        List<Routine> routines = Arrays.asList(testRoutine);
        when(routineService.getAllRoutines()).thenReturn(routines);

        // when & then
        mockMvc.perform(get("/api/routines"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].title").value("아침 조깅"))
                .andExpect(jsonPath("$[0].frequency").value("DAILY"));

        verify(routineService).getAllRoutines();
    }

    @Test
    void getActiveRoutines_성공() throws Exception {
        // given
        List<Routine> activeRoutines = Arrays.asList(testRoutine);
        when(routineService.getActiveRoutines()).thenReturn(activeRoutines);

        // when & then
        mockMvc.perform(get("/api/routines/active"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].isActive").value(true));

        verify(routineService).getActiveRoutines();
    }

    @Test
    void getTodayRoutines_성공() throws Exception {
        // given
        List<Routine> todayRoutines = Arrays.asList(testRoutine);
        when(routineService.getTodayRoutines()).thenReturn(todayRoutines);
        when(routineService.isCompletedToday(anyLong())).thenReturn(false);

        // when & then
        mockMvc.perform(get("/api/routines/today"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].completedToday").value(false));

        verify(routineService).getTodayRoutines();
    }

    @Test
    void getRoutine_성공() throws Exception {
        // given
        when(routineService.getRoutineById(1L)).thenReturn(testRoutine);
        when(routineService.isCompletedToday(1L)).thenReturn(true);

        // when & then
        mockMvc.perform(get("/api/routines/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.title").value("아침 조깅"))
                .andExpect(jsonPath("$.completedToday").value(true));

        verify(routineService).getRoutineById(1L);
        verify(routineService).isCompletedToday(1L);
    }

    @Test
    void createRoutine_성공() throws Exception {
        // given
        CreateRoutineRequest request = new CreateRoutineRequest(
                "영어 공부",
                "매일 1시간 영어 공부",
                RoutineFrequency.DAILY
        );

        Routine createdRoutine = Routine.builder()
                .id(2L)
                .title("영어 공부")
                .description("매일 1시간 영어 공부")
                .frequency(RoutineFrequency.DAILY)
                .isActive(true)
                .build();

        when(routineService.createRoutine(any(Routine.class))).thenReturn(createdRoutine);

        // when & then
        mockMvc.perform(post("/api/routines")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(2))
                .andExpect(jsonPath("$.title").value("영어 공부"));

        verify(routineService).createRoutine(any(Routine.class));
    }

    @Test
    void createRoutine_제목없음_실패() throws Exception {
        // given
        CreateRoutineRequest request = new CreateRoutineRequest(
                "",  // 빈 제목
                "설명",
                RoutineFrequency.DAILY
        );

        // when & then
        mockMvc.perform(post("/api/routines")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        verify(routineService, never()).createRoutine(any());
    }

    @Test
    void updateRoutine_성공() throws Exception {
        // given
        UpdateRoutineRequest request = new UpdateRoutineRequest(
                "저녁 조깅",
                "저녁 30분 조깅",
                RoutineFrequency.WEEKLY
        );

        Routine updatedRoutine = Routine.builder()
                .id(1L)
                .title("저녁 조깅")
                .description("저녁 30분 조깅")
                .frequency(RoutineFrequency.WEEKLY)
                .isActive(true)
                .build();

        when(routineService.updateRoutine(anyLong(), any(Routine.class))).thenReturn(updatedRoutine);

        // when & then
        mockMvc.perform(put("/api/routines/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("저녁 조깅"))
                .andExpect(jsonPath("$.frequency").value("WEEKLY"));

        verify(routineService).updateRoutine(anyLong(), any(Routine.class));
    }

    @Test
    void deleteRoutine_성공() throws Exception {
        // given
        doNothing().when(routineService).deleteRoutine(1L);

        // when & then
        mockMvc.perform(delete("/api/routines/1"))
                .andExpect(status().isNoContent());

        verify(routineService).deleteRoutine(1L);
    }

    @Test
    void toggleRoutineActive_성공() throws Exception {
        // given
        Routine toggledRoutine = Routine.builder()
                .id(1L)
                .title("아침 조깅")
                .frequency(RoutineFrequency.DAILY)
                .isActive(false)  // 토글됨
                .build();

        when(routineService.toggleRoutineActive(1L)).thenReturn(toggledRoutine);

        // when & then
        mockMvc.perform(patch("/api/routines/1/toggle-active"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.isActive").value(false));

        verify(routineService).toggleRoutineActive(1L);
    }

    @Test
    void completeRoutine_성공() throws Exception {
        // given
        RoutineCompletion completion = RoutineCompletion.builder()
                .id(1L)
                .routine(testRoutine)
                .note("완료!")
                .completedAt(LocalDateTime.now())
                .build();

        when(routineService.completeRoutine(eq(1L), anyString())).thenReturn(completion);

        // when & then
        mockMvc.perform(post("/api/routines/1/complete")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"note\": \"완료!\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.routineId").value(1));

        verify(routineService).completeRoutine(eq(1L), anyString());
    }

    @Test
    void uncompleteRoutine_성공() throws Exception {
        // given
        doNothing().when(routineService).uncompleteRoutine(1L);

        // when & then
        mockMvc.perform(delete("/api/routines/1/complete"))
                .andExpect(status().isNoContent());

        verify(routineService).uncompleteRoutine(1L);
    }

    @Test
    void getRoutineCompletions_성공() throws Exception {
        // given
        RoutineCompletion completion1 = RoutineCompletion.builder()
                .id(1L)
                .routine(testRoutine)
                .completedAt(LocalDateTime.now())
                .build();

        RoutineCompletion completion2 = RoutineCompletion.builder()
                .id(2L)
                .routine(testRoutine)
                .completedAt(LocalDateTime.now().minusDays(1))
                .build();

        List<RoutineCompletion> completions = Arrays.asList(completion1, completion2);
        when(routineService.getRoutineCompletions(1L)).thenReturn(completions);

        // when & then
        mockMvc.perform(get("/api/routines/1/completions"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].routineId").value(1));

        verify(routineService).getRoutineCompletions(1L);
    }

    @Test
    void getRoutinesByFrequency_성공() throws Exception {
        // given
        List<Routine> dailyRoutines = Arrays.asList(testRoutine);
        when(routineService.getRoutinesByFrequency(RoutineFrequency.DAILY)).thenReturn(dailyRoutines);

        // when & then
        mockMvc.perform(get("/api/routines/frequency/DAILY"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].frequency").value("DAILY"));

        verify(routineService).getRoutinesByFrequency(RoutineFrequency.DAILY);
    }
}
