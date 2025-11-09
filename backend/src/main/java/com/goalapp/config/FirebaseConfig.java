package com.goalapp.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Base64;

/**
 * Firebase 초기화 설정
 * firebase-adminsdk.json 파일 또는 환경 변수를 통해 Firebase를 초기화합니다.
 *
 * ENABLE_FIREBASE 환경변수로 활성화 여부를 제어합니다 (기본값: false)
 * 메모리 제약이 있는 환경에서는 비활성화를 권장합니다 (약 50-100MB 절약)
 */
@Configuration
@Slf4j
public class FirebaseConfig {

    @PostConstruct
    public void initialize() {
        // 환경 변수로 Firebase 활성화 여부 확인 (기본값: false)
        String enableFirebase = System.getenv("ENABLE_FIREBASE");
        boolean isEnabled = "true".equalsIgnoreCase(enableFirebase);

        if (!isEnabled) {
            log.warn("⚠️  Firebase is DISABLED (ENABLE_FIREBASE not set to 'true')");
            log.warn("⚠️  Push notifications will not work. To enable: set ENABLE_FIREBASE=true");
            return;
        }

        try {
            // 이미 초기화되어 있으면 스킵
            if (!FirebaseApp.getApps().isEmpty()) {
                log.info("🔥 Firebase already initialized");
                return;
            }

            FirebaseOptions options;

            // 1. 환경 변수에서 Base64 인코딩된 서비스 계정 키 읽기 (Railway 배포용)
            String base64Credentials = System.getenv("FIREBASE_CREDENTIALS_BASE64");

            if (base64Credentials != null && !base64Credentials.isEmpty()) {
                log.info("🔥 Initializing Firebase from environment variable (Base64)");
                byte[] decodedBytes = Base64.getDecoder().decode(base64Credentials);
                InputStream serviceAccount = new ByteArrayInputStream(decodedBytes);

                options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

            } else {
                // 2. 로컬 파일에서 읽기 (로컬 개발용)
                log.info("🔥 Initializing Firebase from local file");
                InputStream serviceAccount = new ClassPathResource("firebase-adminsdk.json").getInputStream();

                options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();
            }

            FirebaseApp.initializeApp(options);
            log.info("✅ Firebase initialized successfully");

        } catch (IOException e) {
            log.error("❌ Failed to initialize Firebase", e);
            throw new RuntimeException("Failed to initialize Firebase", e);
        }
    }
}
