import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asset_bor/student/cancel_status_screen.dart';
import 'package:flutter/material.dart';
import 'student_home_page.dart';
import 'student_assets_list.dart';
import '../../auth_storage.dart';
import '../../login.dart';
import '../config.dart';

class BorrowHistory {
  final String item;
  final String borrowId;
  final String approver;
  final String? receiver;
  final String borrowDate;
  final String returnDate;
  final String requestDate;
  final String objective;
  final String status;
  final String imagePath;
  final String? actualReturnDate;
  final String? rejectionReason;

  BorrowHistory({
    required this.item,
    required this.borrowId,
    required this.approver,
    required this.receiver,
    required this.borrowDate,
    required this.requestDate,
    required this.returnDate,
    required this.objective,
    required this.status,
    required this.imagePath,
    this.actualReturnDate,
    this.rejectionReason,
  });

  factory BorrowHistory.fromJson(Map<String, dynamic> j) {
    return BorrowHistory(
      item: j['asset_name'] ?? '-',
      borrowId: j['request_id'].toString(),
      approver: j['approver_name'] ?? '-',
      receiver: j['receiver_name'] ?? '-',
      requestDate: j['request_date'] ?? '-',
      borrowDate: j['borrow_date'] ?? '-',
      returnDate: j['return_date'] ?? '-',
      actualReturnDate: j['returned_date'] ?? '-',
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
  bool _loggingOutNow = false;

  late Future<List<BorrowHistory>> _future;

  String _formatDateOnly(String dateTime) {
    if (dateTime == '-' || dateTime.isEmpty) return '-';

    try {
      final dt = DateTime.parse(dateTime).toLocal();
      return '${dt.day.toString().padLeft(2, '0')} ${_monthShort(dt.month)} ${dt.year % 100}';
    } catch (_) {
      return '-';
    }
  }

  String _formatTimeOnly(String dateTime) {
    if (dateTime == '-' || dateTime.isEmpty) return '';

    try {
      final dt = DateTime.parse(dateTime).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _monthShort(int m) {
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
    return months[m];
  }

  @override
  void initState() {
    super.initState();
    _future = _fetchHistory();
  }

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
    setState(() => _selectedIndex = index);

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
        break;
    }
  }

  Future<void> _confirmAndLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Color(0xFFB0B0B0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (ok == true) _logout();
  }

  Future<void> _logout() async {
    if (_loggingOutNow) return;
    setState(() => _loggingOutNow = true);
    await AuthStorage.clearUserId();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
    setState(() => _loggingOutNow = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1F1F1F),
        centerTitle: true,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'History',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            _loggingOutNow
                ? const CircularProgressIndicator(color: Colors.white)
                : IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _confirmAndLogout,
                  ),
          ],
        ),
      ),

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
            itemBuilder: (_, i) => _buildHistoryCard(history[i]),
          );
        },
      ),

      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavbar),
    );
  }

  Widget _buildHistoryCard(BorrowHistory item) {
    final bool isRejected = item.status == 'rejected';
    final bool isCancelled = item.status == 'cancelled';
    final bool isReturned = item.status == 'returned';

    Color statusColor;
    String statusText;
    Color textColor = Colors.black;

    if (isRejected) {
      statusColor = const Color(0xFFEF5350);
      statusText = 'Rejected: ${item.rejectionReason ?? '-'}';
      textColor = Colors.white;
    } else if (isCancelled) {
      statusColor = Colors.grey;
      statusText = 'Cancelled';
      textColor = Colors.white;
    } else if (isReturned) {
      statusColor = const Color(0xFFD4FFAA);
      statusText = 'Returned: ${item.actualReturnDate ?? '-'}';
      textColor = Colors.black;
    } else {
      statusColor = Colors.white24;
      statusText = item.status;
      textColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF434343),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 130,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Image.asset(item.imagePath, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),

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
                  'Date: ${_formatDateOnly(item.borrowDate)} · '
                  '${_formatTimeOnly(item.requestDate)} - '
                  '${_formatDateOnly(item.returnDate)} · '
                  '${_formatTimeOnly(item.requestDate)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),

                Text(
                  'Approve By: ${item.approver}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),

                Text(
                  'Return Received By: ${item.receiver}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),

                Text(
                  'Objective: ${item.objective}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),

                Text(
                  'Actual Return: ${item.actualReturnDate == '-' ? '-' : item.actualReturnDate}',
                  style: const TextStyle(color: Colors.white70),
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
