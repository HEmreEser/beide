package edu.hm.cs.kreisel_backend.controller;

import edu.hm.cs.kreisel_backend.model.Location;
import edu.hm.cs.kreisel_backend.repository.LocationRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/locations")
public class LocationController {

    @Autowired
    private LocationRepository locationRepo;

    @GetMapping
    public List<Location> getAllLocations() {
        return locationRepo.findAll();
    }

    @PostMapping
    public ResponseEntity<Location> createLocation(@Valid @RequestBody Location location) {
        return ResponseEntity.ok(locationRepo.save(location));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getLocationById(@PathVariable Long id) {
        return locationRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}