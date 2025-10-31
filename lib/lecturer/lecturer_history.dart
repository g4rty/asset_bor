import 'dart:convert';

import '../auth_storage.dart';
import '../config.dart';
import '../login.dart';
import 'lecturer_asset_list.dart';
import 'lecturer_home_page.dart';
import 'lecturer_requested_item.dart';
import 'widgets/lecturer_nav_bar.dart';
import 'widgets/lecturer_logout.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LecturerHistory extends StatefulWidget {
  const LecturerHistory({super.key});

  @override
  State<LecturerHistory> createState() => LecturerHistoryState();
}

class LecturerHistoryState extends State<LecturerHistory> {
  late Future<List<Map<String, dynamic>>> futureHistory;

  @override
  void initState() {
    super.initState();
    futureHistory = loadHistory();
  }

  Future<List<Map<String, dynamic>>> loadHistory() async {
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

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/lecturers/$userId/history'),
    );
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final List raw = jsonDecode(response.body) as List;
    return raw
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();
  }

  Future<void> refreshHistory() async {
    final next = loadHistory();
    setState(() {
      futureHistory = next;
    });
    await next;
  }

  String formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    final date = DateTime.tryParse(value);
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
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month];
    final year = (date.year % 100).toString().padLeft(2, '0');
    return '$day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF1F1F1F);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
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
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFD4FF00),
          backgroundColor: background,
          onRefresh: refreshHistory,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: futureHistory,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4FF00)),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          refreshHistory();
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'No history',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24 + 84),
                itemCount: items.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Text(
                      'History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }

                  final entry = items[index - 1];
                  return buildHistoryCard(entry);
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: LecturerNavBar(
        index: 3,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LecturerHomePage()),
            );
          } else if (i == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LecturerAssetList()),
            );
          } else if (i == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LecturerRequestedItem()),
            );
          }
        },
      ),
    );
  }

  Widget buildHistoryCard(Map<String, dynamic> item) {
    final borrowPeriod =
        '${formatDate(item['borrow_date'] as String?)} - ${formatDate(item['return_date'] as String?)}';
    final actualReturn = formatDate(item['returned_date'] as String?);
    final loanOutBy = (item['approver_name'] as String?)?.trim();
    final assetImage = (item['asset_image'] as String?)?.trim();
    String? approvedDate = (item['approval_date'] as String?);
    String? rejectionReason= (item['rejection_reason'] as String?);
    String? requestStatus = item['decision_status'] as String?;
    final bannerStatus = '';
    Color bg;
    Color fg;
    String statusMsg;


    if(requestStatus == 'rejected' && rejectionReason != null){
      bg = const Color(0xFFED7575);
      fg = Colors.white;
      statusMsg = 'Rejected: $rejectionReason'; 
    }else{
      bg = Color(0xFFD9FFA3);
      fg = Color(0xFF396001);
      statusMsg = 'Approved';
    }

    Widget imageBox;
    if (assetImage == null || assetImage.isEmpty) {
      imageBox = const Icon(Icons.image, color: Colors.white24, size: 36);
    } else {
      imageBox = Image.asset(
        'assets/images/$assetImage',
        fit: BoxFit.cover,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 110,
              height: 110,
              color: const Color(0xFF2C2C2E),
              child: imageBox,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request ${item['request_id']} • Asset ${item['asset_id']}',
                  style: const TextStyle(
                    color: Color(0xFFD4FF00),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // const SizedBox(height: 6),
                Text(
                  item['asset_name'] as String? ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // const SizedBox(height: 6),
                Text(
                  'Borrower : ${item['borrower_name']}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                // const SizedBox(height: 4),
                Text(
                  'Borrow period : $borrowPeriod',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                // const SizedBox(height: 4),
                Text(
                  'Actual return : $actualReturn',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                // const SizedBox(height: 4),
                Text(
                  'Loan out by : ${loanOutBy == null || loanOutBy.isEmpty ? '-' : loanOutBy}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 6),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusMsg,
                      style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 14),
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
