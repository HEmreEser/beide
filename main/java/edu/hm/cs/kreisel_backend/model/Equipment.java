package edu.hm.cs.kreisel_backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@Entity
public class Equipment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String type; // optional z.B. "Fußball", "Mountainbike"
    private String description;

    private boolean available = true;

    @ManyToOne
    private Category category;

    @ManyToOne
    private Location location;

    @OneToMany(mappedBy = "equipment", cascade = CascadeType.ALL)
    private List<Rating> ratings;

    @OneToMany(mappedBy = "equipment", cascade = CascadeType.ALL)
    private List<Rental> rentals;
}
