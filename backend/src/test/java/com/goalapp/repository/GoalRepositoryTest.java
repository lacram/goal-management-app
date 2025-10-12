package com.goalapp.repository;

import com.goalapp.entity.Goal;
import com.goalapp.entity.GoalStatus;
import com.goalapp.entity.GoalType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@ActiveProfiles("test")
@DisplayName("목표 레포지토리 테스트")
class GoalRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private GoalRepository goalRepository;

    private Goal lifetimeGoal;
    private Goal completedGoal;

    @BeforeEach
    void setUp() {
        // 평생 목표
        lifetimeGoal = Goal.builder()
                .title("건강한 삶 살기")
                .description("평생에 걸친 건강 관리")
                .type(GoalType.LIFETIME)
                .status(GoalStatus.ACTIVE)
                .priority(3)
                .reminderEnabled(false)
                .createdAt(LocalDateTime.now())
                .build();

        // 완료된 목표
        completedGoal = Goal.builder()
                .title("완료된 목표")
                .description("이미 완료된 목표")
                .type(GoalType.DAILY)
                .status(GoalStatus.COMPLETED)
                .priority(1)
                .reminderEnabled(false)
                .completedAt(LocalDateTime.now().minusDays(1))
                .createdAt(LocalDateTime.now().minusDays(2))
                .build();

        // 데이터 저장
        entityManager.persistAndFlush(lifetimeGoal);
        entityManager.persistAndFlush(completedGoal);
    }

    @Test
    @DisplayName("모든 목표 조회")
    void findAll_ShouldReturnAllGoals() {
        // When
        List<Goal> goals = goalRepository.findAll();

        // Then
        assertThat(goals).hasSize(2);
        assertThat(goals).extracting(Goal::getTitle)
                .containsExactlyInAnyOrder("건강한 삶 살기", "완료된 목표");
    }

    @Test
    @DisplayName("ID로 목표 조회")
    void findById_ShouldReturnGoal() {
        // When
        Optional<Goal> found = goalRepository.findById(lifetimeGoal.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getTitle()).isEqualTo("건강한 삶 살기");
        assertThat(found.get().getType()).isEqualTo(GoalType.LIFETIME);
    }

    @Test
    @DisplayName("존재하지 않는 ID로 목표 조회")
    void findById_ShouldReturnEmpty_WhenGoalNotExists() {
        // When
        Optional<Goal> found = goalRepository.findById(999L);

        // Then
        assertThat(found).isEmpty();
    }

    @Test
    @DisplayName("타입별 목표 조회")
    void findByType_ShouldReturnGoalsByType() {
        // When
        List<Goal> dailyGoals = goalRepository.findByType(GoalType.DAILY);
        List<Goal> lifetimeGoals = goalRepository.findByType(GoalType.LIFETIME);

        // Then
        assertThat(dailyGoals).hasSize(1);
        assertThat(dailyGoals.get(0).getTitle()).isEqualTo("완료된 목표");

        assertThat(lifetimeGoals).hasSize(1);
        assertThat(lifetimeGoals.get(0).getTitle()).isEqualTo("건강한 삶 살기");
    }

    @Test
    @DisplayName("상태별 목표 조회")
    void findByStatus_ShouldReturnGoalsByStatus() {
        // When
        List<Goal> activeGoals = goalRepository.findByStatus(GoalStatus.ACTIVE);
        List<Goal> completedGoals = goalRepository.findByStatus(GoalStatus.COMPLETED);

        // Then
        assertThat(activeGoals).hasSize(1);
        assertThat(activeGoals.get(0).getTitle()).isEqualTo("건강한 삶 살기");

        assertThat(completedGoals).hasSize(1);
        assertThat(completedGoals.get(0).getTitle()).isEqualTo("완료된 목표");
    }

    @Test
    @DisplayName("목표 저장 테스트")
    void save_ShouldPersistGoal() {
        // Given
        Goal newGoal = Goal.builder()
                .title("새로운 목표")
                .description("테스트용 새 목표")
                .type(GoalType.MONTHLY)
                .status(GoalStatus.ACTIVE)
                .priority(2)
                .reminderEnabled(true)
                .reminderFrequency("WEEKLY")
                .createdAt(LocalDateTime.now())
                .build();

        // When
        Goal savedGoal = goalRepository.save(newGoal);

        // Then
        assertThat(savedGoal.getId()).isNotNull();
        assertThat(savedGoal.getTitle()).isEqualTo("새로운 목표");
        assertThat(savedGoal.getCreatedAt()).isNotNull();

        // 데이터베이스에서 다시 조회해서 확인
        Optional<Goal> foundGoal = goalRepository.findById(savedGoal.getId());
        assertThat(foundGoal).isPresent();
        assertThat(foundGoal.get().getTitle()).isEqualTo("새로운 목표");
    }

    @Test
    @DisplayName("목표 삭제 테스트")
    void delete_ShouldRemoveGoal() {
        // Given
        Long goalId = completedGoal.getId();
        assertThat(goalRepository.findById(goalId)).isPresent();

        // When
        goalRepository.delete(completedGoal);
        entityManager.flush();

        // Then
        assertThat(goalRepository.findById(goalId)).isEmpty();
    }
}
