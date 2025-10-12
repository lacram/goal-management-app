package com.goalapp.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateGoalRequest {
    
    private String title;
    
    private String description;
    
    private LocalDateTime dueDate;
    
    private Integer priority;
    
    private Boolean reminderEnabled;
    
    private String reminderFrequency;
}