import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asset_bor/student/cancel_status_screen.dart';
import 'package:flutter/material.dart';
import 'student_home_page.dart';
import 'student_assets_list.dart';
import '../../auth_storage.dart';
import '../../login.dart';
import '../config.dart'; // ✅ เพิ่ม import config สำหรับ baseUrl

class BorrowHistory {
  final String item;
  final String borrowId;
  final String approver;
  final String borrowDate;
  final String returnDate;
  final String objective;
  final String status;
  final String imagePath;
  final String? actualReturnDate;
  final String? rejectionReason;

  BorrowHistory({
    required this.item,
    required this.borrowId,
    required this.approver,
    required this.borrowDate,
    required this.returnDate,
    required this.objective,
    required this.status,
    required this.imagePath,
    this.actualReturnDate,
    this.rejectionReason,
  });

  // ✅ เพิ่ม fromJson เพื่อรับข้อมูลจาก backend
  factory BorrowHistory.fromJson(Map<String, dynamic> j) {
    String formatDate(String? d) {
      if (d == null || d.isEmpty) return '-';

      try {
        final dt = DateTime.parse(d); // รองรับทั้งแบบมีเวลาและไม่มีเวลา
        const months = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]} ${dt.year % 100}';
      } catch (e) {
        return '-';
      }
    }

    return BorrowHistory(
      item: j['asset_name'] ?? '-',
      borrowId: j['request_id'].toString(),
      approver: j['approver_name'] ?? '-',
      borrowDate: formatDate(j['borrow_date']),
      returnDate: formatDate(j['return_date']),
      actualReturnDate: formatDate(j['returned_date']),
      objective: j['objective'] ?? '-',
      status: j['decision_status'] ?? '-',
      rejectionReason: j['rejection_reason'],
      imagePath: j['asset_image'] != null && j['asset_image'].isNotEmpty
          ? 'assets/images/${j['asset_image']}'
          : 'assets/images/placeholder.png',
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 3;
  bool _loggingOut = false;

  late Future<List<BorrowHistory>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchHistory();
  }

  // ✅ ดึงข้อมูลจาก backend
  Future<List<BorrowHistory>> _fetchHistory() async {
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

    final url = Uri.parse('${AppConfig.baseUrl}/students/$userId/history');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => BorrowHistory.fromJson(e)).toList();
  }

  void handleNavbar(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentHomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentAssetsList()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CancelStatusScreen()),
        );
        break;
      case 3:
        // อยู่หน้าปัจจุบัน
        break;
    }
  }

  bool _loggingOutNow = false;

  Future<void> _confirmAndLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 15, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF424242)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 210, 245, 160),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    await _logout();
  }

  Future<void> _logout() async {
    if (_loggingOutNow) return;
    setState(() => _loggingOutNow = true);
    try {
      await AuthStorage.clearUserId();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _loggingOutNow = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StudentHomePage()),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            _loggingOutNow
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: _confirmAndLogout,
                  ),
          ],
        ),
      ),

      // ✅ ใช้ FutureBuilder ดึงข้อมูลจริงแทน mock data
      body: FutureBuilder<List<BorrowHistory>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4FF00)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return const Center(
              child: Text(
                'No borrowing history found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return _buildHistoryCard(history[index]);
            },
          );
        },
      ),

      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavbar),
    );
  }

  Widget _buildHistoryCard(BorrowHistory item) {
    final bool isRejected = item.status == 'rejected';
    final bool isApproved = item.status == 'approved';
    final bool isCancelled = item.status == 'cancelled';
    final bool isPending = item.status == 'pending';

    Color statusColor;
    String statusText;
    Color textColor = Colors.black;

    if (isRejected) {
      statusColor = const Color(0xFFEF5350);
      statusText = 'Rejected: ${item.rejectionReason ?? '-'}';
      textColor = Colors.white;
    } else if (isPending) {
      // ✅ เพิ่มเงื่อนไขนี้
      statusColor = Colors.yellowAccent;
      statusText = 'Pending';
    } else if (isApproved && item.actualReturnDate != '-') {
      statusColor = const Color(0xFFD4FFAA);
      statusText = 'Returned: ${item.actualReturnDate}';
    } else if (isCancelled) {
      statusColor = Colors.grey;
      statusText = 'Cancelled';
    } else {
      statusColor = const Color(0xFFAEE4FF);
      statusText = 'Borrowing';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF434343),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปภาพ
          Container(
            width: 100,
            height: 100,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Image.asset(item.imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),

          // รายละเอียด
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request ${item.borrowId} · Asset ${item.item}',
                  style: const TextStyle(
                    color: Color(0xFFD4FF00),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Date: ${item.borrowDate} – ${item.returnDate}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  'Approve By: ${item.approver}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  'Objective: ${item.objective}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  'Actual Return: ${item.actualReturnDate == '-' ? '-' : item.actualReturnDate}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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
}
