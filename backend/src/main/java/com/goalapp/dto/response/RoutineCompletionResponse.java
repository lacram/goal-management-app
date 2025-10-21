package com.goalapp.dto.response;

import com.goalapp.entity.RoutineCompletion;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoutineCompletionResponse {

    private Long id;
    private Long routineId;
    private LocalDateTime completedAt;
    private String note;

    public static RoutineCompletionResponse from(RoutineCompletion completion) {
        return RoutineCompletionResponse.builder()
                .id(completion.getId())
                .routineId(completion.getRoutine().getId())
                .completedAt(completion.getCompletedAt())
                .note(completion.getNote())
                .build();
    }
}
