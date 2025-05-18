package edu.hm.cs.kreisel_backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RegisterRequest {

    @Email(regexp = "^[a-zA-Z0-9._%+-]+@hm\\.edu$", message = "Nur hm.edu Emails erlaubt")
    private String email;

    @NotBlank
    private String password;
}