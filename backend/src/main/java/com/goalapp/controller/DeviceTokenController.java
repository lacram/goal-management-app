package com.goalapp.controller;

import com.goalapp.entity.DeviceToken;
import com.goalapp.repository.DeviceTokenRepository;
import com.goalapp.service.FcmService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 디바이스 토큰 관리 컨트롤러
 * FCM 토큰 등록, 조회, 삭제를 처리합니다.
 */
@RestController
@RequestMapping("/api/device-tokens")
@RequiredArgsConstructor
@Slf4j
public class DeviceTokenController {

    private final DeviceTokenRepository deviceTokenRepository;
    private final FcmService fcmService;

    /**
     * FCM 토큰 등록 또는 업데이트
     * POST /api/device-tokens
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> registerToken(@RequestBody Map<String, String> request) {
        String fcmToken = request.get("fcmToken");
        String deviceId = request.get("deviceId");
        String deviceName = request.get("deviceName");
        String platform = request.get("platform");

        log.info("📱 Registering FCM token: device={}, platform={}", deviceName, platform);

        if (fcmToken == null || fcmToken.isEmpty()) {
            log.warn("⚠️ FCM token is empty");
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "FCM token is required");
            return ResponseEntity.badRequest().body(response);
        }

        try {
            // 기존 토큰이 있으면 업데이트, 없으면 새로 생성
            Optional<DeviceToken> existingToken = deviceTokenRepository.findByFcmToken(fcmToken);

            DeviceToken deviceToken;
            if (existingToken.isPresent()) {
                deviceToken = existingToken.get();
                deviceToken.setDeviceId(deviceId);
                deviceToken.setDeviceName(deviceName);
                deviceToken.setPlatform(platform);
                deviceToken.activate();
                log.info("♻️ Updating existing token");
            } else {
                deviceToken = DeviceToken.builder()
                        .fcmToken(fcmToken)
                        .deviceId(deviceId)
                        .deviceName(deviceName)
                        .platform(platform)
                        .isActive(true)
                        .build();
                log.info("✨ Creating new token");
            }

            deviceToken = deviceTokenRepository.save(deviceToken);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Token registered successfully");
            response.put("tokenId", deviceToken.getId());

            log.info("✅ FCM token registered successfully: ID={}", deviceToken.getId());
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("❌ Failed to register FCM token", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Failed to register token: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 모든 활성화된 토큰 조회
     * GET /api/device-tokens
     */
    @GetMapping
    public ResponseEntity<List<DeviceToken>> getAllActiveTokens() {
        log.info("📋 Fetching all active device tokens");
        List<DeviceToken> tokens = deviceTokenRepository.findByIsActiveTrue();
        log.info("✅ Found {} active tokens", tokens.size());
        return ResponseEntity.ok(tokens);
    }

    /**
     * 특정 토큰 조회
     * GET /api/device-tokens/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<DeviceToken> getTokenById(@PathVariable Long id) {
        log.info("🔍 Fetching device token: ID={}", id);
        return deviceTokenRepository.findById(id)
                .map(token -> {
                    log.info("✅ Token found");
                    return ResponseEntity.ok(token);
                })
                .orElseGet(() -> {
                    log.warn("⚠️ Token not found: ID={}", id);
                    return ResponseEntity.notFound().build();
                });
    }

    /**
     * FCM 토큰으로 조회
     * GET /api/device-tokens/by-token?token=xxx
     */
    @GetMapping("/by-token")
    public ResponseEntity<DeviceToken> getTokenByFcmToken(@RequestParam String token) {
        log.info("🔍 Fetching device token by FCM token");
        return deviceTokenRepository.findByFcmToken(token)
                .map(deviceToken -> {
                    log.info("✅ Token found");
                    return ResponseEntity.ok(deviceToken);
                })
                .orElseGet(() -> {
                    log.warn("⚠️ Token not found");
                    return ResponseEntity.notFound().build();
                });
    }

    /**
     * 토큰 삭제 (비활성화)
     * DELETE /api/device-tokens/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteToken(@PathVariable Long id) {
        log.info("🗑️ Deleting device token: ID={}", id);

        return deviceTokenRepository.findById(id)
                .map(token -> {
                    token.deactivate();
                    deviceTokenRepository.save(token);

                    Map<String, Object> response = new HashMap<>();
                    response.put("success", true);
                    response.put("message", "Token deactivated successfully");

                    log.info("✅ Token deactivated: ID={}", id);
                    return ResponseEntity.ok(response);
                })
                .orElseGet(() -> {
                    Map<String, Object> response = new HashMap<>();
                    response.put("success", false);
                    response.put("message", "Token not found");

                    log.warn("⚠️ Token not found: ID={}", id);
                    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
                });
    }

    /**
     * 테스트 알림 전송
     * POST /api/device-tokens/test-notification
     */
    @PostMapping("/test-notification")
    public ResponseEntity<Map<String, Object>> sendTestNotification(@RequestBody Map<String, String> request) {
        String fcmToken = request.get("fcmToken");
        String title = request.getOrDefault("title", "테스트 알림");
        String body = request.getOrDefault("body", "Goal Management App 알림 테스트입니다.");

        log.info("🧪 Sending test notification");

        if (fcmToken == null || fcmToken.isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "FCM token is required");
            return ResponseEntity.badRequest().body(response);
        }

        boolean success = fcmService.sendNotification(fcmToken, title, body);

        Map<String, Object> response = new HashMap<>();
        response.put("success", success);
        response.put("message", success ? "Test notification sent successfully" : "Failed to send notification");

        if (success) {
            // 토큰 사용 기록 업데이트
            deviceTokenRepository.findByFcmToken(fcmToken).ifPresent(token -> {
                token.markAsUsed();
                deviceTokenRepository.save(token);
            });
        }

        return ResponseEntity.ok(response);
    }
}
