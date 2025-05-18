package edu.hm.cs.kreisel_backend.dto;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Setter
@Getter
public class RentalRequest {

    @NotNull(message = "Equipment ID is required")
    private Long equipmentId;

    @NotNull(message = "Start date is required")
    private LocalDate startDate;

    @NotNull(message = "End date is required")
    private LocalDate endDate;

    // Optional field for testing without authentication
    private Long userId;
}