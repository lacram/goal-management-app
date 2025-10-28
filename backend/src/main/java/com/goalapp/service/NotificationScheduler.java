package com.goalapp.service;

import com.goalapp.entity.DeviceToken;
import com.goalapp.entity.Goal;
import com.goalapp.repository.DeviceTokenRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 알림 스케줄러
 * 정기적으로 만료 임박 목표를 확인하고 푸시 알림을 전송합니다.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationScheduler {

    private final GoalExpirationService expirationService;
    private final FcmService fcmService;
    private final DeviceTokenRepository deviceTokenRepository;

    /**
     * 만료 임박 알림 (매일 오전 9시)
     * 24시간 이내 만료되는 목표에 대해 알림 전송
     */
    @Scheduled(cron = "0 0 9 * * *")
    public void sendDailyExpirationWarnings() {
        log.info("🔔 Starting daily expiration warnings (24 hours)");

        List<Goal> expiringSoon = expirationService.getExpiringSoonGoals(24);

        if (expiringSoon.isEmpty()) {
            log.info("✅ No goals expiring within 24 hours");
            return;
        }

        // 활성화된 모든 디바이스 토큰 가져오기
        List<DeviceToken> activeTokens = deviceTokenRepository.findByIsActiveTrue();

        if (activeTokens.isEmpty()) {
            log.warn("⚠️ No active device tokens found");
            return;
        }

        int sentCount = 0;
        for (Goal goal : expiringSoon) {
            // 알림이 활성화된 목표만 처리
            if (!goal.isReminderEnabled()) {
                continue;
            }

            log.info("🔔 Sending notification for goal: '{}' (Due: {})", goal.getTitle(), goal.getDueDate());

            // 모든 활성화된 디바이스에 알림 전송
            for (DeviceToken token : activeTokens) {
                boolean success = fcmService.sendGoalExpiringNotification(
                        token.getFcmToken(),
                        goal.getTitle(),
                        24
                );

                if (success) {
                    token.markAsUsed();
                    deviceTokenRepository.save(token);
                    sentCount++;
                }
            }
        }

        log.info("✅ Daily expiration warnings completed: {} notifications sent for {} goals",
                 sentCount, expiringSoon.size());
    }

    /**
     * 만료 임박 알림 (매 3시간마다)
     * 3시간 이내 만료되는 목표에 대해 알림 전송
     */
    @Scheduled(cron = "0 0 */3 * * *")
    public void sendUrgentExpirationWarnings() {
        log.info("🔔 Starting urgent expiration warnings (3 hours)");

        List<Goal> expiringSoon = expirationService.getExpiringSoonGoals(3);

        if (expiringSoon.isEmpty()) {
            log.info("✅ No goals expiring within 3 hours");
            return;
        }

        List<DeviceToken> activeTokens = deviceTokenRepository.findByIsActiveTrue();

        if (activeTokens.isEmpty()) {
            log.warn("⚠️ No active device tokens found");
            return;
        }

        int sentCount = 0;
        for (Goal goal : expiringSoon) {
            if (!goal.isReminderEnabled()) {
                continue;
            }

            log.info("⚠️ URGENT: Goal '{}' expires in less than 3 hours (Due: {})",
                    goal.getTitle(), goal.getDueDate());

            for (DeviceToken token : activeTokens) {
                boolean success = fcmService.sendGoalExpiringNotification(
                        token.getFcmToken(),
                        goal.getTitle(),
                        3
                );

                if (success) {
                    token.markAsUsed();
                    deviceTokenRepository.save(token);
                    sentCount++;
                }
            }
        }

        log.info("✅ Urgent expiration warnings completed: {} notifications sent for {} goals",
                 sentCount, expiringSoon.size());
    }

    /**
     * 만료된 목표 알림 (매 시간 30분)
     * 최근 1시간 내 만료된 목표에 대해 알림 전송
     */
    @Scheduled(cron = "0 30 * * * *")
    public void sendExpiredGoalNotifications() {
        log.info("🔔 Checking for recently expired goals");

        // 이 로직은 GoalExpirationService에서 만료 처리될 때 트리거할 수 있습니다
        // 또는 최근 1시간 내 만료된 목표를 별도로 조회하여 알림 전송

        log.info("✅ Expired goal notifications check completed");
    }

    /**
     * 테스트용: 수동으로 알림 전송
     *
     * @param fcmToken  FCM 토큰
     * @param goalTitle 목표 제목
     * @param hours     남은 시간
     * @return 전송 성공 여부
     */
    public boolean sendTestNotification(String fcmToken, String goalTitle, int hours) {
        log.info("🧪 Sending test notification");
        return fcmService.sendGoalExpiringNotification(fcmToken, goalTitle, hours);
    }
}
