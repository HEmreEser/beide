package edu.hm.cs.kreisel_backend.controller;

import edu.hm.cs.kreisel_backend.dto.LoginRequest;
import edu.hm.cs.kreisel_backend.dto.RegisterRequest;
import edu.hm.cs.kreisel_backend.model.User;
import edu.hm.cs.kreisel_backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Email bereits registriert");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        // Admins via Email
        if (request.getEmail().startsWith("admin") && request.getEmail().endsWith("@hm.edu")) {
            user.setRole(User.Role.ADMIN);
        } else {
            user.setRole(User.Role.USER);
        }

        return ResponseEntity.ok(userRepository.save(user));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        // Dummy Response – JWT Token Auth wird später gemacht
        return ResponseEntity.ok("Login erfolgreich (Platzhalter)");
    }
}
