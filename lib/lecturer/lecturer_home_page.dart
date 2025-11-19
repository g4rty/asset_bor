import 'dart:convert';

import 'package:asset_bor/auth_storage.dart';
import 'package:asset_bor/config.dart';
import 'package:asset_bor/lecturer/lecturer_asset_list.dart';
import 'package:asset_bor/lecturer/lecturer_history.dart';
import 'package:asset_bor/lecturer/lecturer_requested_item.dart';
import 'package:asset_bor/shared/logout.dart';
import 'package:asset_bor/shared/navbar.dart';
import 'package:asset_bor/login.dart';
import 'package:asset_bor/shared/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage({super.key});

  @override
  State<LecturerHomePage> createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  Map<String, dynamic> counts = {};
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    ensureUser();
    loadCounts();
  }

  Future<void> ensureUser() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null && mounted) {
      await AuthStorage.clearUserId();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> loadCounts() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/counts'),
        headers: await AuthStorage.withSessionCookie(null),
      );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        counts = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMsg = '$e';
        isLoading = false;
      });
    }
  }

  int readCount(String key) {
    final v = counts[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? 0;
    }
    return 0;
  }

  void handleNavTap(int index) {
    if (index == 0) return;
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LecturerAssetList()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LecturerRequestedItem()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LecturerHistory()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Assets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: const [LogoutButton(iconColor: Colors.white)],
      ),
      body: SafeArea(
        child: buildDashboardBody(
          isLoading: isLoading,
          errorText: errorMsg,
          onRefresh: loadCounts,
          onRetry: loadCounts,
          available: readCount('available_units'),
          borrowed: readCount('borrowed_units'),
          disabled: readCount('disabled_units'),
          pending: readCount('pending_requests'),
        ),
      ),
      bottomNavigationBar: NavBar(index: 0, onTap: handleNavTap),
    );
  }
}
