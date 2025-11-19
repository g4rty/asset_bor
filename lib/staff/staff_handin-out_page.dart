import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../auth_storage.dart';
import '../config.dart';
import '../login.dart';

import 'staff_assets_list.dart';
import 'staff_history_page.dart';
import 'staff_home_page.dart';
import 'package:asset_bor/shared/backend_image.dart';
import 'package:asset_bor/shared/logout.dart'; // ⭐ เพิ่ม import ปุ่ม logout
import 'package:asset_bor/shared/navbar.dart';

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

  void handleNavTap(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffHomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffAssetsList()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffHistoryPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),

      // ⭐ AppBar + ปุ่ม Logout
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Hand-in / Hand-out",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: const [LogoutButton(iconColor: Colors.white)],
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const SizedBox(height: 20),
            _buildTabBar(),
            const SizedBox(height: 14),
            Expanded(child: _buildTabBody()),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavTap),
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
  //                        API FETCH
  // ------------------------------------------------------------

  Future<List<HandItem>> _fetchHandOutQueue() async {
    final userId = await AuthStorage.getUserId();
    final url = Uri.parse("${AppConfig.baseUrl}/staff/$userId/handout-queue");

    final res = await http.get(
      url,
      headers: await AuthStorage.withSessionCookie(null),
    );
    final List data = jsonDecode(res.body);

    return data.map((e) => HandItem.fromJson(e)).toList();
  }

  Future<List<HandItem>> _fetchHandInQueue() async {
    final userId = await AuthStorage.getUserId();
    final url = Uri.parse("${AppConfig.baseUrl}/staff/$userId/handin-queue");

    final res = await http.get(
      url,
      headers: await AuthStorage.withSessionCookie(null),
    );
    final List data = jsonDecode(res.body);

    return data.map((e) => HandItem.fromJson(e)).toList();
  }
}

// ------------------------------------------------------------
//                        MODEL
// ------------------------------------------------------------

class HandItem {
  final int requestId;
  final int assetId; // ⭐ Asset ID
  final String assetName;
  final String borrowerName;
  final String? assetImage;
  final String? reason;

  HandItem({
    required this.requestId,
    required this.assetId,
    required this.assetName,
    required this.borrowerName,
    this.assetImage,
    this.reason,
  });

  factory HandItem.fromJson(Map<String, dynamic> j) {
    return HandItem(
      requestId: j["request_id"] as int,
      assetId: j["asset_id"] as int,
      assetName: j["asset_name"] as String,
      borrowerName: j["borrower_name"] as String,
      assetImage: j["asset_image"] as String?,
      reason: j["reason"] as String?,
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
              child: backendImageWidget(
                item.assetImage,
                fit: BoxFit.cover,
                placeholder: const Icon(
                  Icons.image,
                  color: Colors.white24,
                  size: 32,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // ---------------- TEXT INFO ----------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // หัว Request + Asset ID
                Text(
                  'Request ${item.requestId} • Asset ${item.assetId}',
                  style: const TextStyle(
                    color: Color(0xFFD8FFA3),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                _infoLine("Item", item.assetName),
                _infoLine("Borrower", item.borrowerName),
                if (item.reason != null)
                  _infoLine("Objective", item.reason ?? "-"),
              ],
            ),
          ),

          // ---------------- BUTTON ----------------
          TextButton(
            onPressed: () => _doAction(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
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
  //                   ACTION (DO HAND-IN / OUT) + POPUP
  // ------------------------------------------------------------

  Future<void> _doAction(BuildContext context) async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      // ถ้าไม่มี user ให้เด้งกลับหน้า login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return;
    }

    final base = AppConfig.baseUrl;
    final actionLabel = isHandOut ? "Hand-out" : "Hand-in";

    // ⭐⭐ Popup สไตล์ dark + ภาษาอังกฤษ ⭐⭐
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF2C2C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Confirm Action",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to $actionLabel this item?",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD8FFA3),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // ถ้ากด Cancel หรือปิด dialog → ไม่ทำอะไรต่อ
    if (confirm != true) return;

    final endpoint = isHandOut
        ? "$base/staff/$userId/handout/${item.requestId}"
        : "$base/staff/$userId/handin/${item.requestId}";

    try {
      final res = await http.post(
        Uri.parse(endpoint),
        headers: await AuthStorage.withSessionCookie(null),
      );

      if (res.statusCode == 200) {
        onActionDone();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF4CAF50), // เขียว success
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  "$actionLabel success",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  "Error: ${res.body}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                "Error: $e",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
