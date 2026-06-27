package com.studybuddy.backend.repository;

import com.studybuddy.backend.model.Streak;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface StreakRepository extends JpaRepository<Streak, Long> {
    List<Streak> findByUserEmailOrderByStudyDateDesc(String email);
    boolean existsByUserEmailAndStudyDate(String email, LocalDate date);
}