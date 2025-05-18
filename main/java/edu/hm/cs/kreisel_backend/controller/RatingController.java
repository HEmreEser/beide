package edu.hm.cs.kreisel_backend.controller;

import edu.hm.cs.kreisel_backend.dto.RatingRequest;
import edu.hm.cs.kreisel_backend.dto.RatingResponse;
import edu.hm.cs.kreisel_backend.model.*;
import edu.hm.cs.kreisel_backend.repository.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

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
    public ResponseEntity<?> addRating(@Valid @RequestBody RatingRequest request, @RequestHeader(value = "Authorization", required = false) String authHeader) {
        // Extract user ID from the dummy token for now
        // Format is "dummy-token-{userId}"
        Long userId = null;
        if (authHeader != null && authHeader.startsWith("Bearer dummy-token-")) {
            try {
                userId = Long.parseLong(authHeader.substring(18));
            } catch (NumberFormatException e) {
                return ResponseEntity.status(401).body("Ungültiger Token");
            }
        }

        if (userId == null) {
            return ResponseEntity.status(401).body("Nicht authentifiziert");
        }

        Optional<User> userOpt = userRepo.findById(userId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(401).body("User nicht gefunden");
        }

        User user = userOpt.get();
        Equipment equipment = equipmentRepo.findById(request.getEquipmentId()).orElse(null);
        if (equipment == null) {
            return ResponseEntity.badRequest().body("Equipment nicht gefunden");
        }

        // Check if user has already rated this equipment
        Optional<Rating> existingRating = ratingRepo.findByUserIdAndEquipmentId(user.getId(), equipment.getId());
        if (existingRating.isPresent()) {
            // Update existing rating
            Rating rating = existingRating.get();
            rating.setRating(request.getStars());
            rating.setComment(request.getComment());
            ratingRepo.save(rating);
            return ResponseEntity.ok("Bewertung aktualisiert");
        }

        // Create new rating
        Rating rating = new Rating();
        rating.setEquipment(equipment);
        rating.setUser(user);
        rating.setRating(request.getStars());  // Field name is "rating" in the entity
        rating.setComment(request.getComment());

        ratingRepo.save(rating);

        return ResponseEntity.ok("Bewertung hinzugefügt");
    }

    @GetMapping("/equipment/{equipmentId}")
    public ResponseEntity<List<RatingResponse>> getRatingsForEquipment(@PathVariable Long equipmentId) {
        List<RatingResponse> ratings = ratingRepo.findByEquipmentId(equipmentId)
                .stream()
                .map(RatingResponse::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ratings);
    }

    @GetMapping("/user")
    public ResponseEntity<?> getUserRatings(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        // Extract user ID from the dummy token
        Long userId = null;
        if (authHeader != null && authHeader.startsWith("Bearer dummy-token-")) {
            try {
                userId = Long.parseLong(authHeader.substring(18));
            } catch (NumberFormatException e) {
                return ResponseEntity.status(401).body("Ungültiger Token");
            }
        }

        if (userId == null) {
            return ResponseEntity.status(401).body("Nicht authentifiziert");
        }

        List<RatingResponse> ratings = ratingRepo.findByUserId(userId)
                .stream()
                .map(RatingResponse::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ratings);
    }
}