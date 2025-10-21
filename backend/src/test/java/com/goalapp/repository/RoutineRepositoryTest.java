package com.goalapp.repository;

import com.goalapp.entity.Routine;
import com.goalapp.entity.RoutineFrequency;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
class RoutineRepositoryTest {

    @Autowired
    private RoutineRepository routineRepository;

    private Routine dailyRoutine;
    private Routine weeklyRoutine;
    private Routine inactiveRoutine;

    @BeforeEach
    void setUp() {
        routineRepository.deleteAll();

        dailyRoutine = Routine.builder()
                .title("아침 조깅")
                .description("매일 30분 조깅")
                .frequency(RoutineFrequency.DAILY)
                .isActive(true)
                .build();

        weeklyRoutine = Routine.builder()
                .title("영어 공부")
                .description("주 3회 영어 공부")
                .frequency(RoutineFrequency.WEEKLY)
                .isActive(true)
                .build();

        inactiveRoutine = Routine.builder()
                .title("비활성 루틴")
                .frequency(RoutineFrequency.DAILY)
                .isActive(false)
                .build();

        routineRepository.saveAll(List.of(dailyRoutine, weeklyRoutine, inactiveRoutine));
    }

    @Test
    void findByIsActiveTrueOrderByCreatedAtDesc_활성루틴만조회() {
        // when
        List<Routine> activeRoutines = routineRepository.findByIsActiveTrueOrderByCreatedAtDesc();

        // then
        assertThat(activeRoutines).hasSize(2);
        assertThat(activeRoutines).extracting(Routine::isActive).containsOnly(true);
        assertThat(activeRoutines).extracting(Routine::getTitle)
                .contains("아침 조깅", "영어 공부");
    }

    @Test
    void findByFrequencyAndIsActiveTrueOrderByCreatedAtDesc_주기별조회() {
        // when
        List<Routine> dailyRoutines = routineRepository
                .findByFrequencyAndIsActiveTrueOrderByCreatedAtDesc(RoutineFrequency.DAILY);

        // then
        assertThat(dailyRoutines).hasSize(1);
        assertThat(dailyRoutines.get(0).getTitle()).isEqualTo("아침 조깅");
        assertThat(dailyRoutines.get(0).getFrequency()).isEqualTo(RoutineFrequency.DAILY);
    }

    @Test
    void findAllByOrderByCreatedAtDesc_전체조회() {
        // when
        List<Routine> allRoutines = routineRepository.findAllByOrderByCreatedAtDesc();

        // then
        assertThat(allRoutines).hasSize(3);
        assertThat(allRoutines).extracting(Routine::getTitle)
                .contains("아침 조깅", "영어 공부", "비활성 루틴");
    }

    @Test
    void save_루틴생성() {
        // given
        Routine newRoutine = Routine.builder()
                .title("독서")
                .description("매일 30분 독서")
                .frequency(RoutineFrequency.DAILY)
                .isActive(true)
                .build();

        // when
        Routine saved = routineRepository.save(newRoutine);

        // then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getTitle()).isEqualTo("독서");
        assertThat(saved.getCreatedAt()).isNotNull();
        assertThat(saved.getUpdatedAt()).isNotNull();
    }

    @Test
    void update_루틴수정() {
        // given
        Routine routine = routineRepository.findAll().get(0);
        String originalTitle = routine.getTitle();

        // when
        routine.setTitle("수정된 제목");
        Routine updated = routineRepository.save(routine);

        // then
        assertThat(updated.getId()).isEqualTo(routine.getId());
        assertThat(updated.getTitle()).isEqualTo("수정된 제목");
        assertThat(updated.getTitle()).isNotEqualTo(originalTitle);
    }

    @Test
    void delete_루틴삭제() {
        // given
        Long routineId = dailyRoutine.getId();

        // when
        routineRepository.deleteById(routineId);

        // then
        assertThat(routineRepository.findById(routineId)).isEmpty();
        assertThat(routineRepository.findAll()).hasSize(2);
    }
}
