package com.studybuddy.backend.controller;

import com.studybuddy.backend.model.Streak;
import com.studybuddy.backend.repository.StreakRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/streak")
@CrossOrigin(origins = "*")
public class StreakController {

    @Autowired
    private StreakRepository streakRepository;

    @PostMapping("/record")
    public ResponseEntity<?> recordStreak(
            @RequestBody Map<String, String> request) {

        String email = request.get("email");
        LocalDate today = LocalDate.now();

        if (!streakRepository.existsByUserEmailAndStudyDate(email, today)) {
            Streak streak = new Streak();
            streak.setUserEmail(email);
            streak.setStudyDate(today);
            streakRepository.save(streak);
        }

        return ResponseEntity.ok(
                Map.of("message", "Streak recorded!",
                        "streak", calculateStreak(email)));
    }

    @GetMapping("/count/{email}")
    public ResponseEntity<?> getStreak(@PathVariable String email) {
        return ResponseEntity.ok(
                Map.of("streak", calculateStreak(email)));
    }

    private int calculateStreak(String email) {
        List<Streak> streaks = streakRepository
                .findByUserEmailOrderByStudyDateDesc(email);
        if (streaks.isEmpty()) return 0;

        int count = 1;
        LocalDate expected = LocalDate.now().minusDays(1);

        for (int i = 1; i < streaks.size(); i++) {
            if (streaks.get(i).getStudyDate().equals(expected)) {
                count++;
                expected = expected.minusDays(1);
            } else break;
        }
        return count;
    }
}