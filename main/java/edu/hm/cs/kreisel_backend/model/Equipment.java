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

    @Column(nullable = false)
    private String name;

    @Column(nullable = true)
    private String type; // optional z.B. "Fußball", "Mountainbike"

    @Column(nullable = true)
    private String description;

    @Column(nullable = false)
    private boolean available = true;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "location_id", nullable = false)
    private Location location;

    @OneToMany(mappedBy = "equipment", cascade = CascadeType.ALL)
    private List<Rating> ratings;

    @OneToMany(mappedBy = "equipment", cascade = CascadeType.ALL)
    private List<Rental> rentals;
}