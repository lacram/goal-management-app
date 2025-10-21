package com.goalapp.dto.request;

import com.goalapp.entity.RoutineFrequency;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateRoutineRequest {

    private String title;
    private String description;
    private RoutineFrequency frequency;
}
