import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int streakCount = 0;
  int sessionsToday = 0;
  int totalFocusMinutes = 0;
  int quizzesCompleted = 0;
  bool isLoading = true;
  String userEmail = '';

  final String baseUrl = 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email') ?? 'test@gmail.com';
    sessionsToday = prefs.getInt('sessions_today') ?? 0;
    totalFocusMinutes = prefs.getInt('total_focus_minutes') ?? 0;
    quizzesCompleted = prefs.getInt('quizzes_completed') ?? 0;

    try {
      final res = await http.get(
          Uri.parse('$baseUrl/api/streak/count/$userEmail'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => streakCount = data['streak'] ?? 0);
      }
    } catch (e) {
      debugPrint('Error loading streak: $e');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0f0f23),
        appBar: AppBar(
            backgroundColor: const Color(0xFF1a1a2e),
            title: const Text('My Progress',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold))),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(
            color: Color(0xFF534AB7)))
            : RefreshIndicator(
            onRefresh: loadData,
            child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overview',
                          style: TextStyle(color: Colors.white,
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(children: [
                        _statCard('Current streak',
                            '$streakCount days', '🔥',
                            const Color(0xFFBA7517)),
                        const SizedBox(width: 12),
                        _statCard('Sessions today',
                            '$sessionsToday', '⏱️',
                            const Color(0xFF534AB7)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        _statCard('Focus time',
                            '${totalFocusMinutes}m', '🎯',
                            const Color(0xFF1D9E75)),
                        const SizedBox(width: 12),
                        _statCard('Quizzes done',
                            '$quizzesCompleted', '📝',
                            const Color(0xFFD85A30)),
                      ]),
                      const SizedBox(height: 28),
                      const Text('Weekly activity',
                          style: TextStyle(color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _weeklyChart(),
                      const SizedBox(height: 28),
                      const Text('Achievements',
                          style: TextStyle(color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _achievementCard('First session',
                          'Completed your first study session',
                          sessionsToday >= 1, const Color(0xFF534AB7)),
                      const SizedBox(height: 10),
                      _achievementCard('Quiz master',
                          'Completed 5 quizzes',
                          quizzesCompleted >= 5, const Color(0xFF1D9E75)),
                      const SizedBox(height: 10),
                      _achievementCard('3 day streak',
                          'Studied 3 days in a row',
                          streakCount >= 3, const Color(0xFFBA7517)),
                      const SizedBox(height: 10),
                      _achievementCard('Focus champion',
                          'Accumulated 100 minutes of focus time',
                          totalFocusMinutes >= 100,
                          const Color(0xFFD85A30)),
                    ]))));
  }

  Widget _statCard(String label, String value,
      String emoji, Color color) {
    return Expanded(
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: color.withOpacity(0.3))),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(value,
                      style: TextStyle(color: color,
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ])));
  }

  Widget _weeklyChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = [3, 5, 2, 7, 4, 6, sessionsToday];
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(14)),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final height = maxVal > 0
                  ? (values[i] / maxVal * 100).toDouble() : 0.0;
              final isToday = i == 6;
              return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${values[i]}',
                        style: TextStyle(
                            color: isToday
                                ? const Color(0xFF534AB7) : Colors.grey,
                            fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                        width: 28,
                        height: height + 4,
                        decoration: BoxDecoration(
                            color: isToday
                                ? const Color(0xFF534AB7)
                                : const Color(0xFF534AB7).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 6),
                    Text(days[i],
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 10)),
                  ]);
            })));
  }

  Widget _achievementCard(String title, String desc,
      bool unlocked, Color color) {
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: unlocked
                    ? color.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.2))),
        child: Row(children: [
          Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: unlocked
                      ? color.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(
                  unlocked ? Icons.emoji_events : Icons.lock,
                  color: unlocked ? color : Colors.grey,
                  size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: unlocked ? Colors.white : Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
              ])),
          if (unlocked)
            Icon(Icons.check_circle,
                color: color, size: 20),
        ]));
  }
}