import 'package:flutter/material.dart';

import 'login.dart' show LoginPage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AssetBorrowingApp());
}

class AssetBorrowingApp extends StatelessWidget {
  const AssetBorrowingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asset Borrowing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
