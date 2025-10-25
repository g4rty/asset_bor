import 'package:flutter/material.dart';
import 'login.dart' show LoginPage;

void main() => runApp(const AssetBorrowingApp());

class AssetBorrowingApp extends StatelessWidget {
  const AssetBorrowingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asset Borrowing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
