import 'package:flutter/material.dart';

class StaffHistoryPage extends StatefulWidget {
  const StaffHistoryPage({super.key});

  @override
  State<StaffHistoryPage> createState() => _StaffHistoryPageState();
}

class _StaffHistoryPageState extends State<StaffHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Title(color: Colors.black, child: Text('kuy tad')),
    );
  }
}
