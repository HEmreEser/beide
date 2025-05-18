package edu.hm.cs.kreisel_backend.repository;

import edu.hm.cs.kreisel_backend.model.Location;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LocationRepository extends JpaRepository<Location, Long> {
    // Basic methods provided by JpaRepository
}