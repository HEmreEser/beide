package edu.hm.cs.kreisel_backend.controller;

import edu.hm.cs.kreisel_backend.dto.EquipmentRequest;
import edu.hm.cs.kreisel_backend.model.Equipment;
import edu.hm.cs.kreisel_backend.repository.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
    public ResponseEntity<Equipment> create(@Valid @RequestBody EquipmentRequest request) {
        Equipment equipment = new Equipment();
        equipment.setName(request.getName());
        equipment.setType(request.getType());
        equipment.setDescription(request.getDescription());
        equipment.setAvailable(true);
        equipment.setCategory(categoryRepo.findById(request.getCategoryId()).orElse(null));
        equipment.setLocation(locationRepo.findById(request.getLocationId()).orElse(null));

        return ResponseEntity.ok(equipmentRepo.save(equipment));
    }

    @GetMapping
    public List<Equipment> getAvailable() {
        return equipmentRepo.findByAvailableTrue();
    }

    @GetMapping("/category/{category}")
    public List<Equipment> filterByCategory(@PathVariable String category) {
        return equipmentRepo.findByCategory_NameAndAvailableTrue(category);
    }
    @GetMapping("/location/{location}")
    public List<Equipment> filterByLocation(@PathVariable String location) {
        return equipmentRepo.findByLocation_NameAndAvailableTrue(location);
    }

}
