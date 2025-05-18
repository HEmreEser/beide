package edu.hm.cs.kreisel_backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class EquipmentRequest {

    @NotBlank
    private String name;

    private String type;
    private String description;

    @NotNull(message = "Category is required")
    private Long categoryId;

    @NotNull(message = "Location is required")
    private Long locationId;
}