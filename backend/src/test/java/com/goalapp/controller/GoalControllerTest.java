package com.goalapp.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.goalapp.dto.request.CreateGoalRequest;
import com.goalapp.dto.request.UpdateGoalRequest;
import com.goalapp.dto.response.GoalResponse;
import com.goalapp.entity.Goal;
import com.goalapp.entity.GoalStatus;
import com.goalapp.entity.GoalType;
import com.goalapp.exception.GoalNotFoundException;
import com.goalapp.service.GoalService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(GoalController.class)
@DisplayName("목표 컨트롤러 테스트")
class GoalControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private GoalService goalService;

    @Autowired
    private ObjectMapper objectMapper;

    private Goal testGoal;
    private CreateGoalRequest createRequest;
    private UpdateGoalRequest updateRequest;

    @BeforeEach
    void setUp() {
        testGoal = Goal.builder()
                .id(1L)
                .title("테스트 목표")
                .description("테스트용 목표입니다")
                .type(GoalType.DAILY)
                .status(GoalStatus.ACTIVE)
                .priority(1)
                .reminderEnabled(true)
                .reminderFrequency("DAILY")
                .createdAt(LocalDateTime.now())
                .build();

        createRequest = CreateGoalRequest.builder()
                .title("새로운 목표")
                .description("새로운 목표 설명")
                .type(GoalType.WEEKLY)
                .priority(2)
                .reminderEnabled(false)
                .build();

        updateRequest = UpdateGoalRequest.builder()
                .title("수정된 목표")
                .description("수정된 설명")
                .priority(3)
                .build();
    }

    @Test
    @DisplayName("모든 목표 조회 - 성공")
    void getAllGoals_Success() throws Exception {
        // Given
        List<Goal> goals = Arrays.asList(testGoal);
        given(goalService.getAllGoals()).willReturn(goals);

        // When & Then
        mockMvc.perform(get("/api/goals"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].id").value(1L))
                .andExpect(jsonPath("$[0].title").value("테스트 목표"))
                .andExpect(jsonPath("$[0].type").value("DAILY"))
                .andExpect(jsonPath("$[0].status").value("ACTIVE"));

        verify(goalService, times(1)).getAllGoals();
    }

    @Test
    @DisplayName("ID로 목표 조회 - 성공")
    void getGoalById_Success() throws Exception {
        // Given
        given(goalService.getGoalById(1L)).willReturn(testGoal);

        // When & Then
        mockMvc.perform(get("/api/goals/1"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.title").value("테스트 목표"))
                .andExpect(jsonPath("$.description").value("테스트용 목표입니다"))
                .andExpect(jsonPath("$.type").value("DAILY"))
                .andExpect(jsonPath("$.status").value("ACTIVE"))
                .andExpect(jsonPath("$.priority").value(1))
                .andExpect(jsonPath("$.reminderEnabled").value(true))
                .andExpect(jsonPath("$.reminderFrequency").value("DAILY"));

        verify(goalService, times(1)).getGoalById(1L);
    }

    @Test
    @DisplayName("ID로 목표 조회 - 목표를 찾을 수 없음")
    void getGoalById_NotFound() throws Exception {
        // Given
        given(goalService.getGoalById(999L)).willThrow(new GoalNotFoundException("Goal not found"));

        // When & Then
        mockMvc.perform(get("/api/goals/999"))
                .andExpect(status().isNotFound())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.message").value("Goal not found"));

        verify(goalService, times(1)).getGoalById(999L);
    }

    @Test
    @DisplayName("목표 생성 - 성공")
    void createGoal_Success() throws Exception {
        // Given
        Goal createdGoal = Goal.builder()
                .id(2L)
                .title(createRequest.getTitle())
                .description(createRequest.getDescription())
                .type(createRequest.getType())
                .status(GoalStatus.ACTIVE)
                .priority(createRequest.getPriority())
                .reminderEnabled(createRequest.isReminderEnabled())
                .createdAt(LocalDateTime.now())
                .build();

        given(goalService.createGoal(any(Goal.class))).willReturn(createdGoal);

        // When & Then
        mockMvc.perform(post("/api/goals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isCreated())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.id").value(2L))
                .andExpect(jsonPath("$.title").value("새로운 목표"))
                .andExpect(jsonPath("$.description").value("새로운 목표 설명"))
                .andExpect(jsonPath("$.type").value("WEEKLY"))
                .andExpect(jsonPath("$.status").value("ACTIVE"))
                .andExpect(jsonPath("$.priority").value(2))
                .andExpect(jsonPath("$.reminderEnabled").value(false));

        verify(goalService, times(1)).createGoal(any(Goal.class));
    }

    @Test
    @DisplayName("목표 생성 - 유효성 검증 실패 (제목 누락)")
    void createGoal_ValidationFailure() throws Exception {
        // Given
        CreateGoalRequest invalidRequest = CreateGoalRequest.builder()
                .description("설명만 있는 요청")
                .type(GoalType.DAILY)
                .build();

        // When & Then
        mockMvc.perform(post("/api/goals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest());

        verify(goalService, never()).createGoal(any(Goal.class));
    }

    @Test
    @DisplayName("목표 업데이트 - 성공")
    void updateGoal_Success() throws Exception {
        // Given
        Goal updatedGoal = Goal.builder()
                .id(1L)
                .title(updateRequest.getTitle())
                .description(updateRequest.getDescription())
                .type(testGoal.getType())
                .status(testGoal.getStatus())
                .priority(updateRequest.getPriority())
                .reminderEnabled(testGoal.isReminderEnabled())
                .reminderFrequency(testGoal.getReminderFrequency())
                .createdAt(testGoal.getCreatedAt())
                .updatedAt(LocalDateTime.now())
                .build();

        given(goalService.updateGoal(eq(1L), any(Goal.class))).willReturn(updatedGoal);

        // When & Then
        mockMvc.perform(put("/api/goals/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.title").value("수정된 목표"))
                .andExpect(jsonPath("$.description").value("수정된 설명"))
                .andExpect(jsonPath("$.priority").value(3));

        verify(goalService, times(1)).updateGoal(eq(1L), any(Goal.class));
    }

    @Test
    @DisplayName("목표 업데이트 - 목표를 찾을 수 없음")
    void updateGoal_NotFound() throws Exception {
        // Given
        given(goalService.updateGoal(eq(999L), any(Goal.class)))
                .willThrow(new GoalNotFoundException("Goal not found"));

        // When & Then
        mockMvc.perform(put("/api/goals/999")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isNotFound())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.message").value("Goal not found"));

        verify(goalService, times(1)).updateGoal(eq(999L), any(Goal.class));
    }

    @Test
    @DisplayName("목표 삭제 - 성공")
    void deleteGoal_Success() throws Exception {
        // Given
        doNothing().when(goalService).deleteGoal(1L);

        // When & Then
        mockMvc.perform(delete("/api/goals/1"))
                .andExpect(status().isNoContent());

        verify(goalService, times(1)).deleteGoal(1L);
    }

    @Test
    @DisplayName("목표 삭제 - 목표를 찾을 수 없음")
    void deleteGoal_NotFound() throws Exception {
        // Given
        doThrow(new GoalNotFoundException("Goal not found")).when(goalService).deleteGoal(999L);

        // When & Then
        mockMvc.perform(delete("/api/goals/999"))
                .andExpect(status().isNotFound())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.message").value("Goal not found"));

        verify(goalService, times(1)).deleteGoal(999L);
    }

    @Test
    @DisplayName("목표 완료 처리 - 성공")
    void completeGoal_Success() throws Exception {
        // Given
        Goal completedGoal = Goal.builder()
                .id(1L)
                .title(testGoal.getTitle())
                .description(testGoal.getDescription())
                .type(testGoal.getType())
                .status(GoalStatus.COMPLETED)
                .priority(testGoal.getPriority())
                .reminderEnabled(testGoal.isReminderEnabled())
                .reminderFrequency(testGoal.getReminderFrequency())
                .createdAt(testGoal.getCreatedAt())
                .completedAt(LocalDateTime.now())
                .build();

        given(goalService.completeGoal(1L)).willReturn(completedGoal);

        // When & Then
        mockMvc.perform(patch("/api/goals/1/complete"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.status").value("COMPLETED"))
                .andExpect(jsonPath("$.completedAt").exists());

        verify(goalService, times(1)).completeGoal(1L);
    }

    @Test
    @DisplayName("목표 완료 취소 - 성공")
    void uncompleteGoal_Success() throws Exception {
        // Given
        Goal uncompletedGoal = Goal.builder()
                .id(1L)
                .title(testGoal.getTitle())
                .description(testGoal.getDescription())
                .type(testGoal.getType())
                .status(GoalStatus.ACTIVE)
                .priority(testGoal.getPriority())
                .reminderEnabled(testGoal.isReminderEnabled())
                .reminderFrequency(testGoal.getReminderFrequency())
                .createdAt(testGoal.getCreatedAt())
                .completedAt(null)
                .build();

        given(goalService.uncompleteGoal(1L)).willReturn(uncompletedGoal);

        // When & Then
        mockMvc.perform(patch("/api/goals/1/uncomplete"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.status").value("ACTIVE"))
                .andExpect(jsonPath("$.completedAt").isEmpty());

        verify(goalService, times(1)).uncompleteGoal(1L);
    }

    @Test
    @DisplayName("타입별 목표 조회 - 성공")
    void getGoalsByType_Success() throws Exception {
        // Given
        List<Goal> dailyGoals = Arrays.asList(testGoal);
        given(goalService.getGoalsByType(GoalType.DAILY)).willReturn(dailyGoals);

        // When & Then
        mockMvc.perform(get("/api/goals/type/DAILY"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].type").value("DAILY"));

        verify(goalService, times(1)).getGoalsByType(GoalType.DAILY);
    }

    @Test
    @DisplayName("상태별 목표 조회 - 성공")
    void getGoalsByStatus_Success() throws Exception {
        // Given
        List<Goal> activeGoals = Arrays.asList(testGoal);
        given(goalService.getGoalsByStatus(GoalStatus.ACTIVE)).willReturn(activeGoals);

        // When & Then
        mockMvc.perform(get("/api/goals/status/ACTIVE"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].status").value("ACTIVE"));

        verify(goalService, times(1)).getGoalsByStatus(GoalStatus.ACTIVE);
    }

    @Test
    @DisplayName("하위 목표 조회 - 성공")
    void getChildGoals_Success() throws Exception {
        // Given
        Goal childGoal = Goal.builder()
                .id(2L)
                .title("하위 목표")
                .parentGoalId(1L)
                .type(GoalType.WEEKLY)
                .status(GoalStatus.ACTIVE)
                .build();

        List<Goal> childGoals = Arrays.asList(childGoal);
        given(goalService.getChildGoals(1L)).willReturn(childGoals);

        // When & Then
        mockMvc.perform(get("/api/goals/1/children"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].parentGoalId").value(1L));

        verify(goalService, times(1)).getChildGoals(1L);
    }

    @Test
    @DisplayName("최상위 목표 조회 - 성공")
    void getRootGoals_Success() throws Exception {
        // Given
        List<Goal> rootGoals = Arrays.asList(testGoal);
        given(goalService.getRootGoals()).willReturn(rootGoals);

        // When & Then
        mockMvc.perform(get("/api/goals/root"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$").isArray());

        verify(goalService, times(1)).getRootGoals();
    }

    @Test
    @DisplayName("오늘의 목표 조회 - 성공")
    void getTodayGoals_Success() throws Exception {
        // Given
        List<Goal> todayGoals = Arrays.asList(testGoal);
        given(goalService.getTodayGoals()).willReturn(todayGoals);

        // When & Then
        mockMvc.perform(get("/api/goals/today"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$").isArray());

        verify(goalService, times(1)).getTodayGoals();
    }

    @Test
    @DisplayName("진행률 조회 - 성공")
    void getGoalProgress_Success() throws Exception {
        // Given
        given(goalService.getGoalById(1L)).willReturn(testGoal);
        given(goalService.calculateProgressPercentage(testGoal)).willReturn(75.0);

        // When & Then
        mockMvc.perform(get("/api/goals/1/progress"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.goalId").value(1L))
                .andExpect(jsonPath("$.progressPercentage").value(75.0));

        verify(goalService, times(1)).getGoalById(1L);
        verify(goalService, times(1)).calculateProgressPercentage(testGoal);
    }

    @Test
    @DisplayName("잘못된 목표 타입으로 조회 - 400 에러")
    void getGoalsByType_InvalidType() throws Exception {
        // When & Then
        mockMvc.perform(get("/api/goals/type/INVALID_TYPE"))
                .andExpect(status().isBadRequest());

        verify(goalService, never()).getGoalsByType(any(GoalType.class));
    }

    @Test
    @DisplayName("잘못된 목표 상태로 조회 - 400 에러")
    void getGoalsByStatus_InvalidStatus() throws Exception {
        // When & Then
        mockMvc.perform(get("/api/goals/status/INVALID_STATUS"))
                .andExpect(status().isBadRequest());

        verify(goalService, never()).getGoalsByStatus(any(GoalStatus.class));
    }
}
