package edu.hm.cs.kreisel_backend.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "app_review")
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    @JsonBackReference("user-reviews")
    private User user;

    @ManyToOne
    @JoinColumn(name = "item_id", nullable = false)
    @JsonBackReference("item-reviews")
    private Item item;

    @OneToOne
    @JoinColumn(name = "rental_id", nullable = false, unique = true)
    @JsonBackReference("rental-review")
    private Rental rental;

    @NotNull
    @Min(value = 1, message = "Rating muss zwischen 1 und 5 liegen")
    @Max(value = 5, message = "Rating muss zwischen 1 und 5 liegen")
    private Integer rating;

    @Column(length = 1000)
    private String comment;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
