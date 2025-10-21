package com.goalapp.service;

import com.goalapp.entity.Goal;
import com.goalapp.repository.GoalRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 목표 만료 처리 스케줄러 서비스
 * - 매 시간 만료된 목표를 자동으로 감지하고 상태 변경
 * - EXPIRED 상태인 목표를 24시간 후 자동으로 보관(ARCHIVED)
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class GoalExpirationService {

    private final GoalRepository goalRepository;

    /**
     * 만료된 목표 자동 감지 및 상태 변경
     * 매 시간 정각에 실행 (00:00, 01:00, 02:00, ...)
     */
    @Scheduled(cron = "0 0 * * * *")
    @Transactional
    public void checkAndExpireGoals() {
        log.info("⏰ Starting scheduled task: checkAndExpireGoals");

        LocalDateTime now = LocalDateTime.now();
        List<Goal> expiredGoals = goalRepository.findExpiredGoals(now);

        if (expiredGoals.isEmpty()) {
            log.info("✅ No expired goals found");
            return;
        }

        // 만료된 목표들의 상태를 EXPIRED로 변경
        expiredGoals.forEach(goal -> {
            goal.markAsExpired();
            log.info("⚠️ Goal expired: '{}' (ID: {}, Due: {})",
                    goal.getTitle(), goal.getId(), goal.getDueDate());
        });

        goalRepository.saveAll(expiredGoals);
        log.info("✅ Expired {} goals successfully", expiredGoals.size());
    }

    /**
     * EXPIRED 상태인 목표를 자동으로 보관 처리
     * 매일 새벽 2시에 실행 (서버 부하가 적은 시간대)
     * EXPIRED 상태가 된 지 24시간이 지난 목표를 ARCHIVED로 전환
     */
    @Scheduled(cron = "0 0 2 * * *")
    @Transactional
    public void archiveExpiredGoals() {
        log.info("📦 Starting scheduled task: archiveExpiredGoals");

        // 24시간 전 시간 계산
        LocalDateTime archiveThreshold = LocalDateTime.now().minusHours(24);
        List<Goal> goalsToArchive = goalRepository.findExpiredGoalsForArchiving(archiveThreshold);

        if (goalsToArchive.isEmpty()) {
            log.info("✅ No goals to archive");
            return;
        }

        // 보관 처리
        goalsToArchive.forEach(goal -> {
            goal.archive();
            log.info("📦 Goal archived: '{}' (ID: {}, Expired at: {})",
                    goal.getTitle(), goal.getId(), goal.getUpdatedAt());
        });

        goalRepository.saveAll(goalsToArchive);
        log.info("✅ Archived {} expired goals successfully", goalsToArchive.size());
    }

    /**
     * 만료 임박 목표 조회
     * @param hoursBeforeExpiry 만료 몇 시간 전까지의 목표를 조회할지 (기본: 24시간)
     * @return 만료 임박 목표 리스트
     */
    public List<Goal> getExpiringSoonGoals(int hoursBeforeExpiry) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime threshold = now.plusHours(hoursBeforeExpiry);

        List<Goal> expiringSoon = goalRepository.findExpiringSoonGoals(now, threshold);
        log.debug("🔔 Found {} goals expiring within {} hours", expiringSoon.size(), hoursBeforeExpiry);

        return expiringSoon;
    }

    /**
     * 수동으로 만료된 목표 감지 및 처리 (테스트/관리자용)
     * @return 처리된 목표 수
     */
    @Transactional
    public int manualExpireCheck() {
        log.info("🔧 Manual expiration check triggered");

        LocalDateTime now = LocalDateTime.now();
        List<Goal> expiredGoals = goalRepository.findExpiredGoals(now);

        expiredGoals.forEach(Goal::markAsExpired);
        goalRepository.saveAll(expiredGoals);

        log.info("✅ Manually expired {} goals", expiredGoals.size());
        return expiredGoals.size();
    }

    /**
     * 수동으로 보관 처리 (테스트/관리자용)
     * @return 처리된 목표 수
     */
    @Transactional
    public int manualArchiveCheck() {
        log.info("🔧 Manual archive check triggered");

        LocalDateTime archiveThreshold = LocalDateTime.now().minusHours(24);
        List<Goal> goalsToArchive = goalRepository.findExpiredGoalsForArchiving(archiveThreshold);

        goalsToArchive.forEach(Goal::archive);
        goalRepository.saveAll(goalsToArchive);

        log.info("✅ Manually archived {} goals", goalsToArchive.size());
        return goalsToArchive.size();
    }
}
