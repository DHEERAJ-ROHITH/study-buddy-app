import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController textCtrl = TextEditingController();
  List<dynamic> questions = [];
  int currentIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isLoading = false;
  bool quizStarted = false;

  final String baseUrl = 'http://10.0.2.2:8080/api/ai';

  Future<void> generateQuiz() async {
    if (textCtrl.text.trim().isEmpty) return;
    setState(() => isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/flashcards'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': textCtrl.text.trim()}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        String raw = data['flashcards'];
        raw = raw.replaceAll('```json', '').replaceAll('```', '').trim();
        final parsed = jsonDecode(raw);
        setState(() {
          questions = parsed;
          currentIndex = 0;
          score = 0;
          selectedAnswer = null;
          showResult = false;
          quizStarted = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
    setState(() => isLoading = false);
  }

  void selectAnswer(String answer) {
    if (selectedAnswer != null) return;
    setState(() => selectedAnswer = answer);
    if (answer == questions[currentIndex]['answer']) {
      score++;
    }
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
      });
    } else {
      setState(() => showResult = true);
    }
  }

  void resetQuiz() {
    setState(() {
      questions = [];
      currentIndex = 0;
      score = 0;
      selectedAnswer = null;
      showResult = false;
      quizStarted = false;
      textCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Quiz Generator',
            style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold)),
        actions: [
          if (quizStarted)
            IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: resetQuiz)
        ],
      ),
      body: !quizStarted ? _buildInputScreen() :
      showResult ? _buildResultScreen() :
      _buildQuizScreen(),
    );
  }

  Widget _buildInputScreen() {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 20),
          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFF1a1a2e),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                const Icon(Icons.quiz, color: Color(0xFF534AB7), size: 48),
                const SizedBox(height: 12),
                const Text('Generate Quiz from Text',
                    style: TextStyle(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Paste any study text and AI will create MCQs',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center),
              ])),
          const SizedBox(height: 24),
          TextField(
              controller: textCtrl,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  hintText: 'Paste your study notes here...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1a1a2e),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF333344))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF333344))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF534AB7))))),
          const SizedBox(height: 20),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: isLoading ? null : generateQuiz,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF534AB7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Generate Quiz',
                      style: TextStyle(color: Colors.white,
                          fontSize: 16, fontWeight: FontWeight.bold)))),
        ]));
  }

  Widget _buildQuizScreen() {
    final q = questions[currentIndex];
    final options = List<String>.from(q['options']);
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              backgroundColor: const Color(0xFF1a1a2e),
              color: const Color(0xFF534AB7)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Question ${currentIndex + 1}/${questions.length}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text('Score: $score',
                style: const TextStyle(color: Color(0xFF1D9E75),
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 24),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFF1a1a2e),
                  borderRadius: BorderRadius.circular(16)),
              child: Text(q['question'],
                  style: const TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.bold,
                      height: 1.5))),
          const SizedBox(height: 20),
          ...options.map((option) {
            Color optionColor = const Color(0xFF1a1a2e);
            Color textColor = Colors.white70;
            if (selectedAnswer != null) {
              if (option == q['answer']) {
                optionColor = const Color(0xFF0F6E56);
                textColor = Colors.white;
              } else if (option == selectedAnswer) {
                optionColor = const Color(0xFF993C1D);
                textColor = Colors.white;
              }
            }
            return GestureDetector(
                onTap: () => selectAnswer(option),
                child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: optionColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: selectedAnswer == option
                                ? Colors.transparent
                                : const Color(0xFF333344))),
                    child: Text(option,
                        style: TextStyle(color: textColor, fontSize: 14))));
          }),
          if (selectedAnswer != null) ...[
            const SizedBox(height: 8),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: nextQuestion,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF534AB7),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text(
                        currentIndex < questions.length - 1
                            ? 'Next Question' : 'See Results',
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold)))),
          ],
        ]));
  }

  Widget _buildResultScreen() {
    final percentage = (score / questions.length * 100).round();
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                          color: const Color(0xFF1a1a2e),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: percentage >= 60
                                  ? const Color(0xFF1D9E75)
                                  : const Color(0xFFD85A30),
                              width: 4)),
                      child: Center(
                          child: Text('$percentage%',
                              style: TextStyle(
                                  color: percentage >= 60
                                      ? const Color(0xFF1D9E75)
                                      : const Color(0xFFD85A30),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)))),
                  const SizedBox(height: 24),
                  Text(
                      percentage >= 80 ? 'Excellent!' :
                      percentage >= 60 ? 'Good job!' : 'Keep practicing!',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('You scored $score out of ${questions.length}',
                      style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 40),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: resetQuiz,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF534AB7),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('Try Another Quiz',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.bold)))),
                ])));
    }
}