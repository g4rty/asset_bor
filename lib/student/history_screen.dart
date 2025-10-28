import 'package:asset_bor/student/cancel_status_screen.dart';
import 'package:flutter/material.dart';
import 'student_home_page.dart';
import 'student_assets_list.dart';

class BorrowHistory {
  final String item;
  final String borrowId;
  final String approver;
  final String borrowDate;
  final String returnDate;
  final String objective;
  final String status;

  BorrowHistory({
    required this.item,
    required this.borrowId,
    required this.approver,
    required this.borrowDate,
    required this.returnDate,
    required this.objective,
    required this.status,
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
    } else if (index == 3) {
      // อยู่หน้า History อยู่แล้ว ไม่ต้องทำอะไร
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'Rejected') {
      return const Color(0xFFEF5350);
    }
    return const Color(0xFF66BB6A);
  }

  String _getStatusText(String status, String returnDate) {
    if (status == 'Rejected') {
      return 'Rejected: Under repair';
    }
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
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      color: const Color(0xFF2C2C2C),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            _buildItemIcon(),
            const SizedBox(width: 20),
            _buildItemDetails(item),
          ],
        ),
      ),
    );
  }

  Widget _buildItemIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(Icons.sports, color: Colors.white, size: 60),
      ),
    );
  }

  Widget _buildItemDetails(BorrowHistory item) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText('Item: ${item.item}', const Color(0xFF7FFF00), 16),
          _buildText('Borrow ID: ${item.borrowId}', Colors.white70, 14),
          _buildText('Approver: ${item.approver}', Colors.white70, 14),
          _buildText('Borrow Date: ${item.borrowDate}', Colors.white70, 14),
          _buildText('Return Date: ${item.returnDate}', Colors.white70, 14),
          _buildText('Objective: ${item.objective}', Colors.white70, 14),
          _buildStatus(item),
        ],
      ),
    );
  }

  Widget _buildText(String text, Color color, double fontSize) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: fontSize),
    );
  }

  Widget _buildStatus(BorrowHistory item) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _getStatusColor(item.status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getStatusText(item.status, item.returnDate),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  final List<BorrowHistory> _borrowHistoryList = [
    BorrowHistory(
      item: 'Basketball',
      borrowId: '02',
      approver: 'Pub',
      borrowDate: '12 Aug 25',
      returnDate: '13 Aug 25',
      objective: 'Practice',
      status: 'Returned',
    ),
    BorrowHistory(
      item: 'Tennis',
      borrowId: '01',
      approver: 'PupPub',
      borrowDate: '12 Aug 25',
      returnDate: '12 Aug 25',
      objective: 'Practice',
      status: 'Rejected',
    ),
    BorrowHistory(
      item: 'Football',
      borrowId: '03',
      approver: 'PupPubPub',
      borrowDate: '13 Aug 25',
      returnDate: '13 Aug 25',
      objective: 'Competition',
      status: 'Returned',
    ),
  ];
}
