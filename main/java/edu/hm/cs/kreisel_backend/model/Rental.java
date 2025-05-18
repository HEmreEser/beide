package edu.hm.cs.kreisel_backend.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@Entity
public class Rental {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JsonBackReference
    private User user;

    @ManyToOne(fetch = FetchType.EAGER)
    private Equipment equipment;

    private LocalDate startDate;
    private LocalDate endDate;

    private boolean returned = false;
    private boolean extended = false;
}
