import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  List<Map<String, dynamic>> tasks = [];
  final TextEditingController taskCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('tasks');
    if (saved != null) {
      setState(() => tasks = List<Map<String, dynamic>>
          .from(jsonDecode(saved)));
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks));
  }

  void addTask() {
    if (taskCtrl.text.trim().isEmpty) return;
    setState(() {
      tasks.add({
        'title': taskCtrl.text.trim(),
        'done': false,
        'time': DateTime.now().toIso8601String()
      });
    });
    taskCtrl.clear();
    saveTasks();
  }

  void toggleTask(int index) {
    setState(() => tasks[index]['done'] = !tasks[index]['done']);
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() => tasks.removeAt(index));
    saveTasks();
  }

  int get completedCount =>
      tasks.where((t) => t['done'] == true).length;

  double get progress =>
      tasks.isEmpty ? 0 : completedCount / tasks.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0f0f23),
        appBar: AppBar(
            backgroundColor: const Color(0xFF1a1a2e),
            title: const Text('Study Planner',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold))),
        body: Column(children: [
          Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF1a1a2e),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Today's tasks",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text('$completedCount/${tasks.length} done',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ]),
                const SizedBox(height: 10),
                ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFF333344),
                        color: const Color(0xFF1D9E75),
                        minHeight: 8)),
              ])),
          Expanded(
              child: tasks.isEmpty
                  ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.checklist,
                            color: Colors.grey, size: 64),
                        const SizedBox(height: 16),
                        const Text('No tasks yet!',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text('Add your study tasks below',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13)),
                      ]))
                  : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, i) {
                    final task = tasks[i];
                    final isDone = task['done'] == true;
                    return Dismissible(
                        key: Key(task['time']),
                        onDismissed: (_) => deleteTask(i),
                        background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xFF993C1D),
                                borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete,
                                color: Colors.white)),
                        child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                                color: const Color(0xFF1a1a2e),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: isDone
                                        ? const Color(0xFF1D9E75).withOpacity(0.4)
                                        : const Color(0xFF333344))),
                            child: Row(children: [
                              GestureDetector(
                                  onTap: () => toggleTask(i),
                                  child: Container(
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDone
                                              ? const Color(0xFF1D9E75)
                                              : Colors.transparent,
                                          border: Border.all(
                                              color: isDone
                                                  ? const Color(0xFF1D9E75)
                                                  : Colors.grey)),
                                      child: isDone
                                          ? const Icon(Icons.check,
                                          color: Colors.white, size: 16)
                                          : null)),
                              const SizedBox(width: 14),
                              Expanded(
                                  child: Text(task['title'],
                                      style: TextStyle(
                                          color: isDone
                                              ? Colors.grey : Colors.white,
                                          fontSize: 14,
                                          decoration: isDone
                                              ? TextDecoration.lineThrough
                                              : null))),
                            ])));
                    })),
          Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              color: const Color(0xFF1a1a2e),
              child: Row(children: [
                Expanded(
                    child: TextField(
                        controller: taskCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: 'Add a study task...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF0f0f23),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none)),
                        onSubmitted: (_) => addTask())),
                const SizedBox(width: 10),
                GestureDetector(
                    onTap: addTask,
                    child: Container(
                        width: 48, height: 48,
                        decoration: const BoxDecoration(
                            color: Color(0xFF534AB7),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 24))),
              ])),
        ]));
  }
}