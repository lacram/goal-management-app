package com.goalapp.dto.response;

import com.goalapp.entity.Routine;
import com.goalapp.entity.RoutineFrequency;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoutineResponse {

    private Long id;
    private String title;
    private String description;
    private RoutineFrequency frequency;
    private boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private boolean completedToday;

    public static RoutineResponse from(Routine routine) {
        return RoutineResponse.builder()
                .id(routine.getId())
                .title(routine.getTitle())
                .description(routine.getDescription())
                .frequency(routine.getFrequency())
                .isActive(routine.isActive())
                .createdAt(routine.getCreatedAt())
                .updatedAt(routine.getUpdatedAt())
                .completedToday(false) // 기본값, 컨트롤러에서 설정
                .build();
    }
}
