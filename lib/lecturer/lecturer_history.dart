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
  bool _isLoading = true;
  String? _error;
  List<HistoryItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4FF00)),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => _loadHistory(), child: const Text('Try again')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text('No history', style: TextStyle(color: Colors.white70)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadHistory,
      backgroundColor: const Color(0xFF1F1F1F),
      color: const Color(0xFFD4FF00),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24 + 84),
        itemCount: _items.length + 1,
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
          return _HistoryCard(item: _items[i - 1]);
        },
      ),
    );
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final rows = await _fetchHistory();
      if (!mounted) return;
      setState(() {
        _items = rows;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _isLoading = false;
      });
    }
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
  final int? handoverById;
  final int? receiverId;
  final String? handoverByName;
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
    this.handoverById,
    this.receiverId,
    this.handoverByName,
    this.rejectionReason,
    this.assetImage,
    this.approvalDate,
    this.borrowDate,
    this.returnDate,
    this.returnedDate,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
    requestId: j['request_id'] as int,
    handoverById: _int(j['handover_by_id']),
    receiverId: _int(j['receiver_id']),
    handoverByName: j['handover_by_name'] as String?,
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

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
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
              width: 110,
              height: 110,
              color: _imgBg,
              child: _buildImage(),
            ),
          ),

          const SizedBox(width: 16),
          // details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request ${item.requestId} · Asset ${item.assetName}',
                  style: const TextStyle(
                    color: Color(0xFFD4FF00),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                _line('Borrower', item.borrowerName),
                _line('Date', _range(item.borrowDate, item.returnDate)),
                _line('Handout date', _fmtDate(item.approvalDate)),
                _line('Handed out by', item.handoverByName ?? '-'),
                if (item.returnedDate != null)
                  _line('Actual return', _fmtDate(item.returnedDate)),
                _line('Returned by', item.returnedDate != null ? item.borrowerName : '-'),
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

  Widget _buildImage() {
    final img = item.assetImage;
    if (img == null || img.isEmpty) {
      return const Icon(Icons.image, color: Colors.white24, size: 36);
    }
    if (img.startsWith('http')) {
      return Image.network(img, fit: BoxFit.cover);
    }
    return Image.asset('assets/images/$img', fit: BoxFit.cover);
  }

  static Widget _line(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$k : ',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              TextSpan(
                text: v,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      );

  static String _range(DateTime? a, DateTime? b) =>
      '${_fmtDate(a)} - ${_fmtDate(b)}';

  static String _fmtDate(DateTime? d) => d == null
      ? '-'
      : '${d.day.toString().padLeft(2, '0')} ${_mon[d.month]} ${d.year % 100}';

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
    if (x.returnedDate != null) {
      return _chip(const Color(0xFFDFFFAE), 'Returned: ${_fmtDate(x.returnedDate)}');
    }
    if (x.handoverById != null && x.receiverId != null) {
      return _chip(const Color(0xFFDFFFAE), 'Returned');
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
