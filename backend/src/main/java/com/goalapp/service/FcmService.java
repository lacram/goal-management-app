package com.goalapp.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Firebase Cloud Messaging 서비스
 * 푸시 알림을 전송합니다.
 *
 * Firebase가 비활성화된 경우 (ENABLE_FIREBASE=false) 알림 전송을 스킵합니다.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class FcmService {

    /**
     * Firebase 초기화 여부 확인
     */
    private boolean isFirebaseInitialized() {
        return !FirebaseApp.getApps().isEmpty();
    }

    /**
     * 단일 기기에 푸시 알림 전송
     *
     * @param fcmToken 기기 FCM 토큰
     * @param title    알림 제목
     * @param body     알림 내용
     * @return 전송 성공 여부
     */
    public boolean sendNotification(String fcmToken, String title, String body) {
        if (!isFirebaseInitialized()) {
            log.debug("Firebase is not initialized, skipping notification");
            return false;
        }

        if (fcmToken == null || fcmToken.isEmpty()) {
            log.warn("⚠️ FCM token is null or empty, skipping notification");
            return false;
        }

        try {
            Message message = Message.builder()
                    .setToken(fcmToken)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            log.info("✅ FCM notification sent successfully: {}", response);
            return true;

        } catch (Exception e) {
            log.error("❌ Failed to send FCM notification to token: {}", fcmToken, e);
            return false;
        }
    }

    /**
     * 데이터 포함 푸시 알림 전송
     *
     * @param fcmToken 기기 FCM 토큰
     * @param title    알림 제목
     * @param body     알림 내용
     * @param data     추가 데이터 (키-값 쌍)
     * @return 전송 성공 여부
     */
    public boolean sendNotificationWithData(String fcmToken, String title, String body,
                                           java.util.Map<String, String> data) {
        if (!isFirebaseInitialized()) {
            log.debug("Firebase is not initialized, skipping notification");
            return false;
        }

        if (fcmToken == null || fcmToken.isEmpty()) {
            log.warn("⚠️ FCM token is null or empty, skipping notification");
            return false;
        }

        try {
            Message.Builder messageBuilder = Message.builder()
                    .setToken(fcmToken)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build());

            // 데이터 추가
            if (data != null && !data.isEmpty()) {
                messageBuilder.putAllData(data);
            }

            String response = FirebaseMessaging.getInstance().send(messageBuilder.build());
            log.info("✅ FCM notification with data sent successfully: {}", response);
            return true;

        } catch (Exception e) {
            log.error("❌ Failed to send FCM notification with data to token: {}", fcmToken, e);
            return false;
        }
    }

    /**
     * 목표 만료 임박 알림 전송
     *
     * @param fcmToken  기기 FCM 토큰
     * @param goalTitle 목표 제목
     * @param hoursLeft 남은 시간 (시간 단위)
     * @return 전송 성공 여부
     */
    public boolean sendGoalExpiringNotification(String fcmToken, String goalTitle, int hoursLeft) {
        String title = "⏰ 목표 만료 임박!";
        String body = String.format("\"%s\" 목표가 %d시간 후 만료됩니다", goalTitle, hoursLeft);

        java.util.Map<String, String> data = new java.util.HashMap<>();
        data.put("type", "GOAL_EXPIRING");
        data.put("goal_title", goalTitle);
        data.put("hours_left", String.valueOf(hoursLeft));

        return sendNotificationWithData(fcmToken, title, body, data);
    }

    /**
     * 목표 만료 알림 전송
     *
     * @param fcmToken  기기 FCM 토큰
     * @param goalTitle 목표 제목
     * @return 전송 성공 여부
     */
    public boolean sendGoalExpiredNotification(String fcmToken, String goalTitle) {
        String title = "⚠️ 목표가 만료되었습니다";
        String body = String.format("\"%s\" 목표가 만료되었습니다. 기간을 연장하시겠습니까?", goalTitle);

        java.util.Map<String, String> data = new java.util.HashMap<>();
        data.put("type", "GOAL_EXPIRED");
        data.put("goal_title", goalTitle);

        return sendNotificationWithData(fcmToken, title, body, data);
    }

    /**
     * 목표 자동 보관 알림 전송
     *
     * @param fcmToken  기기 FCM 토큰
     * @param goalTitle 목표 제목
     * @return 전송 성공 여부
     */
    public boolean sendGoalArchivedNotification(String fcmToken, String goalTitle) {
        String title = "📦 목표가 보관되었습니다";
        String body = String.format("\"%s\" 목표가 자동으로 보관되었습니다", goalTitle);

        java.util.Map<String, String> data = new java.util.HashMap<>();
        data.put("type", "GOAL_ARCHIVED");
        data.put("goal_title", goalTitle);

        return sendNotificationWithData(fcmToken, title, body, data);
    }
}
