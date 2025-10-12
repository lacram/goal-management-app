package com.goalapp.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.goalapp.dto.request.CreateGoalRequest;
import com.goalapp.dto.request.UpdateGoalRequest;
import com.goalapp.entity.Goal;
import com.goalapp.entity.GoalStatus;
import com.goalapp.entity.GoalType;
import com.goalapp.repository.GoalRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureWebMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.WebApplicationContext;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureWebMvc
@ActiveProfiles("test")
@Transactional
@DisplayName("목표 관리 API 통합 테스트")
class GoalManagementIntegrationTest {

    @Autowired
    private WebApplicationContext webApplicationContext;

    @Autowired
    private GoalRepository goalRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
        goalRepository.deleteAll();
    }

    @Test
    @DisplayName("목표 생성부터 완료까지 전체 워크플로우 테스트")
    void goalCompleteWorkflow_ShouldWorkCorrectly() throws Exception {
        // 1. 목표 생성
        CreateGoalRequest createRequest = CreateGoalRequest.builder()
                .title("운동하기")
                .description("매일 30분 이상 운동")
                .type(GoalType.DAILY)
                .priority(1)
                .reminderEnabled(true)
                .reminderFrequency("DAILY")
                .build();

        String createResponse = mockMvc.perform(post("/api/goals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title").value("운동하기"))
                .andExpect(jsonPath("$.status").value("ACTIVE"))
                .andReturn()
                .getResponse()
                .getContentAsString();

        Goal createdGoal = objectMapper.readValue(createResponse, Goal.class);
        Long goalId = createdGoal.getId();

        // 2. 목표 조회 확인
        mockMvc.perform(get("/api/goals/" + goalId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(goalId))
                .andExpect(jsonPath("$.title").value("운동하기"))
                .andExpect(jsonPath("$.status").value("ACTIVE"));

        // 3. 목표 수정
        UpdateGoalRequest updateRequest = UpdateGoalRequest.builder()
                .title("매일 운동하기")
                .description("매일 최소 45분 이상 운동")
                .priority(2)
                .build();

        mockMvc.perform(put("/api/goals/" + goalId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("매일 운동하기"))
                .andExpect(jsonPath("$.description").value("매일 최소 45분 이상 운동"))
                .andExpect(jsonPath("$.priority").value(2));

        // 4. 목표 완료 처리
        mockMvc.perform(patch("/api/goals/" + goalId + "/complete"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("COMPLETED"))
                .andExpect(jsonPath("$.completedAt").exists());

        // 5. 완료된 목표 확인
        mockMvc.perform(get("/api/goals/" + goalId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("COMPLETED"));

        // 6. 데이터베이스에서도 확인
        Goal savedGoal = goalRepository.findById(goalId).orElseThrow();
        assertThat(savedGoal.getStatus()).isEqualTo(GoalStatus.COMPLETED);
        assertThat(savedGoal.getCompletedAt()).isNotNull();
    }

    @Test
    @DisplayName("계층적 목표 구조 테스트")
    void hierarchicalGoals_ShouldWorkCorrectly() throws Exception {
        // 1. 부모 목표 생성 (평생 목표)
        CreateGoalRequest parentRequest = CreateGoalRequest.builder()
                .title("건강한 삶")
                .description("평생에 걸친 건강 관리")
                .type(GoalType.LIFETIME)
                .priority(3)
                .reminderEnabled(false)
                .build();

        String parentResponse = mockMvc.perform(post("/api/goals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(parentRequest)))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Goal parentGoal = objectMapper.readValue(parentResponse, Goal.class);
        Long parentId = parentGoal.getId();

        // 2. 자식 목표 생성 (연간 목표)
        CreateGoalRequest childRequest = CreateGoalRequest.builder()
                .title("올해 운동 목표")
                .description("연간 운동 계획 실행")
                .type(GoalType.YEARLY)
                .parentGoalId(parentId)
                .priority(2)
                .reminderEnabled(true)
                .reminderFrequency("MONTHLY")
                .build();

        String childResponse = mockMvc.perform(post("/api/goals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(childRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.parentGoalId").value(parentId))
                .andReturn()
                .getResponse()
                .getContentAsString();

        Goal childGoal = objectMapper.readValue(childResponse, Goal.class);
        Long childId = childGoal.getId();

        // 3. 하위 목표 조회
        mockMvc.perform(get("/api/goals/" + parentId + "/children"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].id").value(childId))
                .andExpect(jsonPath("$[0].parentGoalId").value(parentId));

        // 4. 최상위 목표 조회
        mockMvc.perform(get("/api/goals/root"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].id").value(parentId))
                .andExpect(jsonPath("$[0].parentGoalId").doesNotExist());
    }

    @Test
    @DisplayName("목표 필터링 테스트")
    void goalFiltering_ShouldWorkCorrectly() throws Exception {
        // 테스트 데이터 생성
        Goal dailyGoal1 = Goal.builder()
                .title("일간 목표 1")
                .type(GoalType.DAILY)
                .status(GoalStatus.ACTIVE)
                .priority(1)
                .reminderEnabled(true)
                .createdAt(LocalDateTime.now())
                .build();

        Goal dailyGoal2 = Goal.builder()
                .title("일간 목표 2")
                .type(GoalType.DAILY)
                .status(GoalStatus.COMPLETED)
                .priority(2)
                .reminderEnabled(false)
                .completedAt(LocalDateTime.now())
                .createdAt(LocalDateTime.now())
                .build();

        Goal weeklyGoal = Goal.builder()
                .title("주간 목표")
                .type(GoalType.WEEKLY)
                .status(GoalStatus.ACTIVE)
                .priority(1)
                .reminderEnabled(true)
                .createdAt(LocalDateTime.now())
                .build();

        goalRepository.save(dailyGoal1);
        goalRepository.save(dailyGoal2);
        goalRepository.save(weeklyGoal);

        // 1. 타입별 조회 - DAILY
        mockMvc.perform(get("/api/goals/type/DAILY"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(2));

        // 2. 타입별 조회 - WEEKLY
        mockMvc.perform(get("/api/goals/type/WEEKLY"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(1));

        // 3. 상태별 조회 - ACTIVE
        mockMvc.perform(get("/api/goals/status/ACTIVE"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(2));

        // 4. 상태별 조회 - COMPLETED
        mockMvc.perform(get("/api/goals/status/COMPLETED"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(1));
    }

    @Test
    @DisplayName("목표 삭제 테스트")
    void goalDeletion_ShouldWorkCorrectly() throws Exception {
        // 목표 생성
        Goal testGoal = Goal.builder()
                .title("삭제할 목표")
                .description("테스트용 목표")
                .type(GoalType.DAILY)
                .status(GoalStatus.ACTIVE)
                .priority(1)
                .reminderEnabled(false)
                .createdAt(LocalDateTime.now())
                .build();

        Goal savedGoal = goalRepository.save(testGoal);
        Long goalId = savedGoal.getId();

        // 목표 존재 확인
        mockMvc.perform(get("/api/goals/" + goalId))
                .andExpect(status().isOk());

        // 목표 삭제
        mockMvc.perform(delete("/api/goals/" + goalId))
                .andExpect(status().isNoContent());

        // 삭제 확인
        mockMvc.perform(get("/api/goals/" + goalId))
                .andExpect(status().isNotFound());

        // 데이터베이스에서도 확인
        assertThat(goalRepository.findById(goalId)).isEmpty();
    }

    @Test
    @DisplayName("유효성 검증 테스트")
    void validation_ShouldWorkCorrectly() throws Exception {
        // 1. 빈 제목으로 목표 생성 시도
        CreateGoalRequest invalidRequest = CreateGoalRequest.builder()
                .title("") // 빈 제목
                .description("설명")
                .type(GoalType.DAILY)
                .build();

        mockMvc.perform(post("/api/goals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest());

        // 2. null 제목으로 목표 생성 시도
        CreateGoalRequest nullTitleRequest = CreateGoalRequest.builder()
                .title(null)
                .description("설명")
                .type(GoalType.DAILY)
                .build();

        mockMvc.perform(post("/api/goals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(nullTitleRequest)))
                .andExpect(status().isBadRequest());

        // 3. 존재하지 않는 목표 조회
        mockMvc.perform(get("/api/goals/999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").exists());
    }

    @Test
    @DisplayName("목표 진행률 계산 테스트")
    void progressCalculation_ShouldWorkCorrectly() throws Exception {
        // 부모 목표 생성
        Goal parentGoal = Goal.builder()
                .title("부모 목표")
                .type(GoalType.MONTHLY)
                .status(GoalStatus.ACTIVE)
                .priority(2)
                .reminderEnabled(false)
                .createdAt(LocalDateTime.now())
                .build();

        Goal savedParent = goalRepository.save(parentGoal);

        // 자식 목표들 생성 (완료 1개, 미완료 1개)
        Goal completedChild = Goal.builder()
                .title("완료된 자식")
                .type(GoalType.WEEKLY)
                .status(GoalStatus.COMPLETED)
                .parentGoalId(savedParent.getId())
                .priority(1)
                .reminderEnabled(false)
                .completedAt(LocalDateTime.now())
                .createdAt(LocalDateTime.now())
                .build();

        Goal activeChild = Goal.builder()
                .title("미완료 자식")
                .type(GoalType.WEEKLY)
                .status(GoalStatus.ACTIVE)
                .parentGoalId(savedParent.getId())
                .priority(1)
                .reminderEnabled(false)
                .createdAt(LocalDateTime.now())
                .build();

        goalRepository.save(completedChild);
        goalRepository.save(activeChild);

        // 진행률 조회 (50% 예상)
        mockMvc.perform(get("/api/goals/" + savedParent.getId() + "/progress"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.goalId").value(savedParent.getId()))
                .andExpect(jsonPath("$.progressPercentage").value(50.0));
    }

    @Test
    @DisplayName("에러 처리 테스트")
    void errorHandling_ShouldWorkCorrectly() throws Exception {
        // 1. 존재하지 않는 목표 업데이트
        UpdateGoalRequest updateRequest = UpdateGoalRequest.builder()
                .title("수정된 제목")
                .build();

        mockMvc.perform(put("/api/goals/999")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").exists())
                .andExpect(jsonPath("$.timestamp").exists());

        // 2. 존재하지 않는 목표 완료 처리
        mockMvc.perform(patch("/api/goals/999/complete"))
                .andExpect(status().isNotFound());

        // 3. 존재하지 않는 목표 삭제
        mockMvc.perform(delete("/api/goals/999"))
                .andExpect(status().isNotFound());

        // 4. 잘못된 목표 타입으로 조회
        mockMvc.perform(get("/api/goals/type/INVALID"))
                .andExpect(status().isBadRequest());
    }
}
