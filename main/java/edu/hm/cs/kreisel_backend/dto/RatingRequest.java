package edu.hm.cs.kreisel_backend.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RatingRequest {
    @NotNull
    private Long equipmentId;

    @Min(1)
    @Max(5)
    private int stars;  // im DTO heißt es "stars"

    @NotBlank
    private String comment;
}
