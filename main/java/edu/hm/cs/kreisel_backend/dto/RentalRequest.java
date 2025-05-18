package edu.hm.cs.kreisel_backend.dto;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Setter
@Getter
public class RentalRequest {

    // Getter & Setter
    @NotNull
    private Long equipmentId;

    @NotNull
    private LocalDate startDate;

    @NotNull
    private LocalDate endDate;

}
