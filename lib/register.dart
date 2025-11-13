import '/login.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
            SizedBox(height: 16),
            SizedBox(
              width: 380,
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm your password',
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
                onPressed: () {
                  // TODO: add login logic
                },
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
                  'Create Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign in',
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