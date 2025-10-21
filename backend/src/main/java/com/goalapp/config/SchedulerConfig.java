package com.goalapp.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Spring Scheduler 설정
 * @Scheduled 어노테이션을 사용한 스케줄러를 활성화합니다.
 */
@Configuration
@EnableScheduling
public class SchedulerConfig {
    // @EnableScheduling 만으로도 충분
    // 필요시 TaskScheduler bean을 커스터마이징할 수 있음
}
