import 'package:asset_bor/student/cancel_status_screen.dart';
import 'package:flutter/material.dart';
import 'student_home_page.dart';
import 'student_assets_list.dart';
import '../../auth_storage.dart';
import '../../login.dart';

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
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 3;

  void handleNavbar(int index) {
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

  Color _getStatusColor(String status) {
    if (status == 'Rejected') return const Color(0xFFEF5350);
    return const Color(0xFFD4FFAA);
  }

  String _getStatusText(String status, String returnDate) {
    if (status == 'Rejected') return 'Rejected: Under repair';
    return 'Returned: ${_formatReturnDate(returnDate)}';
  }

  String _formatReturnDate(String returnDate) {
    final dateParts = returnDate.split(' ');
    return '${dateParts[0]} ${dateParts[1]} ${dateParts[2]}';
  }

  bool _loggingOut = false;

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
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      await AuthStorage.clearUserId();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
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
            _loggingOut
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
      body: ListView.builder(
        itemCount: _borrowHistoryList.length,
        itemBuilder: (context, index) {
          final item = _borrowHistoryList[index];
          return _buildHistoryCard(item);
        },
      ),
      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavbar),
    );
  }

  Widget _buildHistoryCard(BorrowHistory item) {
    final bool isRejected = item.status == 'Rejected';

    // 🔸 กำหนดข้อความและสีตามสถานะ
    final String statusText = isRejected
        ? 'Rejected: Temporarily under repair'
        : 'Approved';

    final Color statusColor = isRejected
        ? const Color(0xFFEF5350)
        : const Color(0xFFD4FFAA);

    final Color textColor = isRejected ? Colors.white : Colors.black;

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
          // 🔸 รูปภาพ
          Container(
            width: 100,
            height: 100,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Image.asset(item.imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),

          // 🔸 รายละเอียด
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
                  'Approve By: ${item.objective}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 6),

                Text(
                  'Objective: ${item.objective}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 6),
                Text(
                  'Actual Return Date: ${item.actualReturnDate}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 12),

                // 🔸 สถานะ
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

  Widget _buildItemImage(String imagePath) {
    return Container(
      width: 120,
      height: 100,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Image.asset(imagePath, fit: BoxFit.contain),
    );
  }

  Widget _buildItemDetails(BorrowHistory item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${item.borrowId} ${item.item}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        _buildInfo('Approver', item.approver),
        _buildInfo('Borrow Date', item.borrowDate),
        _buildInfo('Return Date', item.returnDate),
        _buildInfo('Objective', item.objective),
        const SizedBox(height: 10),
        _buildStatus(item),
      ],
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _buildStatus(BorrowHistory item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(item.status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusText(item.status, item.returnDate),
        style: TextStyle(color: _getStatusTextColor(item.status), fontSize: 14),
      ),
    );
  }

  Color _getStatusTextColor(String status) {
    if (status == 'Rejected') return Colors.white;
    return Colors.black;
  }

  final List<BorrowHistory> _borrowHistoryList = [
    BorrowHistory(
      item: 'Tennis',
      borrowId: '01',
      approver: 'PupPub',
      borrowDate: '12 Aug 25',
      returnDate: '13 Aug 25',
      objective: 'Practice',
      status: 'approved',
      imagePath: 'assets/images/Tennis.png',
      actualReturnDate: '13 Aug 25',
    ),
    BorrowHistory(
      item: 'Basketball',
      borrowId: '02',
      approver: 'Pub',
      borrowDate: '12 Aug 25',
      returnDate: '13 Aug 25',
      objective: 'Practice',
      status: 'ejected',
      imagePath: 'assets/images/Basketball.png',
      actualReturnDate: '-',
    ),
    BorrowHistory(
      item: 'Football',
      borrowId: '03',
      approver: 'PupPubPub',
      borrowDate: '13 Aug 25',
      returnDate: '14 Aug 25',
      objective: 'Competition',
      status: 'approved',
      imagePath: 'assets/images/Football.png',
      actualReturnDate: '15 Aug 25',
    ),
  ];
}
