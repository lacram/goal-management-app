package com.goalapp.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 디바이스 FCM 토큰 엔티티
 * 각 사용자의 디바이스별 FCM 토큰을 저장합니다.
 */
@Entity
@Table(name = "device_tokens")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeviceToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * FCM 토큰 (고유 식별자)
     * 각 디바이스마다 고유한 값
     */
    @Column(name = "fcm_token", nullable = false, unique = true, length = 500)
    private String fcmToken;

    /**
     * 디바이스 식별자 (선택사항)
     * 동일 사용자의 여러 디바이스 구분용
     */
    @Column(name = "device_id", length = 255)
    private String deviceId;

    /**
     * 디바이스 이름 (선택사항)
     * 예: "Galaxy S21", "iPhone 13 Pro"
     */
    @Column(name = "device_name", length = 255)
    private String deviceName;

    /**
     * 플랫폼 (android, ios, web 등)
     */
    @Column(name = "platform", length = 50)
    private String platform;

    /**
     * 토큰 활성화 여부
     */
    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    /**
     * 토큰 생성 일시
     */
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /**
     * 토큰 최종 업데이트 일시
     */
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    /**
     * 마지막 사용 일시
     * 알림 전송 성공 시 업데이트
     */
    @Column(name = "last_used_at")
    private LocalDateTime lastUsedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    /**
     * 토큰 사용 기록 업데이트
     */
    public void markAsUsed() {
        this.lastUsedAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    /**
     * 토큰 비활성화
     */
    public void deactivate() {
        this.isActive = false;
        this.updatedAt = LocalDateTime.now();
    }

    /**
     * 토큰 재활성화
     */
    public void activate() {
        this.isActive = true;
        this.updatedAt = LocalDateTime.now();
    }
}
