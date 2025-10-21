package com.goalapp.config;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;

import java.util.TimeZone;

/**
 * 타임존 설정
 * 애플리케이션 전역에서 Asia/Seoul 타임존을 사용하도록 설정
 */
@Configuration
@Slf4j
public class TimeZoneConfig {

    @PostConstruct
    public void init() {
        // JVM 타임존을 Asia/Seoul로 설정
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Seoul"));
        log.info("⏰ Application timezone set to: {}", TimeZone.getDefault().getID());
    }
}
