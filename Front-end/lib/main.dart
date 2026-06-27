import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/planner_screen.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const StudyBuddyApp());
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF534AB7)),
          useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final screens = const [
    AuthScreen(),
    ChatScreen(),
    QuizScreen(),
    PomodoroScreen(),
    AnalyticsScreen(),
    PlannerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => setState(() => currentIndex = i),
          backgroundColor: const Color(0xFF1a1a2e),
          selectedItemColor: const Color(0xFF534AB7),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat), label: 'AI Chat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.quiz), label: 'Quiz'),
            BottomNavigationBarItem(
                icon: Icon(Icons.timer), label: 'Pomodoro'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart), label: 'Progress'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: 'Planner'),
          ]),
    );
  }
}