import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../auth_storage.dart';
import '../config.dart';
import '../login.dart';
import 'staff_assets_list.dart';
import 'staff_history_page.dart';
import 'staff_home_page.dart';

class StaffHandPage extends StatefulWidget {
  const StaffHandPage({super.key});

  @override
  State<StaffHandPage> createState() => _StaffHandPageState();
}

// tab: Hand-out หรือ Hand-in
enum HandTab { handOut, handIn }

class _StaffHandPageState extends State<StaffHandPage> {
  HandTab _selectedTab = HandTab.handOut;
  late Future<List<HandItem>> _futureHandOut;
  late Future<List<HandItem>> _futureHandIn;

  int _selectedIndex = 2; // หน้า Hand-in/out ใน bottom nav
  final Color _accentColor = const Color(0xFFD8FFA3);

  @override
  void initState() {
    super.initState();
    _reloadAll();
  }

  void _reloadAll() {
    _futureHandOut = _fetchHandOutQueue();
    _futureHandIn = _fetchHandInQueue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hand-in / Hand-out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTabBar(),
            const SizedBox(height: 12),
            Expanded(child: _buildTabBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ----------------- Tab bar -----------------

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _tabButton('Hand-out', HandTab.handOut),
          const SizedBox(width: 8),
          _tabButton('Hand-in', HandTab.handIn),
        ],
      ),
    );
  }

  Widget _tabButton(String label, HandTab tab) {
    final bool selected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _accentColor : const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------- Tab body -----------------

  Widget _buildTabBody() {
    if (_selectedTab == HandTab.handOut) {
      return FutureBuilder<List<HandItem>>(
        future: _futureHandOut,
        builder: _buildList('No items to hand-out', isHandOut: true),
      );
    } else {
      return FutureBuilder<List<HandItem>>(
        future: _futureHandIn,
        builder: _buildList('No items to hand-in', isHandOut: false),
      );
    }
  }

  // ⚠️ ตรงนี้คือฟังก์ชันที่แก้ type ให้ถูกแล้ว
  // คืนค่าเป็น "Widget Function(BuildContext, AsyncSnapshot<List<HandItem>>)"
  Widget Function(BuildContext, AsyncSnapshot<List<HandItem>>) _buildList(
    String emptyText, {
    required bool isHandOut,
  }) {
    return (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFD4FF00)),
        );
      }
      if (snapshot.hasError) {
        return Center(
          child: Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: Colors.white),
          ),
        );
      }
      final items = snapshot.data ?? [];
      if (items.isEmpty) {
        return Center(
          child: Text(emptyText, style: const TextStyle(color: Colors.white70)),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _reloadAll();
          });
          await Future.wait([_futureHandOut, _futureHandIn]);
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24 + 84),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _HandCard(
            item: items[index],
            isHandOut: isHandOut,
            onActionDone: () {
              setState(() {
                _reloadAll();
              });
            },
          ),
        ),
      );
    };
  }

  // ----------------- Bottom Navigation Bar -----------------

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

        if (index == 0) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffHomePage()),
          );
        } else if (index == 1) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffAssetsList()),
          );
        } else if (index == 2) {
          // อยู่หน้านี้แล้ว
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

  // ----------------- Fetch Hand-out / Hand-in -----------------

  Future<List<HandItem>> _fetchHandOutQueue() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      await AuthStorage.clearUserId();
      if (!mounted) return [];
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return [];
    }

    final url = Uri.parse('${AppConfig.baseUrl}/staff/$userId/handout-queue');

    final r = await http.get(url);
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
    final List data = jsonDecode(r.body) as List;
    return data
        .map((e) => HandItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<HandItem>> _fetchHandInQueue() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      await AuthStorage.clearUserId();
      if (!mounted) return [];
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return [];
    }

    final url = Uri.parse('${AppConfig.baseUrl}/staff/$userId/handin-queue');

    final r = await http.get(url);
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
    final List data = jsonDecode(r.body) as List;
    return data
        .map((e) => HandItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/* ---------- Data model ---------- */

class HandItem {
  final int requestId;
  final String assetName;
  final String? assetImage;
  final String borrowerName;
  final String? reason;
  final DateTime? requestDate;
  final DateTime? approvalDate;
  final DateTime? borrowDate;
  final DateTime? returnDate;

  HandItem({
    required this.requestId,
    required this.assetName,
    required this.borrowerName,
    this.assetImage,
    this.reason,
    this.requestDate,
    this.approvalDate,
    this.borrowDate,
    this.returnDate,
  });

  factory HandItem.fromJson(Map<String, dynamic> j) => HandItem(
    requestId: j['request_id'] as int,
    assetName: j['asset_name'] as String,
    assetImage: j['asset_image'] as String?,
    borrowerName: j['borrower_name'] as String,
    reason: j['reason'] as String?,
    requestDate: _dt(j['request_date']),
    approvalDate: _dt(j['approval_date']),
    borrowDate: _dt(j['borrow_date']),
    returnDate: _dt(j['return_date']),
  );

  static DateTime? _dt(dynamic s) => (s == null || (s is String && s.isEmpty))
      ? null
      : DateTime.parse(s as String);
}

/* ---------- UI card ---------- */

class _HandCard extends StatelessWidget {
  const _HandCard({
    required this.item,
    required this.isHandOut,
    required this.onActionDone,
  });

  final HandItem item;
  final bool isHandOut;
  final VoidCallback onActionDone;

  static const Color _card = Color(0xFF3A3A3C);
  static const Color _imgBg = Color(0xFF2C2C2E);

  @override
  Widget build(BuildContext context) {
    final actionLabel = isHandOut ? 'Hand-out' : 'Hand-in';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูป
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 80,
              height: 80,
              color: _imgBg,
              child: item.assetImage != null && item.assetImage!.isNotEmpty
                  ? Image.asset(
                      'assets/images/${item.assetImage!}',
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, color: Colors.white24, size: 30),
            ),
          ),
          const SizedBox(width: 16),
          // ข้อมูล
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line('Item', item.assetName),
                _line('Borrower', item.borrowerName),
                if (item.requestDate != null)
                  _line('Request', _fmt(item.requestDate!)),
                if (item.returnDate != null)
                  _line('Return', _fmt(item.returnDate!)),
                if (item.reason != null && item.reason!.isNotEmpty)
                  _line('Objective', item.reason!),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => _doAction(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _line(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$k : ',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          TextSpan(
            text: v,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    ),
  );

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.year % 100}';

  Future<void> _doAction(BuildContext context) async {
    try {
      final userId = await AuthStorage.getUserId();
      if (userId == null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
        return;
      }

      final base = AppConfig.baseUrl;
      final endpoint = isHandOut
          ? '$base/staff/$userId/handout/${item.requestId}'
          : '$base/staff/$userId/handin/${item.requestId}';

      final url = Uri.parse(endpoint);
      final res = await http.post(url);

      if (res.statusCode == 200) {
        onActionDone();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isHandOut ? 'Hand-out สำเร็จ' : 'Hand-in สำเร็จ'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ${res.statusCode}: ${res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
