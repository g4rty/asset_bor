import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_storage.dart';
import '../config.dart';
import 'lecturer_asset_list.dart';
import 'lecturer_history.dart';
import 'lecturer_requested_item.dart';
import 'widgets/lecturer_nav_bar.dart';
import 'package:flutter/material.dart';

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage({super.key});

  @override
  State<LecturerHomePage> createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  late Future<_Counts> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchCounts();
    _ensureUser();
  }

  Future<void> _ensureUser() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null && mounted) {
      await AuthStorage.clearUserId();
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<_Counts> _fetchCounts() async {
    final r = await http.get(Uri.parse('${AppConfig.baseUrl}/counts'));
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return _Counts.fromJson(j);
  }

  void _handleNavTap(int i) {
    if (i == 0) return; // already Home
    if (i == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LecturerAssetList()),
      );
    } else if (i == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LecturerRequestedItem()),
      );
    } else if (i == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LecturerHistory()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFD4FF00),
          onRefresh: () async => setState(() => _future = _fetchCounts()),
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
                  child: Text('Error: ${s.error}',
                      style: const TextStyle(color: Colors.white)),
                );
              }
              final c = s.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  const Text('Dashboard',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // very simple bars
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar('Available', c.availableUnits, Colors.lightGreenAccent),
                      _bar('Borrowing', c.borrowedUnits, Colors.lightBlueAccent),
                      _bar('Disabled', c.disabledUnits, Colors.grey),
                      _bar('Pending', c.pendingRequests, const Color(0xFFFFFF99)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // stat cards
                  Center(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _stat('Available', c.availableUnits),
                        _stat('Pending', c.pendingRequests),
                        _stat('Disable', c.disabledUnits),
                        _stat('Borrowed', c.borrowedUnits),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: LecturerNavBar(index: 0, onTap: _handleNavTap),
    );
  }

  Widget _bar(String label, int value, Color color) {
    final h = (value.clamp(0, 30)) * 6.0 + 8; // simple scale
    return Expanded(
      child: Column(
        children: [
          Container(height: h, color: color),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text('$value',
              style: const TextStyle(
                  color: Color(0xFF42A45A),
                  fontSize: 28,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
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
