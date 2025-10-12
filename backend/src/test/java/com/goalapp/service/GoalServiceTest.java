package com.goalapp.service;

import com.goalapp.entity.Goal;
import com.goalapp.entity.GoalStatus;
import com.goalapp.entity.GoalType;
import com.goalapp.exception.GoalNotFoundException;
import com.goalapp.repository.GoalRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("목표 서비스 테스트")
class GoalServiceTest {

    @Mock
    private GoalRepository goalRepository;

    @InjectMocks
    private GoalService goalService;

    private Goal testGoal;
    private Goal parentGoal;
    private Goal childGoal;

    @BeforeEach
    void setUp() {
        // 테스트용 부모 목표
        parentGoal = Goal.builder()
                .id(1L)
                .title("평생 목표")
                .description("건강한 삶 살기")
                .type(GoalType.LIFETIME)
                .status(GoalStatus.ACTIVE)
                .priority(3)
                .reminderEnabled(false)
                .createdAt(LocalDateTime.now())
                .build();

        // 테스트용 자식 목표
        childGoal = Goal.builder()
                .id(2L)
                .title("운동하기")
                .description("주 3회 이상 운동")
                .type(GoalType.WEEKLY)
                .status(GoalStatus.ACTIVE)
                .parentGoalId(1L)
                .priority(2)
                .reminderEnabled(true)
                .reminderFrequency("WEEKLY")
                .createdAt(LocalDateTime.now())
                .build();

        // 기본 테스트 목표
        testGoal = Goal.builder()
                .id(3L)
                .title("독서하기")
                .description("매일 30분 이상 독서")
                .type(GoalType.DAILY)
                .status(GoalStatus.ACTIVE)
                .priority(1)
                .reminderEnabled(true)
                .reminderFrequency("DAILY")
                .createdAt(LocalDateTime.now())
                .build();
    }

    @Test
    @DisplayName("모든 목표 조회 - 성공")
    void getAllGoals_Success() {
        // Given
        List<Goal> expectedGoals = Arrays.asList(parentGoal, childGoal, testGoal);
        when(goalRepository.findAll()).thenReturn(expectedGoals);

        // When
        List<Goal> actualGoals = goalService.getAllGoals();

        // Then
        assertNotNull(actualGoals);
        assertEquals(3, actualGoals.size());
        assertEquals(expectedGoals, actualGoals);
        verify(goalRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("ID로 목표 조회 - 성공")
    void getGoalById_Success() {
        // Given
        when(goalRepository.findById(1L)).thenReturn(Optional.of(parentGoal));

        // When
        Goal actualGoal = goalService.getGoalById(1L);

        // Then
        assertNotNull(actualGoal);
        assertEquals(parentGoal.getId(), actualGoal.getId());
        assertEquals(parentGoal.getTitle(), actualGoal.getTitle());
        verify(goalRepository, times(1)).findById(1L);
    }

    @Test
    @DisplayName("ID로 목표 조회 - 목표를 찾을 수 없음")
    void getGoalById_NotFound() {
        // Given
        when(goalRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(GoalNotFoundException.class, () -> {
            goalService.getGoalById(999L);
        });
        verify(goalRepository, times(1)).findById(999L);
    }

    @Test
    @DisplayName("목표 생성 - 성공")
    void createGoal_Success() {
        // Given
        Goal newGoal = Goal.builder()
                .title("새로운 목표")
                .description("테스트용 목표")
                .type(GoalType.MONTHLY)
                .status(GoalStatus.ACTIVE)
                .priority(2)
                .build();

        Goal savedGoal = Goal.builder()
                .id(4L)
                .title(newGoal.getTitle())
                .description(newGoal.getDescription())
                .type(newGoal.getType())
                .status(newGoal.getStatus())
                .priority(newGoal.getPriority())
                .createdAt(LocalDateTime.now())
                .build();

        when(goalRepository.save(any(Goal.class))).thenReturn(savedGoal);

        // When
        Goal actualGoal = goalService.createGoal(newGoal);

        // Then
        assertNotNull(actualGoal);
        assertEquals(4L, actualGoal.getId());
        assertEquals("새로운 목표", actualGoal.getTitle());
        assertNotNull(actualGoal.getCreatedAt());
        verify(goalRepository, times(1)).save(any(Goal.class));
    }

    @Test
    @DisplayName("목표 업데이트 - 성공")
    void updateGoal_Success() {
        // Given
        Goal updatedGoal = Goal.builder()
                .title("수정된 목표")
                .description("수정된 설명")
                .type(GoalType.WEEKLY)
                .priority(3)
                .build();

        when(goalRepository.findById(1L)).thenReturn(Optional.of(parentGoal));
        when(goalRepository.save(any(Goal.class))).thenReturn(parentGoal);

        // When
        Goal actualGoal = goalService.updateGoal(1L, updatedGoal);

        // Then
        assertNotNull(actualGoal);
        verify(goalRepository, times(1)).findById(1L);
        verify(goalRepository, times(1)).save(any(Goal.class));
    }

    @Test
    @DisplayName("목표 업데이트 - 목표를 찾을 수 없음")
    void updateGoal_NotFound() {
        // Given
        Goal updatedGoal = Goal.builder()
                .title("수정된 목표")
                .build();

        when(goalRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(GoalNotFoundException.class, () -> {
            goalService.updateGoal(999L, updatedGoal);
        });
        verify(goalRepository, times(1)).findById(999L);
        verify(goalRepository, never()).save(any(Goal.class));
    }

    @Test
    @DisplayName("목표 삭제 - 성공")
    void deleteGoal_Success() {
        // Given
        when(goalRepository.findById(1L)).thenReturn(Optional.of(parentGoal));
        doNothing().when(goalRepository).delete(parentGoal);

        // When
        assertDoesNotThrow(() -> goalService.deleteGoal(1L));

        // Then
        verify(goalRepository, times(1)).findById(1L);
        verify(goalRepository, times(1)).delete(parentGoal);
    }

    @Test
    @DisplayName("목표 삭제 - 목표를 찾을 수 없음")
    void deleteGoal_NotFound() {
        // Given
        when(goalRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(GoalNotFoundException.class, () -> {
            goalService.deleteGoal(999L);
        });
        verify(goalRepository, times(1)).findById(999L);
        verify(goalRepository, never()).delete(any(Goal.class));
    }

    @Test
    @DisplayName("목표 완료 처리 - 성공")
    void completeGoal_Success() {
        // Given
        when(goalRepository.findById(1L)).thenReturn(Optional.of(parentGoal));
        when(goalRepository.save(any(Goal.class))).thenReturn(parentGoal);

        // When
        Goal completedGoal = goalService.completeGoal(1L);

        // Then
        assertNotNull(completedGoal);
        assertEquals(GoalStatus.COMPLETED, completedGoal.getStatus());
        assertNotNull(completedGoal.getCompletedAt());
        verify(goalRepository, times(1)).findById(1L);
        verify(goalRepository, times(1)).save(any(Goal.class));
    }

    @Test
    @DisplayName("목표 완료 취소 - 성공")
    void uncompleteGoal_Success() {
        // Given
        Goal completedGoal = Goal.builder()
                .id(1L)
                .title("완료된 목표")
                .status(GoalStatus.COMPLETED)
                .completedAt(LocalDateTime.now())
                .build();

        when(goalRepository.findById(1L)).thenReturn(Optional.of(completedGoal));
        when(goalRepository.save(any(Goal.class))).thenReturn(completedGoal);

        // When
        Goal uncompletedGoal = goalService.uncompleteGoal(1L);

        // Then
        assertNotNull(uncompletedGoal);
        assertEquals(GoalStatus.ACTIVE, uncompletedGoal.getStatus());
        assertNull(uncompletedGoal.getCompletedAt());
        verify(goalRepository, times(1)).findById(1L);
        verify(goalRepository, times(1)).save(any(Goal.class));
    }

    @Test
    @DisplayName("타입별 목표 조회 - 성공")
    void getGoalsByType_Success() {
        // Given
        List<Goal> dailyGoals = Arrays.asList(testGoal);
        when(goalRepository.findByType(GoalType.DAILY)).thenReturn(dailyGoals);

        // When
        List<Goal> actualGoals = goalService.getGoalsByType(GoalType.DAILY);

        // Then
        assertNotNull(actualGoals);
        assertEquals(1, actualGoals.size());
        assertEquals(GoalType.DAILY, actualGoals.get(0).getType());
        verify(goalRepository, times(1)).findByType(GoalType.DAILY);
    }

    @Test
    @DisplayName("상태별 목표 조회 - 성공")
    void getGoalsByStatus_Success() {
        // Given
        List<Goal> activeGoals = Arrays.asList(parentGoal, childGoal, testGoal);
        when(goalRepository.findByStatus(GoalStatus.ACTIVE)).thenReturn(activeGoals);

        // When
        List<Goal> actualGoals = goalService.getGoalsByStatus(GoalStatus.ACTIVE);

        // Then
        assertNotNull(actualGoals);
        assertEquals(3, actualGoals.size());
        assertTrue(actualGoals.stream().allMatch(goal -> goal.getStatus() == GoalStatus.ACTIVE));
        verify(goalRepository, times(1)).findByStatus(GoalStatus.ACTIVE);
    }

    @Test
    @DisplayName("하위 목표 조회 - 성공")
    void getChildGoals_Success() {
        // Given
        List<Goal> childGoals = Arrays.asList(childGoal);
        when(goalRepository.findByParentGoalId(1L)).thenReturn(childGoals);

        // When
        List<Goal> actualGoals = goalService.getChildGoals(1L);

        // Then
        assertNotNull(actualGoals);
        assertEquals(1, actualGoals.size());
        assertEquals(1L, actualGoals.get(0).getParentGoalId());
        verify(goalRepository, times(1)).findByParentGoalId(1L);
    }

    @Test
    @DisplayName("최상위 목표 조회 - 성공")
    void getRootGoals_Success() {
        // Given
        List<Goal> rootGoals = Arrays.asList(parentGoal, testGoal);
        when(goalRepository.findByParentGoalIdIsNull()).thenReturn(rootGoals);

        // When
        List<Goal> actualGoals = goalService.getRootGoals();

        // Then
        assertNotNull(actualGoals);
        assertEquals(2, actualGoals.size());
        assertTrue(actualGoals.stream().allMatch(goal -> goal.getParentGoalId() == null));
        verify(goalRepository, times(1)).findByParentGoalIdIsNull();
    }

    @Test
    @DisplayName("오늘의 목표 조회 - 성공")
    void getTodayGoals_Success() {
        // Given
        List<Goal> todayGoals = Arrays.asList(testGoal);
        when(goalRepository.findTodayGoals(any(LocalDateTime.class), any(LocalDateTime.class)))
                .thenReturn(todayGoals);

        // When
        List<Goal> actualGoals = goalService.getTodayGoals();

        // Then
        assertNotNull(actualGoals);
        assertEquals(1, actualGoals.size());
        verify(goalRepository, times(1)).findTodayGoals(any(LocalDateTime.class), any(LocalDateTime.class));
    }

    @Test
    @DisplayName("진행률 계산 - 하위 목표가 있는 경우")
    void calculateProgress_WithSubGoals() {
        // Given
        Goal parentWithChildren = Goal.builder()
                .id(1L)
                .title("부모 목표")
                .type(GoalType.LIFETIME)
                .status(GoalStatus.ACTIVE)
                .build();

        Goal completedChild = Goal.builder()
                .id(2L)
                .parentGoalId(1L)
                .status(GoalStatus.COMPLETED)
                .build();

        Goal activeChild = Goal.builder()
                .id(3L)
                .parentGoalId(1L)
                .status(GoalStatus.ACTIVE)
                .build();

        List<Goal> children = Arrays.asList(completedChild, activeChild);
        when(goalRepository.findByParentGoalId(1L)).thenReturn(children);

        // When
        double progress = goalService.calculateProgressPercentage(parentWithChildren);

        // Then
        assertEquals(50.0, progress, 0.01);
        verify(goalRepository, times(1)).findByParentGoalId(1L);
    }

    @Test
    @DisplayName("진행률 계산 - 하위 목표가 없는 경우")
    void calculateProgress_WithoutSubGoals() {
        // Given
        Goal leafGoal = Goal.builder()
                .id(1L)
                .title("리프 목표")
                .status(GoalStatus.COMPLETED)
                .build();

        when(goalRepository.findByParentGoalId(1L)).thenReturn(Arrays.asList());

        // When
        double progress = goalService.calculateProgressPercentage(leafGoal);

        // Then
        assertEquals(100.0, progress, 0.01);
        verify(goalRepository, times(1)).findByParentGoalId(1L);
    }
}
