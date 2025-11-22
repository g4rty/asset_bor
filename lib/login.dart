import 'dart:convert';

import '/config.dart';
import 'auth_storage.dart';
import '/lecturer/lecturer_home_page.dart';
import '/register.dart';
import '/staff/staff_home_page.dart';
import '/student/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'shared/backend_image.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _role;
  int? userId;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter both username and password.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/login'),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final rawCookie = response.headers['set-cookie'];
        if (rawCookie == null) {
          throw Exception('No session cookie returned from server');
        }
        final sessionCookie = rawCookie.split(';').first;
        await AuthStorage.setSessionCookie(sessionCookie);

        setState(() {
          _role = data['role'] as String?;
          userId = data['id'] as int;
        });

        // Save user id.
        await AuthStorage.setUserId(userId!);

        Widget? destination;
        if (_role == 'lecturer') {
          destination = const LecturerHomePage();
        } else if (_role == 'staff') {
          destination = const StaffHomePage();
        } else if (_role == 'student') {
          destination = const StudentHomePage();
        }

        if (destination != null) {
          const accent = Color.fromARGB(255, 210, 245, 160);
          const dark = Color(0xFF1F1F1F);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: dark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              title: const Text(
                'Welcome back!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
              content: const Text(
                'You have successfully logged in.',
                style: TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => destination!),
                      (route) => false,
                    );
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unknown role returned from server')),
          );
        }
      } else {
        final msg = response.body.isEmpty ? 'Login failed' : response.body;
        _showErrorDialog(msg);
      }
    } catch (e) {
      _showErrorDialog('Login error: $e');
    }
  }

  void _showErrorDialog(String message) async {
    const accent = Color.fromARGB(255, 210, 245, 160);
    const dark = Color(0xFF1F1F1F);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          title: const Text(
            'Error',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black),
      backgroundColor: Color(000000),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 500),
            Container(
              width: 280,
              height: 280,
              child: backendImageWidget(
                'login_dino.png',
                fit: BoxFit.contain,
                placeholder: Image.asset('assets/images/login_dino.png'),
                error: Image.asset('assets/images/login_dino.png'),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 35, color: Colors.white),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 380,
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.transparent, // no background
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 210, 245, 160), // border color
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(
                        255,
                        190,
                        230,
                        130,
                      ), // brighter on focus
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 380,
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 210, 245, 160),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 190, 230, 130),
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 25),
            SizedBox(
              width: 380,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    255,
                    210,
                    245,
                    160,
                  ), // border fill
                  foregroundColor: Colors.black, // text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Color.fromARGB(255, 210, 245, 160)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
