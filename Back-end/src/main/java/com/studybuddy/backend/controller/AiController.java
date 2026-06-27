package com.studybuddy.backend.controller;

import com.studybuddy.backend.service.GeminiService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/ai")
@CrossOrigin(origins = "*")
public class AiController {

    @Autowired
    private GeminiService geminiService;

    @PostMapping("/ask")
    public ResponseEntity<?> askDoubt(
            @RequestBody Map<String, String> request) {

        String question = request.get("question");
        String answer = geminiService.askGemini(question);
        return ResponseEntity.ok(Map.of("answer", answer));
    }

    @PostMapping("/flashcards")
    public ResponseEntity<?> generateFlashcards(
            @RequestBody Map<String, String> request) {

        String text = request.get("text");
        String prompt = "Generate 5 multiple choice questions from this text. " +
                "Return ONLY a JSON array, no extra text, no markdown. " +
                "Each object must have: 'question' (string), " +
                "'options' (array of 4 strings), 'answer' (string, must match one option exactly). " +
                "Example: [{\"question\":\"What is X?\",\"options\":[\"A\",\"B\",\"C\",\"D\"],\"answer\":\"A\"}] " +
                "Text: " + text;

        String result = geminiService.askGemini(prompt);
        return ResponseEntity.ok(Map.of("flashcards", result));
    }
}