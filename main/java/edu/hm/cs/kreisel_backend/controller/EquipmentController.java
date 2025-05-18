package edu.hm.cs.kreisel_backend.controller;

import edu.hm.cs.kreisel_backend.dto.EquipmentRequest;
import edu.hm.cs.kreisel_backend.model.Category;
import edu.hm.cs.kreisel_backend.model.Equipment;
import edu.hm.cs.kreisel_backend.model.Location;
import edu.hm.cs.kreisel_backend.repository.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/equipment")
public class EquipmentController {

    @Autowired
    private EquipmentRepository equipmentRepo;

    @Autowired
    private CategoryRepository categoryRepo;

    @Autowired
    private LocationRepository locationRepo;

    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody EquipmentRequest request) {
        try {
            // Check if category exists
            Category category = categoryRepo.findById(request.getCategoryId())
                    .orElseThrow(() -> new RuntimeException("Category with ID " + request.getCategoryId() + " not found"));

            // Check if location exists
            Location location = locationRepo.findById(request.getLocationId())
                    .orElseThrow(() -> new RuntimeException("Location with ID " + request.getLocationId() + " not found"));

            Equipment equipment = new Equipment();
            equipment.setName(request.getName());

            // Handle potentially null type field
            String type = request.getType();
            equipment.setType(type != null ? type : "");

            // Handle potentially null description field
            String description = request.getDescription();
            equipment.setDescription(description != null ? description : "");

            equipment.setAvailable(true);
            equipment.setCategory(category);
            equipment.setLocation(location);

            Equipment savedEquipment = equipmentRepo.save(equipment);
            return ResponseEntity.ok(savedEquipment);

        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error creating equipment: " + e.getMessage());
        }
    }

    @GetMapping
    public List<Equipment> getAvailable() {
        return equipmentRepo.findByAvailableTrue();
    }

    @GetMapping("/category/{categoryId}")
    public ResponseEntity<?> filterByCategory(@PathVariable Long categoryId) {
        if (!categoryRepo.existsById(categoryId)) {
            return ResponseEntity.badRequest().body("Category not found");
        }
        return ResponseEntity.ok(equipmentRepo.findByCategoryIdAndAvailableTrue(categoryId));
    }

    @GetMapping("/location/{locationId}")
    public ResponseEntity<?> filterByLocation(@PathVariable Long locationId) {
        if (!locationRepo.existsById(locationId)) {
            return ResponseEntity.badRequest().body("Location not found");
        }
        return ResponseEntity.ok(equipmentRepo.findByLocationIdAndAvailableTrue(locationId));
    }

    @GetMapping("/filter")
    public List<Equipment> filterByCategoryAndLocation(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long locationId) {

        if (categoryId != null && locationId != null) {
            return equipmentRepo.findByCategoryIdAndLocationIdAndAvailableTrue(categoryId, locationId);
        } else if (categoryId != null) {
            return equipmentRepo.findByCategoryIdAndAvailableTrue(categoryId);
        } else if (locationId != null) {
            return equipmentRepo.findByLocationIdAndAvailableTrue(locationId);
        } else {
            return equipmentRepo.findByAvailableTrue();
        }
    }

    @GetMapping("/categories")
    public List<Category> getAllCategories() {
        return categoryRepo.findAll();
    }

    @GetMapping("/locations")
    public List<Location> getAllLocations() {
        return locationRepo.findAll();
    }
}