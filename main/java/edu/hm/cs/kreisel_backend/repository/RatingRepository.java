package edu.hm.cs.kreisel_backend.repository;

import edu.hm.cs.kreisel_backend.model.Rating;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RatingRepository extends JpaRepository<Rating, Long> {
    List<Rating> findByEquipmentId(Long equipmentId);
}
