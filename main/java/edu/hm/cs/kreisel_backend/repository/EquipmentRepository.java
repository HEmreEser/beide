package edu.hm.cs.kreisel_backend.repository;

import edu.hm.cs.kreisel_backend.model.Equipment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EquipmentRepository extends JpaRepository<Equipment, Long> {
    List<Equipment> findByAvailableTrue();

    List<Equipment> findByCategory_NameAndAvailableTrue(String category);

    List<Equipment> findByLocation_NameAndAvailableTrue(String location);
}
