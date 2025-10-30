import 'dart:convert';

import 'package:asset_bor/auth_storage.dart';
import 'package:asset_bor/config.dart';
import 'package:asset_bor/lecturer/lecturer_asset_list.dart';
import 'package:asset_bor/lecturer/lecturer_history.dart';
import 'package:asset_bor/lecturer/lecturer_requested_item.dart';
import 'package:asset_bor/lecturer/widgets/lecturer_logout.dart';
import 'package:asset_bor/lecturer/widgets/lecturer_nav_bar.dart';
import 'package:asset_bor/login.dart';
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

  Widget buildChartBar(String label, int value, Color color) {
    final height = value.clamp(0, 30) * 6.0 + 12;
    return Expanded(
      child: Column(
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget buildStatCard(String label, int value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF42A45A),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget BodyBuilder() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4FF00)));
    }

    if (errorMsg != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $errorMsg', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadCounts,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    final available = readCount('available_units');
    final borrowed = readCount('borrowed_units');
    final disabled = readCount('disabled_units');
    final pending = readCount('pending_requests');

    return RefreshIndicator(
      color: const Color(0xFFD4FF00),
      backgroundColor: const Color(0xFF1F1F1F),
      onRefresh: loadCounts,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildChartBar('Available', available, const Color(0xFFB9FF66)),
              const SizedBox(width: 12),
              buildChartBar('Borrowing', borrowed, const Color(0xFF7AD8FF)),
              const SizedBox(width: 12),
              buildChartBar('Disabled', disabled, const Color(0xFF6C6C70)),
              const SizedBox(width: 12),
              buildChartBar('Pending', pending, const Color(0xFFFFFF99)),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                buildStatCard('Available', available),
                buildStatCard('Pending', pending),
                buildStatCard('Disabled', disabled),
                buildStatCard('Borrowed', borrowed),
              ],
            ),
          ),
        ],
      ),
    );
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
        actions: const [
          LecturerLogoutButton(iconColor: Colors.white),
        ],
      ),
      body: SafeArea(child: BodyBuilder()),
      bottomNavigationBar: LecturerNavBar(index: 0, onTap: handleNavTap),
    );
  }
}
