import 'package:flutter/material.dart';

class StaffHomePage extends StatelessWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Portal'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Set up staff features here.'),
      ),
    );
  }
}
