package edu.hm.cs.kreisel_backend.controller;

import edu.hm.cs.kreisel_backend.dto.RentalRequest;
import edu.hm.cs.kreisel_backend.dto.RentalResponse;
import edu.hm.cs.kreisel_backend.model.*;
import edu.hm.cs.kreisel_backend.repository.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
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
    public ResponseEntity<?> createRental(@Valid @RequestBody RentalRequest request, Principal principal) {
        Equipment equipment = equipmentRepo.findById(request.getEquipmentId()).orElse(null);
        if (equipment == null || !equipment.isAvailable()) {
            return ResponseEntity.badRequest().body("Gerät nicht verfügbar");
        }

        User user = userRepo.findByEmail(principal.getName()).orElse(null);
        if (user == null) {
            return ResponseEntity.status(401).body("User nicht gefunden");
        }

        Rental rental = new Rental();
        rental.setEquipment(equipment);
        rental.setStartDate(request.getStartDate());
        rental.setEndDate(request.getEndDate());
        rental.setUser(user);

        equipment.setAvailable(false); // blockieren

        rentalRepo.save(rental);
        equipmentRepo.save(equipment);

        return ResponseEntity.ok(new RentalResponse(rental));
    }

    @GetMapping("/user")
    public ResponseEntity<List<RentalResponse>> getUserRentals(Principal principal) {
        User user = userRepo.findByEmail(principal.getName()).orElse(null);
        if (user == null) return ResponseEntity.status(401).build();

        List<RentalResponse> rentals = rentalRepo.findByUserId(user.getId())
                .stream()
                .map(RentalResponse::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(rentals);
    }

    @PostMapping("/{rentalId}/return")
    public ResponseEntity<?> returnRental(@PathVariable Long rentalId, Principal principal) {
        Rental rental = rentalRepo.findById(rentalId).orElse(null);
        if (rental == null || rental.isReturned()) {
            return ResponseEntity.badRequest().body("Nicht gefunden oder bereits zurückgegeben");
        }

        if (!rental.getUser().getEmail().equals(principal.getName())) {
            return ResponseEntity.status(403).body("Nicht berechtigt");
        }

        rental.setReturned(true);
        rental.getEquipment().setAvailable(true);

        rentalRepo.save(rental);
        equipmentRepo.save(rental.getEquipment());

        return ResponseEntity.ok("Gerät zurückgegeben");
    }
}
