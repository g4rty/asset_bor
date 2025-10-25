import 'package:flutter/material.dart';
import 'student_home_page.dart'; // ✅ import กลับหน้า Dashboard

class StudentAssetsList extends StatefulWidget {
  const StudentAssetsList({super.key});

  @override
  State<StudentAssetsList> createState() => _StudentAssetsListState();
}

class _StudentAssetsListState extends State<StudentAssetsList> {
  final List<Map<String, dynamic>> assets = [
    {
      'name': 'Tennis Model AVC-23',
      'description':
          '24 lbs tension, light head, stiff shaft — fast and precise handling.',
      'status': 'Available',
    },
    {
      'name': 'Basketball',
      'description':
          '600 g weight, composite leather grip — durable indoors/outdoors.',
      'status': 'Disabled',
    },
    {
      'name': 'Football',
      'description':
          'Size 5, 0.8 bar pressure, 32 panel PU shell — precise flight.',
      'status': 'Borrowed',
    },
    {
      'name': 'Volleyball',
      'description':
          '260–280 g weight, microfiber PU cover — soft touch, indoor play.',
      'status': 'Disabled',
    },
  ];

  static const Color _scaffoldBgColor = Color(0xFF000000);
  static const Color _darkCardColor = Color(0xFF1C1C1E);
  static const Color _accentColor = Color(0xFFD4FF00);
  static const Color _lightTextColor = Color(0xFF8E8E93);

  int _selectedIndex = 2; // ✅ ตอนนี้อยู่ที่หน้า Assets (index 2)

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.greenAccent;
      case 'Borrowed':
        return Colors.lightBlueAccent;
      case 'Disabled':
        return Colors.grey;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, 'refresh'); // ส่งค่า signal กลับไป
          },
        ),
        title: const Text(
          'Asset List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _darkCardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${(index + 1).toString().padLeft(2, '0')} : ${asset['name']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        asset['description'],
                        style: const TextStyle(
                          color: _lightTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(asset['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    asset['status'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      color: _scaffoldBgColor,
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
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        // ✅ กลับไป Dashboard ถ้ากด Home
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentHomePage()),
          );
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
}
