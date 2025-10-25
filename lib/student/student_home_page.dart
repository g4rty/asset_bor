import 'package:flutter/material.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Set up student features here.'),
      ),
    );
  }
}
