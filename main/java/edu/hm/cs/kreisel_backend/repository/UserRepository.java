package edu.hm.cs.kreisel_backend.repository;

import edu.hm.cs.kreisel_backend.model.*;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}