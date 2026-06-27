import '../notification_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});
  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int focusTime = 25 * 60;
  static const int shortBreak = 5 * 60;
  static const int longBreak = 15 * 60;

  int currentMode = 0;
  int timeLeft = focusTime;
  bool isRunning = false;
  int sessionsCompleted = 0;
  int totalFocusMinutes = 0;
  Timer? timer;

  final List<String> modeNames = ['Focus', 'Short break', 'Long break'];
  final List<int> modeTimes = [focusTime, shortBreak, longBreak];
  final List<Color> modeColors = [
    const Color(0xFF534AB7),
    const Color(0xFF1D9E75),
    const Color(0xFFBA7517),
  ];

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        completeSession();
      }
    });
    setState(() => isRunning = true);
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      timeLeft = modeTimes[currentMode];
      isRunning = false;
    });
  }

  void skipSession() {
    timer?.cancel();
    completeSession();
  }

  void completeSession() {
    timer?.cancel();
    setState(() => isRunning = false);
    if (currentMode == 0) {
      sessionsCompleted++;
      totalFocusMinutes += 25;
      NotificationService.showNotification(
        id: 1,
        title: 'Focus session complete!',
        body: 'Great work! Take a 5 minute break.',
      );
    } else {
      NotificationService.showNotification(
        id: 2,
        title: 'Break time over!',
        body: 'Ready to focus again? Let us go!',
      );
    }
    showCompletionDialog();
  }

  void showCompletionDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1a1a2e),
            title: Text(
                currentMode == 0 ? 'Focus session done!' : 'Break done!',
                style: const TextStyle(color: Colors.white)),
            content: Text(
                currentMode == 0
                    ? 'Great work! Take a break.'
                    : 'Ready to focus again?',
                style: const TextStyle(color: Colors.grey)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    switchMode((currentMode + 1) % 3);
                  },
                  child: Text('Next',
                      style: TextStyle(color: modeColors[currentMode]))),
            ]));
  }

  void switchMode(int mode) {
    timer?.cancel();
    setState(() {
      currentMode = mode;
      timeLeft = modeTimes[mode];
      isRunning = false;
    });
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get progress {
    return 1 - (timeLeft / modeTimes[currentMode]);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = modeColors[currentMode];
    return Scaffold(
        backgroundColor: const Color(0xFF0f0f23),
        appBar: AppBar(
            backgroundColor: const Color(0xFF1a1a2e),
            title: const Text('Pomodoro Timer',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold))),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ...List.generate(3, (i) => GestureDetector(
                    onTap: () => switchMode(i),
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                            color: currentMode == i
                                ? modeColors[i] : const Color(0xFF1a1a2e),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: currentMode == i
                                    ? modeColors[i] : const Color(0xFF333344))),
                        child: Text(modeNames[i],
                            style: TextStyle(
                                color: currentMode == i ? Colors.white : Colors.grey,
                                fontSize: 12))))),
              ]),
              const SizedBox(height: 40),
              SizedBox(
                  width: 220, height: 220,
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox(
                        width: 220, height: 220,
                        child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 10,
                            backgroundColor: const Color(0xFF1a1a2e),
                            color: color)),
                    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(formatTime(timeLeft),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 48,
                              fontWeight: FontWeight.bold)),
                      Text(modeNames[currentMode].toUpperCase(),
                          style: TextStyle(color: color, fontSize: 12,
                              letterSpacing: 2)),
                    ]),
                  ])),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ...List.generate(4, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < sessionsCompleted % 4
                            ? color : const Color(0xFF333344)))),
              ]),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _controlBtn(Icons.refresh, resetTimer, false, color),
                    const SizedBox(width: 16),
                    GestureDetector(
                        onTap: isRunning ? pauseTimer : startTimer,
                        child: Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                            child: Icon(
                                isRunning ? Icons.pause : Icons.play_arrow,
                                color: Colors.white, size: 36))),
                    const SizedBox(width: 16),
                    _controlBtn(Icons.skip_next, skipSession, false, color),
                  ]),
              const SizedBox(height: 40),
              Row(children: [
                _statCard('Sessions', '$sessionsCompleted', color),
                const SizedBox(width: 12),
                _statCard('Focus time', '${totalFocusMinutes}m', color),
                const SizedBox(width: 12),
                _statCard('Streak', '1 day', color),
              ]),
            ])));
  }

  Widget _controlBtn(IconData icon, VoidCallback onTap,
      bool isPrimary, Color color) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1a1a2e),
                border: Border.all(color: const Color(0xFF333344))),
            child: Icon(icon, color: Colors.grey, size: 24)));
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Text(value,
                  style: TextStyle(color: color, fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  textAlign: TextAlign.center),
            ])));
  }
}