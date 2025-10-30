import 'dart:convert';

import 'package:asset_bor/auth_storage.dart';
import 'package:asset_bor/config.dart';
import 'package:asset_bor/lecturer/lecturer_asset_list.dart';
import 'package:asset_bor/lecturer/lecturer_home_page.dart';
import 'package:asset_bor/lecturer/lecturer_requested_item.dart';
import 'package:asset_bor/lecturer/widgets/lecturer_logout.dart';
import 'package:asset_bor/lecturer/widgets/lecturer_nav_bar.dart';
import 'package:asset_bor/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LecturerHistory extends StatefulWidget {
  const LecturerHistory({super.key});

  @override
  State<LecturerHistory> createState() => _LecturerHistoryState();
}

class _LecturerHistoryState extends State<LecturerHistory> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    ensureUser();
    loadHistory();
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

  Future<void> loadHistory() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final userId = await AuthStorage.getUserId();
      if (userId == null) {
        throw Exception('No user');
      }
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/lecturers/$userId/history'));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      final data = List<Map<String, dynamic>>.from(jsonDecode(response.body) as List);
      if (!mounted) return;
      setState(() {
        items = data;
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

  String formatDate(dynamic value) {
    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = value.isEmpty ? null : DateTime.tryParse(value);
    }
    if (date == null) return '-';
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month]} ${date.year % 100}';
  }

  String formatDateRange(dynamic start, dynamic end) {
    final startText = formatDate(start);
    final endText = formatDate(end);
    return '$startText - $endText';
  }

  Widget buildStatusChip(Map<String, dynamic> item) {
    final decision = (item['decision_status'] as String?) ?? '';
    final reason = ((item['rejection_reason'] as String?) ?? '').trim();
    final borrower = ((item['borrower_name'] as String?) ?? '').trim();
    final returnedDate = item['returned_date'];

    Color bg;
    String label;

    if (decision.toLowerCase() == 'rejected') {
      bg = const Color(0xFFF07A7A);
      label = 'Rejected: ${reason.isEmpty ? '-' : reason}';
    } else if (returnedDate != null && returnedDate.toString().isNotEmpty) {
      bg = const Color(0xFFDFFFAE);
      label = 'Returned: ${formatDate(returnedDate)}';
    } else {
      bg = const Color(0xFFAEE4FF);
      label = 'Borrowing: ${borrower.isEmpty ? '-' : borrower}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
    );
  }

  Widget buildHistoryCard(Map<String, dynamic> item) {
    final assetName = ((item['asset_name'] as String?) ?? '').trim();
    final borrower = ((item['borrower_name'] as String?) ?? '').trim();
    final assetImage = ((item['asset_image'] as String?) ?? '').trim();
    final approvalDate = item['approval_date'];
    final handoutBy = approvalDate != null && approvalDate.toString().isNotEmpty ? 'Staff' : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 96,
              height: 96,
              color: const Color(0xFF2C2C2E),
              child: (() {
                if (assetImage.isEmpty) {
                  return const Icon(Icons.image, color: Colors.white24, size: 36);
                }
                if (assetImage.startsWith('http')) {
                  return Image.network(assetImage, fit: BoxFit.cover);
                }
                return Image.asset('assets/images/$assetImage', fit: BoxFit.cover);
              }()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('Item : ${assetName.isEmpty ? '-' : assetName}',
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('Borrower : ${borrower.isEmpty ? '-' : borrower}',
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Date : ${formatDateRange(item['borrow_date'], item['return_date'])}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('Handout by : $handoutBy',
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Returned by : ${item['returned_date'] == null ? '-' : (borrower.isEmpty ? '-' : borrower)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('Objective : Practice',
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
                const SizedBox(height: 12),
                buildStatusChip(item),
              ],
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
              onPressed: loadHistory,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('No history', style: TextStyle(color: Colors.white70)),
      );
    }

    return RefreshIndicator(
      onRefresh: loadHistory,
      backgroundColor: const Color(0xFF1F1F1F),
      color: const Color(0xFFD4FF00),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 108),
        itemCount: items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Text(
              'History',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            );
          }
          final item = items[index - 1];
          return buildHistoryCard(item);
        },
      ),
    );
  }

  void handleNavTap(int index) {
    if (index == 3) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LecturerHomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LecturerAssetList()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LecturerRequestedItem()),
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
      bottomNavigationBar: LecturerNavBar(index: 3, onTap: handleNavTap),
    );
  }
}
