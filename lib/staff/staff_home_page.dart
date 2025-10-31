import 'dart:convert';

import 'package:asset_bor/config.dart';
import 'package:asset_bor/shared/dashboard_body.dart';
import 'package:asset_bor/staff/staff_assets_list.dart';
import 'package:asset_bor/staff/staff_handin-out_page.dart';
import 'package:asset_bor/staff/staff_history_page.dart';
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
  final Color _accentColor = const Color(0xFFD8FFA3);
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

  // 🔹 Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home, index: 0),
          _buildNavItem(icon: Icons.shopping_bag_outlined, index: 1),
          _buildNavItem(icon: Icons.list_alt_outlined, index: 2),
          _buildNavItem(icon: Icons.history, index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () async {
        setState(() => _selectedIndex = index);
        if (index == 1) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffAssetsList()),
          );
        } else if (index == 2) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffHandPage()),
          );
        } else if (index == 3) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffHistoryPage()),
          );
        }
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white,
          size: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
