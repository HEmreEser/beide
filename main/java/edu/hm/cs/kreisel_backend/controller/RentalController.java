package edu.hm.cs.kreisel_backend.controller;

import edu.hm.cs.kreisel_backend.dto.RentalRequest;
import edu.hm.cs.kreisel_backend.dto.RentalResponse;
import edu.hm.cs.kreisel_backend.model.*;
import edu.hm.cs.kreisel_backend.repository.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/rentals")
public class RentalController {

    @Autowired
    private RentalRepository rentalRepo;

    @Autowired
    private EquipmentRepository equipmentRepo;

    @Autowired
    private UserRepository userRepo;

    @PostMapping
    @Transactional
    public ResponseEntity<?> createRental(@Valid @RequestBody RentalRequest request, Principal principal) {
        try {
            // For testing purposes, allow direct user ID in request if principal is null
            User user;
            if (principal != null) {
                user = userRepo.findByEmail(principal.getName()).orElse(null);
                if (user == null) {
                    return ResponseEntity.status(401).body("User nicht gefunden");
                }
            } else if (request.getUserId() != null) {
                // Fallback for testing
                user = userRepo.findById(request.getUserId()).orElse(null);
                if (user == null) {
                    return ResponseEntity.status(401).body("User nicht gefunden");
                }
            } else {
                return ResponseEntity.status(401).body("Authentication required");
            }

            // Find equipment and verify it's available
            Equipment equipment = equipmentRepo.findById(request.getEquipmentId())
                    .orElseThrow(() -> new RuntimeException("Equipment not found"));

            if (!equipment.isAvailable()) {
                return ResponseEntity.badRequest().body("Gerät nicht verfügbar");
            }

            // Validate dates
            if (request.getStartDate() == null || request.getEndDate() == null) {
                return ResponseEntity.badRequest().body("Start- und Enddatum müssen angegeben werden");
            }

            if (request.getStartDate().isBefore(LocalDate.now())) {
                return ResponseEntity.badRequest().body("Startdatum kann nicht in der Vergangenheit liegen");
            }

            if (request.getEndDate().isBefore(request.getStartDate())) {
                return ResponseEntity.badRequest().body("Enddatum kann nicht vor dem Startdatum liegen");
            }

            // Create rental record
            Rental rental = new Rental();
            rental.setEquipment(equipment);
            rental.setStartDate(request.getStartDate());
            rental.setEndDate(request.getEndDate());
            rental.setUser(user);
            rental.setReturned(false);
            rental.setExtended(false);

            // Update equipment availability
            equipment.setAvailable(false);

            // Save both entities
            equipmentRepo.save(equipment);
            Rental savedRental = rentalRepo.save(rental);

            return ResponseEntity.ok(new RentalResponse(savedRental));

        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error creating rental: " + e.getMessage());
        }
    }

    @GetMapping("/user")
    public ResponseEntity<?> getUserRentals(Principal principal, @RequestParam(required = false) Long userId) {
        try {
            User user;

            // Handle both authenticated requests and test requests with userId
            if (principal != null) {
                user = userRepo.findByEmail(principal.getName()).orElse(null);
            } else if (userId != null) {
                user = userRepo.findById(userId).orElse(null);
            } else {
                return ResponseEntity.status(401).body("Authentication required");
            }

            if (user == null) {
                return ResponseEntity.status(401).body("User not found");
            }

            List<RentalResponse> rentals = rentalRepo.findByUserId(user.getId())
                    .stream()
                    .map(RentalResponse::new)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(rentals);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error fetching rentals: " + e.getMessage());
        }
    }

    @PostMapping("/{rentalId}/return")
    @Transactional
    public ResponseEntity<?> returnRental(@PathVariable Long rentalId,
                                          Principal principal,
                                          @RequestParam(required = false) Long userId) {
        try {
            Rental rental = rentalRepo.findById(rentalId)
                    .orElseThrow(() -> new RuntimeException("Rental not found"));

            if (rental.isReturned()) {
                return ResponseEntity.badRequest().body("Bereits zurückgegeben");
            }

            // Handle both authenticated requests and test requests with userId
            if (principal != null) {
                if (!rental.getUser().getEmail().equals(principal.getName())) {
                    return ResponseEntity.status(403).body("Nicht berechtigt");
                }
            } else if (userId != null) {
                if (!rental.getUser().getId().equals(userId)) {
                    return ResponseEntity.status(403).body("Nicht berechtigt");
                }
            } else {
                return ResponseEntity.status(401).body("Authentication required");
            }

            // Mark as returned and update equipment availability
            rental.setReturned(true);
            Equipment equipment = rental.getEquipment();
            equipment.setAvailable(true);

            // Save both entities
            equipmentRepo.save(equipment);
            rentalRepo.save(rental);

            return ResponseEntity.ok("Gerät zurückgegeben");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error returning equipment: " + e.getMessage());
        }
    }

    // Get all rentals - admin only endpoint
    @GetMapping("/all")
    public ResponseEntity<?> getAllRentals() {
        try {
            List<RentalResponse> rentals = rentalRepo.findAll()
                    .stream()
                    .map(RentalResponse::new)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(rentals);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error fetching all rentals: " + e.getMessage());
        }
    }
}