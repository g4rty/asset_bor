import 'dart:convert';

import 'package:asset_bor/lecturer/lecturer_asset_list.dart';

import '/config.dart';
import 'auth_storage.dart';
import '/lecturer/lecturer_home_page.dart';
import '/register.dart';
import '/staff/staff_home_page.dart';
import '/student/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


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
        // Uri.parse('${_backendBaseUrl()}/login'),
        Uri.parse('${AppConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        setState(() {
          _role = data['role'] as String?;
          userId = data['id'] as int;
        });
  
        // Save user id.
        await AuthStorage.setUserId(userId!);

        Widget? destination;
        if (_role == 'lecturer') {
          destination = const LecturerAssetList();
        } else if (_role == 'staff') {
          destination = const StaffHomePage();
        } else if (_role == 'student') {
          destination = const StudentHomePage();
        }

        if (destination != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Welcome back!',
                style: TextStyle(
                  // color: Color.fromARGB(255, 190, 230, 130),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              content: Text(
                'You have successfully logged in',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop(); // ปิด dialog ก่อน
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => destination!),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
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
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
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
              child: Image.asset('assets/images/login_dino.png'),
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
