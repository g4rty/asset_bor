import 'dart:convert';

import '../auth_storage.dart';
import '../config.dart';
import '../login.dart';
import 'lecturer_asset_list.dart';
import 'lecturer_home_page.dart';
import 'lecturer_requested_item.dart';
import 'widgets/lecturer_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/lecturer_logout.dart';

class LecturerHistory extends StatefulWidget {
  const LecturerHistory({super.key});

  @override
  State<LecturerHistory> createState() => _LecturerHistoryState();
}

class _LecturerHistoryState extends State<LecturerHistory> {
  late Future<List<HistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Assets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: const [
          LecturerLogoutButton(iconColor: Colors.white),
        ],
      ),
      body: SafeArea(child: _buildBody()),
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

  Widget _buildBody() {
    return FutureBuilder<List<HistoryItem>>(
      future: _future,
      builder: (context, s) {
        if (s.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4FF00)),
          );
        }
        if (s.hasError) {
          return Center(
            child: Text(
              'Error: ${s.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        final rows = s.data!;
        if (rows.isEmpty) {
          return const Center(
            child: Text(
              'No history',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24 + 84),
          itemCount: rows.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, i) {
            if (i == 0) {
              return const Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return _HistoryCard(item: rows[i - 1]);
          },
        );
      },
    );
  }

  Future<List<HistoryItem>> _fetchHistory() async {
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

    final url = Uri.parse(
      '${AppConfig.baseUrl}/lecturers/$userId/history',
    );
    final r = await http.get(url);
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
    final List data = jsonDecode(r.body) as List;
    return data
        .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/* ---------- Data model ---------- */

class HistoryItem {
  final int requestId;
  final String decisionStatus; // 'approved' | 'rejected'
  final String? rejectionReason;
  final String assetName;
  final String? assetImage;
  final String borrowerName;
  final DateTime? approvalDate, borrowDate, returnDate, returnedDate;

  HistoryItem({
    required this.requestId,
    required this.decisionStatus,
    required this.assetName,
    required this.borrowerName,
    this.rejectionReason,
    this.assetImage,
    this.approvalDate,
    this.borrowDate,
    this.returnDate,
    this.returnedDate,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
    requestId: j['request_id'] as int,
    decisionStatus: j['decision_status'] as String,
    rejectionReason: j['rejection_reason'] as String?,
    assetName: j['asset_name'] as String,
    assetImage: j['asset_image'] as String?,
    borrowerName: j['borrower_name'] as String,
    approvalDate: _dt(j['approval_date']),
    borrowDate: _dt(j['borrow_date']),
    returnDate: _dt(j['return_date']),
    returnedDate: _dt(j['returned_date']),
  );

  static DateTime? _dt(dynamic s) => (s == null || (s is String && s.isEmpty))
      ? null
      : DateTime.parse(s as String);
}

/* ---------- UI card ---------- */

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});
  final HistoryItem item;

  static const Color _card = Color(0xFF3A3A3C);
  static const Color _imgBg = Color(0xFF2C2C2E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 96,
              height: 96,
              color: _imgBg,
              child: item.assetImage != null && item.assetImage!.isNotEmpty
                  ? Image.asset(
                      'assets/images/${item.assetImage!}',
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, color: Colors.white24, size: 36),
            ),
          ),

          const SizedBox(width: 16),
          // details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line('Item', item.assetName),
                _line('Borrower', item.borrowerName),
                _line('Date', _range(item.borrowDate, item.returnDate)),
                _line('Handout by', item.approvalDate != null ? 'Staff' : '-'),
                _line(
                  'Returned by',
                  item.returnedDate != null ? item.borrowerName : '-',
                ),
                _line(
                  'Objective',
                  'Practice',
                ), // replace with real reason if exposed
                const SizedBox(height: 12),
                _statusChip(item),
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
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          TextSpan(
            text: v,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    ),
  );

  static String _range(DateTime? a, DateTime? b) {
    String f(DateTime? d) => d == null
        ? '-'
        : '${d.day.toString().padLeft(2, '0')} ${_mon[d.month]} ${d.year % 100}';
    return '${f(a)} - ${f(b)}';
  }

  static const _mon = [
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

  static Widget _statusChip(HistoryItem x) {
    // Rejected → red with reason
    if (x.decisionStatus == 'rejected') {
      return _chip(
        const Color(0xFFF07A7A),
        'Rejected: ${x.rejectionReason ?? '-'}',
      );
    }
    // Approved and returned → green with date
    if (x.returnedDate != null) {
      final d =
          '${x.returnedDate!.day.toString().padLeft(2, '0')} '
          '${_mon[x.returnedDate!.month]} ${x.returnedDate!.year % 100}';
      return _chip(const Color(0xFFDFFFAE), 'Returned: $d');
    }
    // Approved but not returned → blue with borrower
    return _chip(const Color(0xFFAEE4FF), 'Borrowing: ${x.borrowerName}');
  }

  static Widget _chip(Color bg, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
    ),
  );
}
