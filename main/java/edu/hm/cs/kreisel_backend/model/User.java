package edu.hm.cs.kreisel_backend.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Email(regexp = "^[a-zA-Z0-9._%+-]+@hm\\.edu$", message = "Nur hm.edu Emails erlaubt")
    @Column(unique = true, nullable = false)
    private String email;

    @NotBlank
    private String password;

    @Enumerated(EnumType.STRING)
    private Role role;

    @OneToMany(mappedBy = "user")
    private List<Rental> rentals;

    public enum Role {
        USER,
        ADMIN
    }
}
