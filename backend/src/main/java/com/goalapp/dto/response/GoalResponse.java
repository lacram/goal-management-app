package com.goalapp.dto.response;

import com.goalapp.entity.Goal;
import com.goalapp.entity.GoalStatus;
import com.goalapp.entity.GoalType;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GoalResponse {
    
    private Long id;
    private String title;
    private String description;
    private GoalType type;
    private GoalStatus status;
    private Long parentGoalId;
    private List<GoalResponse> subGoals;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime dueDate;
    private LocalDateTime completedAt;
    
    @JsonProperty("isCompleted")
    private boolean isCompleted;
    private int priority;
    private boolean reminderEnabled;
    private String reminderFrequency;
    private double progressPercentage;
    
    public static GoalResponse from(Goal goal) {
        // 하위 목표가 있는 경우 세션 내에서만 호출되므로 getProgressPercentage() 사용 가능
        double progress;
        try {
            progress = goal.getProgressPercentage();
        } catch (Exception e) {
            // LazyInitializationException 발생 시 보수적으로 처리
            progress = goal.isCompleted() ? 100.0 : 0.0;
        }
        
        return GoalResponse.builder()
                .id(goal.getId())
                .title(goal.getTitle())
                .description(goal.getDescription())
                .type(goal.getType())
                .status(goal.getStatus())
                .parentGoalId(goal.getParentGoal() != null ? goal.getParentGoal().getId() : null)
                .subGoals(goal.getSubGoals().stream()
                        .map(GoalResponse::fromWithoutSubGoals)
                        .collect(Collectors.toList()))
                .createdAt(goal.getCreatedAt())
                .updatedAt(goal.getUpdatedAt())
                .dueDate(goal.getDueDate())
                .completedAt(goal.getCompletedAt())
                .isCompleted(goal.isCompleted())
                .priority(goal.getPriority())
                .reminderEnabled(goal.isReminderEnabled())
                .reminderFrequency(goal.getReminderFrequency())
                .progressPercentage(progress)
                .build();
    }
    
    public static GoalResponse fromWithoutSubGoals(Goal goal) {
        // progressPercentage는 별도로 계산하지 않고 완료 상태로만 판단
        double progress = goal.isCompleted() ? 100.0 : 0.0;
        
        return GoalResponse.builder()
                .id(goal.getId())
                .title(goal.getTitle())
                .description(goal.getDescription())
                .type(goal.getType())
                .status(goal.getStatus())
                .parentGoalId(goal.getParentGoal() != null ? goal.getParentGoal().getId() : null)
                .subGoals(null)
                .createdAt(goal.getCreatedAt())
                .updatedAt(goal.getUpdatedAt())
                .dueDate(goal.getDueDate())
                .completedAt(goal.getCompletedAt())
                .isCompleted(goal.isCompleted())
                .priority(goal.getPriority())
                .reminderEnabled(goal.isReminderEnabled())
                .reminderFrequency(goal.getReminderFrequency())
                .progressPercentage(progress)
                .build();
    }
    
    public static GoalResponse fromWithProgress(Goal goal, double progressPercentage) {
        return GoalResponse.builder()
                .id(goal.getId())
                .title(goal.getTitle())
                .description(goal.getDescription())
                .type(goal.getType())
                .status(goal.getStatus())
                .parentGoalId(goal.getParentGoal() != null ? goal.getParentGoal().getId() : null)
                .subGoals(null)
                .createdAt(goal.getCreatedAt())
                .updatedAt(goal.getUpdatedAt())
                .dueDate(goal.getDueDate())
                .completedAt(goal.getCompletedAt())
                .isCompleted(goal.isCompleted())
                .priority(goal.getPriority())
                .reminderEnabled(goal.isReminderEnabled())
                .reminderFrequency(goal.getReminderFrequency())
                .progressPercentage(progressPercentage)
                .build();
    }
}