package com.goalapp.dto.request;

import com.goalapp.entity.RoutineFrequency;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateRoutineRequest {

    @NotBlank(message = "루틴 제목은 필수입니다")
    private String title;

    private String description;

    @NotNull(message = "반복 주기는 필수입니다")
    private RoutineFrequency frequency;
}
