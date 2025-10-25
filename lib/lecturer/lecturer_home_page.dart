import 'package:flutter/material.dart';

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage({super.key});

  @override
  State<LecturerHomePage> createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Portal'),
      ),
      body: const SafeArea(
        child: Center(
          child: Text('home test'),
        ),
      ),
    );
  }
}
