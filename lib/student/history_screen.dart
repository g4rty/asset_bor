import 'package:asset_bor/student/cancel_status_screen.dart';
import 'package:flutter/material.dart';
import 'student_home_page.dart';
import 'student_assets_list.dart';
import '../../auth_storage.dart';
import '../../login.dart';
import '../config.dart';
import '../shared/logout.dart';

class BorrowHistory {
  final String item;
  final String borrowId;
  final String approver;
  final String borrowDate;
  final String returnDate;
  final String objective;
  final String status;
  final String imagePath;

  BorrowHistory({
    required this.item,
    required this.borrowId,
    required this.approver,
    required this.borrowDate,
    required this.returnDate,
    required this.objective,
    required this.status,
    required this.imagePath,
  });
}

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudentHomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudentAssetsList()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CancelStatusScreen()),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StudentHomePage()),
            );
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _borrowHistoryList.length,
        itemBuilder: (context, index) {
          final item = _borrowHistoryList[index];
          return _buildHistoryCard(item);
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 0),
            _buildNavItem(Icons.shopping_bag_outlined, 1),
            _buildNavItem(Icons.list_alt_outlined, 2),
            _buildNavItem(Icons.history, 3),
          ],
        ),
        actions: const [LogoutButton(iconColor: Colors.white)],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFFDBFF00) : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BorrowHistory item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: const Color(0xFF424242),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemImage(item.imagePath),
            const SizedBox(width: 16),
            Expanded(child: _buildItemDetails(item)),
          ],
        ),
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
      returnDate: '12 Aug 25',
      objective: 'Practice',
      status: 'Rejected',
      imagePath: 'assets/images/Tennis.png',
    ),
    BorrowHistory(
      item: 'Basketball',
      borrowId: '02',
      approver: 'Pub',
      borrowDate: '12 Aug 25',
      returnDate: '13 Aug 25',
      objective: 'Practice',
      status: 'Returned',
      imagePath: 'assets/images/Basketball.png',
    ),
    BorrowHistory(
      item: 'Football',
      borrowId: '03',
      approver: 'PupPubPub',
      borrowDate: '13 Aug 25',
      returnDate: '13 Aug 25',
      objective: 'Competition',
      status: 'Returned',
      imagePath: 'assets/images/Football.png',
    ),
  ];
}
