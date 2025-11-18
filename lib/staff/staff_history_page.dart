import 'package:flutter/material.dart';
import 'dart:convert';

import '../auth_storage.dart';
import '../config.dart';
import '../login.dart';
import 'package:asset_bor/staff/staff_assets_list.dart';
import 'package:asset_bor/staff/staff_handin-out_page.dart';
import 'package:asset_bor/staff/staff_home_page.dart';
import 'package:http/http.dart' as http;

class StaffHistoryPage extends StatefulWidget {
  const StaffHistoryPage({super.key});

  @override
  State<StaffHistoryPage> createState() => _StaffHistoryPageState();
}

// ตัวเลือก filter
enum HistoryFilter { all, borrowing, returned, rejected }

class _StaffHistoryPageState extends State<StaffHistoryPage> {
  late Future<List<HistoryItem>> _future;

  int _selectedIndex = 3; // หน้า History
  final Color _accentColor = const Color(0xFFD8FFA3);

  HistoryFilter _selectedFilter = HistoryFilter.all;

  @override
  void initState() {
    super.initState();
    _future = _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _buildBottomNavBar(),
    );
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
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffHandPage()),
          );
        } else if (index == 3) {
          // อยู่หน้า History แล้ว
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

  // ----------------- Body + Filter tabs -----------------

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

        final allRows = s.data ?? [];
        if (allRows.isEmpty) {
          return const Center(
            child: Text('No history', style: TextStyle(color: Colors.white70)),
          );
        }

        final rows = _applyFilter(allRows);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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

  // แถบปุ่ม filter
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 8,
        children: [
          _filterChip('All', HistoryFilter.all),
          _filterChip('Borrowing', HistoryFilter.borrowing),
          _filterChip('Returned', HistoryFilter.returned),
          _filterChip('Rejected', HistoryFilter.rejected),
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

  // กรอง list ตาม filter
  List<HistoryItem> _applyFilter(List<HistoryItem> all) {
    switch (_selectedFilter) {
      case HistoryFilter.all:
        return all;
      case HistoryFilter.borrowing:
        return all
            .where(
              (x) => x.returnedDate == null && x.decisionStatus != 'rejected',
            )
            .toList();
      case HistoryFilter.returned:
        return all.where((x) => x.returnedDate != null).toList();
      case HistoryFilter.rejected:
        return all.where((x) => x.decisionStatus == 'rejected').toList();
    }
  }

  // ----------------- Fetch history (เรียงตามวันที่ยืม) -----------------

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

    // ดึงภาพรวมทุก staff ทุกสถานะ
    final url = Uri.parse('${AppConfig.baseUrl}/staff/history/all');

    final r = await http.get(url);
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }

    final List data = jsonDecode(r.body) as List;
    final list = data
        .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();

    // 🔥 เรียงตามวันที่ยืม (borrowDate ใหม่ → เก่า)
    list.sort(
      (a, b) =>
          (b.borrowDate ?? DateTime(0)).compareTo(a.borrowDate ?? DateTime(0)),
    );

    return list;
  }
}

/* ---------- Data model ---------- */

class HistoryItem {
  final int requestId;
  final String decisionStatus;
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
                _line('Objective', 'Practice'),
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
    if (x.decisionStatus == 'rejected') {
      return _chip(
        const Color(0xFFF07A7A),
        'Rejected: ${x.rejectionReason ?? '-'}',
      );
    }
    if (x.returnedDate != null) {
      final d =
          '${x.returnedDate!.day.toString().padLeft(2, '0')} '
          '${_mon[x.returnedDate!.month]} '
          '${x.returnedDate!.year % 100}';
      return _chip(const Color(0xFFDFFFAE), 'Returned: $d');
    }
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
