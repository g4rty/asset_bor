import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../auth_storage.dart';
import '../config.dart';
import '../login.dart';

import 'staff_assets_list.dart';
import 'staff_handin-out_page.dart';
import 'staff_home_page.dart';
import 'package:asset_bor/shared/backend_image.dart';
import 'package:asset_bor/shared/logout.dart';
import 'package:asset_bor/shared/navbar.dart';

// ใช้สำหรับ filter ที่หน้า History
enum HistoryFilter { all, returned, rejected, pending, cancelled }

class StaffHistoryPage extends StatefulWidget {
  const StaffHistoryPage({super.key});

  @override
  State<StaffHistoryPage> createState() => _StaffHistoryPageState();
}

class _StaffHistoryPageState extends State<StaffHistoryPage> {
  late Future<List<HistoryItem>> _future;

  int _selectedIndex = 3; // index ของ NavBar (History)
  HistoryFilter _selectedFilter = HistoryFilter.all;

  @override
  void initState() {
    super.initState();
    _future = _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272727),

      appBar: AppBar(
        backgroundColor: const Color(0xFF272727),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: const [LogoutButton(iconColor: Colors.white)],
      ),

      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: _handleNavTap),
    );
  }

  void _handleNavTap(int index) {
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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffHandPage()),
      );
    }
  }

  // ----------------- Body + Filter -----------------

  Widget _buildBody() {
    return FutureBuilder<List<HistoryItem>>(
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
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final allRows = snapshot.data ?? [];
        if (allRows.isEmpty) {
          return const Center(
            child: Text('No history', style: TextStyle(color: Colors.white70)),
          );
        }

        final rows = _applyFilter(allRows);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildFilterBar(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24 + 84),
                itemCount: rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, i) => _HistoryCard(item: rows[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 8,
        children: [
          _filterChip('All', HistoryFilter.all),
          _filterChip('Returned', HistoryFilter.returned),
          _filterChip('Rejected', HistoryFilter.rejected),
          _filterChip('Pending', HistoryFilter.pending),
          _filterChip('Cancelled', HistoryFilter.cancelled),
        ],
      ),
    );
  }

  Widget _filterChip(String label, HistoryFilter value) {
    final selected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: const Color(0xFFD8FFA3),
      labelStyle: TextStyle(
        color: selected ? Colors.black : Colors.white,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: const Color(0xFF2C2C2E),
    );
  }

  // กรอง returned / rejected / pending / cancelled
  List<HistoryItem> _applyFilter(List<HistoryItem> all) {
    switch (_selectedFilter) {
      case HistoryFilter.all:
        return all.where((x) {
          final s = x.decisionStatus.toLowerCase();
          // รวมสถานะหลัก ๆ ที่หัวหน้าสนใจ
          return s == 'returned' ||
              s == 'rejected' ||
              s == 'pending' ||
              s == 'cancelled' ||
              s == 'canceled'; // กันสะกดได้สองแบบ
        }).toList();

      case HistoryFilter.returned:
        return all
            .where((x) => x.decisionStatus.toLowerCase() == 'returned')
            .toList();

      case HistoryFilter.rejected:
        return all
            .where((x) => x.decisionStatus.toLowerCase() == 'rejected')
            .toList();

      case HistoryFilter.pending:
        return all
            .where((x) => x.decisionStatus.toLowerCase() == 'pending')
            .toList();

      case HistoryFilter.cancelled:
        return all.where((x) {
          final s = x.decisionStatus.toLowerCase();
          return s == 'cancelled' || s == 'canceled';
        }).toList();
    }
  }

  // ----------------- Fetch history -----------------

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

    // ตอนนี้ใช้ history แบบ ALL (สำหรับ staff ดูรวม)
    final url = Uri.parse('${AppConfig.baseUrl}/staff/history/all');

    final r = await http.get(
      url,
      headers: await AuthStorage.withSessionCookie(null),
    );
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }

    final List data = jsonDecode(r.body) as List;
    final list = data
        .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();

    // ถ้าไม่ต้องการ timeout ใน history ก็ลบออก
    list.removeWhere((x) => x.decisionStatus.toLowerCase() == 'timeout');

    // backend ORDER BY br.id DESC อยู่แล้ว
    return list;
  }
}

/* ---------- Data model ---------- */

class HistoryItem {
  final int requestId;
  final int assetId;
  final String decisionStatus;
  final String? rejectionReason;
  final String assetName;
  final String? assetImage;
  final String borrowerName;

  final DateTime? approvalDate;
  final DateTime? borrowDate;
  final DateTime? returnDate;
  final DateTime? returnedDate;
  final DateTime? requestDate;

  // staff ที่เป็นคน hand-out
  final String? staffName;

  HistoryItem({
    required this.requestId,
    required this.assetId,
    required this.decisionStatus,
    required this.assetName,
    required this.borrowerName,
    this.rejectionReason,
    this.assetImage,
    this.approvalDate,
    this.borrowDate,
    this.returnDate,
    this.returnedDate,
    this.requestDate,
    this.staffName,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
    requestId: j['request_id'] as int,
    assetId: j['asset_id'] as int,
    decisionStatus: j['decision_status'] as String,
    rejectionReason: j['rejection_reason'] as String?,
    assetName: j['asset_name'] as String,
    assetImage: j['asset_image'] as String?,
    borrowerName: j['borrower_name'] as String,
    approvalDate: _dt(j['approval_date']),
    borrowDate: _dt(j['borrow_date']),
    returnDate: _dt(j['return_date']),
    returnedDate: _dt(j['returned_date']),
    requestDate: _dt(j['request_date']),
    staffName: j['staff_name'] as String?,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 96,
              height: 96,
              color: _imgBg,
              child: backendImageWidget(
                item.assetImage,
                fit: BoxFit.cover,
                placeholder: const Icon(
                  Icons.image,
                  color: Colors.white24,
                  size: 36,
                ),
                error: const Icon(Icons.broken_image, color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // หัว Request + Asset ID
                Text(
                  'Request ${item.requestId} • Asset ${item.assetId}',
                  style: const TextStyle(
                    color: Color(0xFF8DF18C),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                _line('Item', item.assetName),
                _line('Borrower', item.borrowerName),

                // แสดง staff ที่ hand-out ถ้ามี
                _line('Hand-out by', item.staffName ?? '-'),

                // แสดงช่วงวันที่ยืม/คืน
                _line('Date', _range(item.borrowDate, item.returnDate)),

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

  // แสดง returned / rejected / pending / cancelled
  static Widget _statusChip(HistoryItem x) {
    final status = x.decisionStatus.toLowerCase();

    if (status == 'rejected') {
      return _chip(
        const Color(0xFFF07A7A),
        'Rejected${x.rejectionReason != null ? ': ${x.rejectionReason}' : ''}',
      );
    }

    if (status == 'returned') {
      final d = x.returnedDate != null
          ? '${x.returnedDate!.day.toString().padLeft(2, '0')} '
                '${_mon[x.returnedDate!.month]} '
                '${x.returnedDate!.year % 100}'
          : '';
      return _chip(
        const Color(0xFFDFFFAE),
        d.isEmpty ? 'Returned' : 'Returned: $d',
      );
    }

    if (status == 'pending') {
      return _chip(const Color.fromARGB(255, 121, 186, 216), 'Pending');
    }

    if (status == 'cancelled' || status == 'canceled') {
      return _chip(
        const Color(0xFFFFE082), // เหลืองอ่อนสำหรับ cancelled
        'Cancelled',
      );
    }

    return _chip(Colors.white30, status);
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
