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

enum HandTab { handOut, handIn }

class _StaffHandPageState extends State<StaffHandPage> {
  HandTab _selectedTab = HandTab.handOut;

  late Future<List<HandItem>> _futureHandOut;
  late Future<List<HandItem>> _futureHandIn;

  int _selectedIndex = 2;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Hand-in / Hand-out",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTabBar(),
            const SizedBox(height: 14),
            Expanded(child: _buildTabBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ------------------------------------------------------------
  //                        TAB BAR
  // ------------------------------------------------------------

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _tabButton("Hand-out", HandTab.handOut),
          const SizedBox(width: 10),
          _tabButton("Hand-in", HandTab.handIn),
        ],
      ),
    );
  }

  Widget _tabButton(String label, HandTab tab) {
    bool selected = _selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _accentColor : const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  //                        TAB BODY
  // ------------------------------------------------------------

  Widget _buildTabBody() {
    return _selectedTab == HandTab.handOut
        ? FutureBuilder<List<HandItem>>(
            future: _futureHandOut,
            builder: _buildList("No items to hand-out", isHandOut: true),
          )
        : FutureBuilder<List<HandItem>>(
            future: _futureHandIn,
            builder: _buildList("No items to hand-in", isHandOut: false),
          );
  }

  Widget Function(BuildContext, AsyncSnapshot<List<HandItem>>) _buildList(
    String emptyText, {
    required bool isHandOut,
  }) {
    return (context, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFCCFF33)),
        );
      }

      if (snap.hasError) {
        return Center(
          child: Text(
            "Error: ${snap.error}",
            style: const TextStyle(color: Colors.redAccent),
          ),
        );
      }

      final items = snap.data ?? [];
      if (items.isEmpty) {
        return Center(
          child: Text(
            emptyText,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (c, i) => _HandCard(
          item: items[i],
          isHandOut: isHandOut,
          onActionDone: () => setState(() => _reloadAll()),
        ),
      );
    };
  }

  // ------------------------------------------------------------
  //                     BOTTOM NAVIGATION
  // ------------------------------------------------------------

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.shopping_bag_outlined, 1),
          _buildNavItem(Icons.list_alt_outlined, 2),
          _buildNavItem(Icons.history, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool selected = _selectedIndex == index;

    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StaffHomePage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StaffAssetsList()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StaffHistoryPage()),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? _accentColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: selected ? Colors.black : Colors.white),
      ),
    );
  }

  // ------------------------------------------------------------
  //                        API FETCH
  // ------------------------------------------------------------

  Future<List<HandItem>> _fetchHandOutQueue() async {
    final userId = await AuthStorage.getUserId();
    final url = Uri.parse("${AppConfig.baseUrl}/staff/$userId/handout-queue");

    final res = await http.get(url);
    final List data = jsonDecode(res.body);

    return data.map((e) => HandItem.fromJson(e)).toList();
  }

  Future<List<HandItem>> _fetchHandInQueue() async {
    final userId = await AuthStorage.getUserId();
    final url = Uri.parse("${AppConfig.baseUrl}/staff/$userId/handin-queue");

    final res = await http.get(url);
    final List data = jsonDecode(res.body);

    return data.map((e) => HandItem.fromJson(e)).toList();
  }
}

// ------------------------------------------------------------
//                        MODEL
// ------------------------------------------------------------

class HandItem {
  final int requestId;
  final String assetName;
  final String borrowerName;
  final String? assetImage;
  final String? reason;

  HandItem({
    required this.requestId,
    required this.assetName,
    required this.borrowerName,
    this.assetImage,
    this.reason,
  });

  factory HandItem.fromJson(Map<String, dynamic> j) {
    return HandItem(
      requestId: j["request_id"],
      assetName: j["asset_name"],
      borrowerName: j["borrower_name"],
      assetImage: j["asset_image"],
      reason: j["reason"],
    );
  }
}

// ------------------------------------------------------------
//                        CARD UI
// ------------------------------------------------------------

class _HandCard extends StatelessWidget {
  final HandItem item;
  final bool isHandOut;
  final VoidCallback onActionDone;

  const _HandCard({
    required this.item,
    required this.isHandOut,
    required this.onActionDone,
  });

  @override
  Widget build(BuildContext context) {
    final actionLabel = isHandOut ? "Hand-out" : "Hand-in";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF383838),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- IMAGE ----------------
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 90,
              height: 90,
              color: const Color(0xFF2C2C2E),
              child: item.assetImage != null
                  ? Image.asset(
                      "assets/images/${item.assetImage}",
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, color: Colors.white24, size: 32),
            ),
          ),

          const SizedBox(width: 14),

          // ---------------- TEXT INFO ----------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoLine("Item", item.assetName),
                _infoLine("Borrower", item.borrowerName),
                if (item.reason != null)
                  _infoLine("Objective", item.reason ?? "-"),
              ],
            ),
          ),

          // ---------------- BUTTON ----------------
          ElevatedButton(
            onPressed: () => _doAction(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$key : ",
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  //                   ACTION (DO HAND-IN / OUT)
  // ------------------------------------------------------------

  Future<void> _doAction(BuildContext context) async {
    final userId = await AuthStorage.getUserId();
    final base = AppConfig.baseUrl;

    final actionLabel = isHandOut ? "Hand-out" : "Hand-in";

    final endpoint = isHandOut
        ? "$base/staff/$userId/handout/${item.requestId}"
        : "$base/staff/$userId/handin/${item.requestId}";

    final res = await http.post(Uri.parse(endpoint));

    if (res.statusCode == 200) {
      onActionDone();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$actionLabel success")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${res.body}")));
    }
  }
}
  