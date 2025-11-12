import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:asset_bor/shared/logout.dart';
import '../config.dart'; // baseUrl
import 'staff_assets_list.dart';
import 'staff_handin-out_page.dart';
import 'staff_history_page.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _selectedIndex = 0;
  late Future<_Counts> _future;

  final Color _scaffoldBgColor = const Color.fromARGB(255, 39, 39, 39);
  final Color _accentColor = const Color(0xFFD8FFA3);

  @override
  void initState() {
    super.initState();
    _future = _fetchCounts();
  }

  Future<_Counts> _fetchCounts() async {
    try {
      final res = await http.get(Uri.parse('${AppConfig.baseUrl}/counts'));
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return _Counts.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load counts: $e');
    }
  }

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

  // 🔹 Dashboard body
  Widget _buildDashboardBody(_Counts c) {
    const background = Color(0xFF1F1F1F);
    const accent = Color(0xFFD4FF00);
    const availableColor = Color(0xFFB9FF66);
    const borrowingColor = Color(0xFF7AD8FF);
    const disabledColor = Color(0xFF6C6C70);
    const pendingColor = Color(0xFFFFFF99);

    return RefreshIndicator(
      color: accent,
      backgroundColor: background,
      onRefresh: () async => setState(() => _future = _fetchCounts()),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const LogoutButton(iconColor: Colors.white),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('Available', c.availableUnits, availableColor),
              const SizedBox(width: 12),
              _buildChartBar('Borrowed', c.borrowedUnits, borrowingColor),
              const SizedBox(width: 12),
              _buildChartBar('Pending', c.pendingRequests, pendingColor),
              const SizedBox(width: 12),
              _buildChartBar('Disabled', c.disabledUnits, disabledColor),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard('Available', c.availableUnits, availableColor),
                _buildStatCard('Borrowed', c.borrowedUnits, borrowingColor),
                _buildStatCard('Pending', c.pendingRequests, pendingColor),
                _buildStatCard('Disabled', c.disabledUnits, disabledColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, int value, Color color) {
    final height = value.clamp(0, 30) * 6.0 + 12;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
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
            style: TextStyle(
              color: color,
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

  // 🔹 Main build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        child: FutureBuilder<_Counts>(
          future: _future,
          builder: (context, s) {
            if (s.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4FF00)),
              );
            }
            if (s.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error: ${s.error}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => setState(() => _future = _fetchCounts()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final counts = s.data!;
            return _buildDashboardBody(counts);
          },
        ),
      ),
    );
  }
}

// 🔹 Model สำหรับ count data
class _Counts {
  final int borrowedUnits;
  final int availableUnits;
  final int disabledUnits;
  final int pendingRequests;

  _Counts({
    required this.borrowedUnits,
    required this.availableUnits,
    required this.disabledUnits,
    required this.pendingRequests,
  });

  factory _Counts.fromJson(Map<String, dynamic> j) => _Counts(
    borrowedUnits: _asInt(j['borrowed_units']),
    availableUnits: _asInt(j['available_units']),
    disabledUnits: _asInt(j['disabled_units']),
    pendingRequests: _asInt(j['pending_requests']),
  );
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final n = int.tryParse(v) ?? double.tryParse(v)?.toInt();
    return n ?? 0;
  }
  return 0;
}
