package edu.hm.cs.kreisel_backend.controller;

import edu.hm.cs.kreisel_backend.dto.RatingRequest;
import edu.hm.cs.kreisel_backend.model.*;
import edu.hm.cs.kreisel_backend.repository.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/ratings")
public class RatingController {

    @Autowired
    private RatingRepository ratingRepo;

    @Autowired
    private EquipmentRepository equipmentRepo;

    @Autowired
    private UserRepository userRepo;

    @PostMapping
    public ResponseEntity<?> addRating(@Valid @RequestBody RatingRequest request, Principal principal) {
        User user = userRepo.findByEmail(principal.getName()).orElse(null);
        if (user == null) return ResponseEntity.status(401).body("User nicht gefunden");

        Equipment equipment = equipmentRepo.findById(request.getEquipmentId()).orElse(null);
        if (equipment == null) return ResponseEntity.badRequest().body("Equipment nicht gefunden");

        Rating rating = new Rating();
        rating.setEquipment(equipment);
        rating.setUser(user);
        rating.setRating(request.getStars());  // korrektes Setzen
        rating.setComment(request.getComment());

        ratingRepo.save(rating);

        return ResponseEntity.ok("Bewertung hinzugefügt");
    }

    @GetMapping("/equipment/{equipmentId}")
    public ResponseEntity<List<Rating>> getRatingsForEquipment(@PathVariable Long equipmentId) {
        List<Rating> ratings = ratingRepo.findByEquipmentId(equipmentId);
        return ResponseEntity.ok(ratings);
    }
}
