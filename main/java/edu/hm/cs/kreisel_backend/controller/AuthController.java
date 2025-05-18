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
import java.util.Optional;

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
        Optional<User> userOpt = userRepository.findByEmail(request.getEmail());
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(401).body("User nicht gefunden");
        }

        User user = userOpt.get();
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return ResponseEntity.status(401).body("Falsches Passwort");
        }

        // Dummy token für Testzwecke – JWT kann später eingebaut werden
        String token = "dummy-token-" + user.getId();

        // Gib Token als JSON zurück
        return ResponseEntity.ok(new TokenResponse(token));
    }

    // Hilfsklasse für das Token-Response-Objekt
    public static class TokenResponse {
        private String token;

        public TokenResponse(String token) {
            this.token = token;
        }

        public String getToken() {
            return token;
        }

        public void setToken(String token) {
            this.token = token;
        }
    }
}