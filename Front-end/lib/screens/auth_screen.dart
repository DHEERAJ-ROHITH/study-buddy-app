import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
bool isLogin = true;
bool isLoading = false;
bool obscurePassword = true;

final emailCtrl = TextEditingController();
final passwordCtrl = TextEditingController();
final nameCtrl = TextEditingController();

final String baseUrl = 'http://10.0.2.2:8080/api/auth';

Future<void> submit() async {
setState(() => isLoading = true);
try {
final url = isLogin ? '$baseUrl/login' : '$baseUrl/register';
final body = isLogin
? {'email': emailCtrl.text, 'password': passwordCtrl.text}
: {'name': nameCtrl.text, 'email': emailCtrl.text,
'password': passwordCtrl.text};

final res = await http.post(Uri.parse(url),
headers: {'Content-Type': 'application/json'},
body: jsonEncode(body));

if (res.statusCode == 200) {
if (isLogin) {
final data = jsonDecode(res.body);
final prefs = await SharedPreferences.getInstance();
await prefs.setString('token', data['token']);
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Login successful!')));
}
} else {
setState(() => isLogin = true);
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Account created! Please login.')));
}
}
} else {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(res.body)));
}
}
} catch (e) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Error: $e')));
}
}
setState(() => isLoading = false);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFF0f0f23),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Column(
children: [
const SizedBox(height: 40),
Container(
width: 64, height: 64,
decoration: BoxDecoration(
color: const Color(0xFF534AB7),
borderRadius: BorderRadius.circular(18)),
child: const Center(
child: Text('S',
style: TextStyle(fontSize: 28,
fontWeight: FontWeight.bold, color: Colors.white))),
),
const SizedBox(height: 12),
const Text('Study Buddy',
style: TextStyle(fontSize: 22,
fontWeight: FontWeight.bold, color: Colors.white)),
const Text('Your AI learning companion',
style: TextStyle(fontSize: 13, color: Colors.grey)),
const SizedBox(height: 32),
Container(
decoration: BoxDecoration(
color: const Color(0xFF1a1a2e),
borderRadius: BorderRadius.circular(10)),
padding: const EdgeInsets.all(4),
child: Row(children: [
_tab('Login', isLogin, () => setState(() => isLogin = true)),
_tab('Sign up', !isLogin, () => setState(() => isLogin = false)),
]),
),
const SizedBox(height: 24),
if (!isLogin) ...[
_field('Full name', nameCtrl, false),
const SizedBox(height: 12),
],
_field('Email', emailCtrl, false),
const SizedBox(height: 12),
_field('Password', passwordCtrl, obscurePassword,
suffix: IconButton(
icon: Icon(obscurePassword
? Icons.visibility_off : Icons.visibility,
color: Colors.grey, size: 20),
onPressed: () =>
setState(() => obscurePassword = !obscurePassword))),
const SizedBox(height: 24),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: isLoading ? null : submit,
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFF534AB7),
padding: const EdgeInsets.symmetric(vertical: 14),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10))),
child: isLoading
? const CircularProgressIndicator(color: Colors.white)
: Text(isLogin ? 'Login' : 'Create account',
style: const TextStyle(
fontSize: 15, fontWeight: FontWeight.bold,
color: Colors.white)))),
],
),
),
),
);
}

Widget _tab(String label, bool active, VoidCallback onTap) =>
Expanded(
child: GestureDetector(
onTap: onTap,
child: Container(
padding: const EdgeInsets.symmetric(vertical: 8),
decoration: BoxDecoration(
color: active ? const Color(0xFF534AB7) : Colors.transparent,
borderRadius: BorderRadius.circular(8)),
child: Text(label,
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 13, fontWeight: FontWeight.w500,
color: active ? Colors.white : Colors.grey)))));

Widget _field(String label, TextEditingController ctrl,
bool obscure, {Widget? suffix}) =>
Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(label,
style: const TextStyle(fontSize: 13, color: Colors.grey)),
const SizedBox(height: 6),
TextField(
controller: ctrl,
obscureText: obscure,
style: const TextStyle(color: Colors.white),
decoration: InputDecoration(
filled: true,
fillColor: const Color(0xFF1a1a2e),
suffixIcon: suffix,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
borderSide: const BorderSide(color: Color(0xFF333344))),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
borderSide: const BorderSide(color: Color(0xFF333344))),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
borderSide: const BorderSide(color: Color(0xFF534AB7))))),
]);}