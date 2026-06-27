package com.studybuddy.backend.controller;

import com.studybuddy.backend.model.User;
import com.studybuddy.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import java.util.Date;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    private BCryptPasswordEncoder passwordEncoder =
            new BCryptPasswordEncoder();

    @PostMapping("/register")
    public ResponseEntity<?> register(
            @RequestBody Map<String, String> request) {

        String email = request.get("email");
        String password = request.get("password");
        String name = request.get("name");

        if (userRepository.existsByEmail(email)) {
            return ResponseEntity.badRequest()
                    .body("Email already exists");
        }

        User user = new User();
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));
        user.setName(name);

        userRepository.save(user);

        return ResponseEntity.ok("User registered successfully");
    }
    @PostMapping("/login")
    public ResponseEntity<?> login(
            @RequestBody Map<String, String> request) {

        String email = request.get("email");
        String password = request.get("password");

        Optional<User> userOpt = userRepository.findByEmail(email);

        if (userOpt.isEmpty() || !passwordEncoder
                .matches(password, userOpt.get().getPassword())) {
            return ResponseEntity.badRequest()
                    .body("Invalid email or password");
        }

        String token = Jwts.builder()
                .setSubject(email)
                .setIssuedAt(new Date())
                .setExpiration(new Date(
                        System.currentTimeMillis() + 86400000))
                .signWith(Keys.hmacShaKeyFor(
                                "StudyBuddySecretKey2024ABCDEFGHIJK".getBytes()),
                        SignatureAlgorithm.HS256)
                .compact();

        return ResponseEntity.ok(
                Map.of("token", token, "email", email));
    }
}
