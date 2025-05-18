package edu.hm.cs.kreisel_backend.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class EquipmentRequest {

    @NotBlank
    private String name;

    private String type;
    private String description;

    private Long categoryId;
    private Long locationId;
}
