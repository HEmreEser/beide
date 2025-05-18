package edu.hm.cs.kreisel_backend.repository;

import edu.hm.cs.kreisel_backend.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    // Basic methods provided by JpaRepository
}