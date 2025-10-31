import 'dart:convert';

import 'package:asset_bor/config.dart';
import 'package:asset_bor/shared/dashboard.dart';
import 'package:asset_bor/staff/staff_assets_list.dart';
import 'package:asset_bor/staff/staff_handin-out_page.dart';
import 'package:asset_bor/staff/staff_history_page.dart';
import 'package:asset_bor/shared/logout.dart';
import 'package:asset_bor/shared/navbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _selectedIndex = 0; // ตำแหน่ง Nav ปัจจุบัน (Dashboard)
  final Color _scaffoldBgColor = const Color.fromARGB(255, 39, 39, 39);
  Map<String, dynamic> counts = {};
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    loadCounts();
  }

  Future<void> loadCounts() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/counts'));
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
        MaterialPageRoute(builder: (context) => const StaffAssetsList()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StaffHandPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StaffHistoryPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: _scaffoldBgColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          LogoutButton(iconColor: Colors.white),
        ],
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
      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavTap),
    );
  }
}
