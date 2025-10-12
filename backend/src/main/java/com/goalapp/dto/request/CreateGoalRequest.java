package com.goalapp.dto.request;

import com.goalapp.entity.GoalType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateGoalRequest {
    
    @NotBlank(message = "목표 제목은 필수입니다")
    private String title;
    
    private String description;
    
    @NotNull(message = "목표 타입은 필수입니다")
    private GoalType type;
    
    private Long parentGoalId;
    
    private LocalDateTime dueDate;
    
    @Builder.Default
    private Integer priority = 1;
    
    @Builder.Default
    private boolean reminderEnabled = false;
    
    private String reminderFrequency;
}