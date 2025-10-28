import 'package:asset_bor/student/cancel_status_screen.dart';
import 'package:flutter/material.dart';
import 'student_home_page.dart';
import 'student_request_form.dart';
import 'package:asset_bor/student/history_screen.dart';

class StudentAssetsList extends StatefulWidget {
  const StudentAssetsList({super.key});

  @override
  State<StudentAssetsList> createState() => _StudentAssetsListState();
}

class _StudentAssetsListState extends State<StudentAssetsList> {
  final List<Map<String, dynamic>> assets = [
    {
      'name': 'Tennis Model ABC-123',
      'description':
          '24 lbs tension, light head, stiff shaft — precise handling.',
      'status': 'Available',
      'image': 'assets/images/login_dino.png',
    },
    {
      'name': 'Basketball',
      'description':
          '600 g weight, composite leather grip — durable indoor/outdoor.',
      'status': 'Disabled',
      'image': 'assets/images/basketball.png',
    },
    {
      'name': 'Football',
      'description':
          'Size 5, 0.8 bar pressure, 32 panel PU shell — precise flight.',
      'status': 'Borrowed',
      'image': 'assets/images/football.png',
    },
  ];

  static const Color _scaffoldBgColor = Color(0xFF000000);
  static const Color _darkCardColor = Color(0xFF1C1C1E);
  static const Color _accentColor = Color(0xFFD4FF00);
  static const Color _lightTextColor = Color(0xFF8E8E93);

  int _selectedIndex = 1;
  int? _tappedIndex;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return const Color(0xFFD4FFAA);
      case 'Borrowed':
        return const Color(0xFF6ED0FF);
      case 'Disabled':
        return const Color(0xFFB0B0B0);
      default:
        return Colors.grey;
    }
  }

  Widget _buildAvailableChip(Map<String, dynamic> asset) {
    return GestureDetector(
      onTap: () {
        if (asset['status'] == 'Available') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentRequestForm(asset: asset),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(asset['status']),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          asset['status'],
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
            Navigator.pop(context, 'restio');
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
          return GestureDetector(
            onTapDown: (_) => setState(() => _tappedIndex = index),
            onTapUp: (_) => setState(() => _tappedIndex = null),
            onTapCancel: () => setState(() => _tappedIndex = null),
            child: AnimatedScale(
              scale: _tappedIndex == index ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _darkCardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(14),
                        image: asset['image'] != null
                            ? DecorationImage(
                                image: AssetImage(asset['image']),
                                fit: BoxFit.cover,
                              )
                            : null,
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
                              color: _accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Description: ${asset['description']}",
                            style: const TextStyle(
                              color: _lightTextColor,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: _buildAvailableChip(asset),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentHomePage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CancelStatusScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HistoryScreen()),
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
