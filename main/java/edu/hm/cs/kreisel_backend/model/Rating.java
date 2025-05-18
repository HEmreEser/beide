package edu.hm.cs.kreisel_backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
public class Rating {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private int rating; // im Entity heißt das Feld "rating"!

    private String comment;

    @OneToOne
    private Rental rental;

    @ManyToOne
    private Equipment equipment;

    @ManyToOne
    private User user;  // User hinzugefügt
}
