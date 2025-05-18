package edu.hm.cs.kreisel_backend.repository;

import edu.hm.cs.kreisel_backend.model.Rating;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RatingRepository extends JpaRepository<Rating, Long> {
    List<Rating> findByEquipmentId(Long equipmentId);

    List<Rating> findByUserId(Long userId);

    Optional<Rating> findByUserIdAndEquipmentId(Long userId, Long equipmentId);
}