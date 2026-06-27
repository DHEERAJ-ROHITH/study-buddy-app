import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
final List<Map<String, String>> messages = [
{'role': 'ai', 'text': 'Hi! I am your AI study assistant. Ask me anything!'}
];
final TextEditingController inputCtrl = TextEditingController();
bool isLoading = false;
final ScrollController scrollCtrl = ScrollController();

final String baseUrl = 'http://10.0.2.2:8080/api/ai';

Future<void> sendMessage() async {
final question = inputCtrl.text.trim();
if (question.isEmpty) return;

setState(() {
messages.add({'role': 'user', 'text': question});
isLoading = true;
});
inputCtrl.clear();
scrollToBottom();

try {
final res = await http.post(
Uri.parse('$baseUrl/ask'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode({'question': question}),
);
if (res.statusCode == 200) {
final data = jsonDecode(res.body);
setState(() {
messages.add({'role': 'ai', 'text': data['answer']});
});
} else {
setState(() {
messages.add({'role': 'ai', 'text': 'Sorry, something went wrong!'});
});
}
} catch (e) {
setState(() {
messages.add({'role': 'ai', 'text': 'Connection error: $e'});
});
}
setState(() => isLoading = false);
scrollToBottom();
}

void scrollToBottom() {
Future.delayed(const Duration(milliseconds: 100), () {
if (scrollCtrl.hasClients) {
scrollCtrl.animateTo(
scrollCtrl.position.maxScrollExtent,
duration: const Duration(milliseconds: 300),
curve: Curves.easeOut,
);
}
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFF0f0f23),
appBar: AppBar(
backgroundColor: const Color(0xFF1a1a2e),
title: Row(children: [
CircleAvatar(
backgroundColor: const Color(0xFF534AB7),
radius: 16,
child: const Text('S',
style: TextStyle(color: Color(0xFFEEEDFE), fontSize: 14))),
const SizedBox(width: 10),
Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
const Text('Study Buddy AI',
style: TextStyle(color: Colors.white, fontSize: 14,
fontWeight: FontWeight.bold)),
const Text('Online',
style: TextStyle(color: Color(0xFF1D9E75), fontSize: 11)),
]),
]),
),
body: Column(children: [
Expanded(
child: ListView.builder(
controller: scrollCtrl,
padding: const EdgeInsets.all(16),
itemCount: messages.length + (isLoading ? 1 : 0),
itemBuilder: (context, index) {
if (index == messages.length) {
return const Align(
alignment: Alignment.centerLeft,
child: Padding(
padding: EdgeInsets.all(8),
child: SizedBox(
width: 40,
child: LinearProgressIndicator(
color: Color(0xFF534AB7)))));
}
final msg = messages[index];
final isUser = msg['role'] == 'user';
return Align(
alignment: isUser
? Alignment.centerRight
: Alignment.centerLeft,
child: Container(
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.symmetric(
horizontal: 14, vertical: 10),
constraints: BoxConstraints(
maxWidth: MediaQuery.of(context).size.width * 0.75),
decoration: BoxDecoration(
color: isUser
? const Color(0xFF534AB7)
: const Color(0xFF1a1a2e),
borderRadius: BorderRadius.only(
topLeft: const Radius.circular(14),
topRight: const Radius.circular(14),
bottomLeft: Radius.circular(isUser ? 14 : 4),
bottomRight: Radius.circular(isUser ? 4 : 14))),
child: Text(msg['text']!,
style: TextStyle(
color: isUser ? const Color(0xFFEEEDFE) : Colors.white70,
fontSize: 14, height: 1.5))));
}),
),
Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
color: const Color(0xFF1a1a2e),
child: Row(children: [
Expanded(
child: TextField(
controller: inputCtrl,
style: const TextStyle(color: Colors.white, fontSize: 14),
decoration: InputDecoration(
hintText: 'Ask your doubt...',
hintStyle: const TextStyle(color: Colors.grey),
filled: true,
fillColor: const Color(0xFF0f0f23),
contentPadding: const EdgeInsets.symmetric(
horizontal: 16, vertical: 10),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(24),
borderSide: BorderSide.none)),
onSubmitted: (_) => sendMessage())),
const SizedBox(width: 8),
  GestureDetector(
      onTap: sendMessage,
      child: Container(
          width: 44, height: 44,
          decoration: const BoxDecoration(
              color: Color(0xFF534AB7),
              shape: BoxShape.circle),
          child: const Icon(Icons.send,
              color: Color(0xFFEEEDFE), size: 20))),
])),
]));
}
}
