package com.goalapp.repository;

import com.goalapp.entity.DeviceToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 디바이스 토큰 레포지토리
 */
@Repository
public interface DeviceTokenRepository extends JpaRepository<DeviceToken, Long> {

    /**
     * FCM 토큰으로 디바이스 조회
     */
    Optional<DeviceToken> findByFcmToken(String fcmToken);

    /**
     * 활성화된 모든 디바이스 토큰 조회
     */
    List<DeviceToken> findByIsActiveTrue();

    /**
     * 비활성화된 모든 디바이스 토큰 조회
     */
    List<DeviceToken> findByIsActiveFalse();

    /**
     * 디바이스 ID로 조회
     */
    List<DeviceToken> findByDeviceId(String deviceId);

    /**
     * 플랫폼별 활성화된 토큰 조회
     */
    List<DeviceToken> findByPlatformAndIsActiveTrue(String platform);

    /**
     * 특정 기간 이상 사용되지 않은 토큰 조회
     * (오래된 토큰 정리용)
     */
    @Query("SELECT d FROM DeviceToken d WHERE d.lastUsedAt < :threshold OR d.lastUsedAt IS NULL")
    List<DeviceToken> findUnusedTokensSince(@Param("threshold") LocalDateTime threshold);

    /**
     * FCM 토큰이 이미 존재하는지 확인
     */
    boolean existsByFcmToken(String fcmToken);

    /**
     * 특정 기간 이후 생성된 토큰 조회
     */
    List<DeviceToken> findByCreatedAtAfter(LocalDateTime date);
}
