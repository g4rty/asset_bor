import 'package:asset_bor/student/cancel_status_screen.dart';
import 'package:flutter/material.dart';
import 'student_home_page.dart';
import 'student_request_form.dart';
import 'package:asset_bor/student/history_screen.dart';

import '../../auth_storage.dart';
import '../../login.dart';

class StudentAssetsList extends StatefulWidget {
  const StudentAssetsList({super.key});

  @override
  State<StudentAssetsList> createState() => _StudentAssetsListState();
}

class _StudentAssetsListState extends State<StudentAssetsList> {
  final List<Map<String, dynamic>> assets = [
    {
      'name': 'Tennis',
      'description':
          '24 lbs string tension, lightweight carbon frame — balanced for power and control.',
      'status': 'Available',
      'image': 'assets/images/Tennis.png',
    },
    {
      'name': 'Basketball',
      'description':
          '600 g weight, composite leather cover — superior grip for indoor and outdoor play.',
      'status': 'Disabled',
      'image': 'assets/images/Basketball.png',
    },
    {
      'name': 'Football',
      'description':
          'Official size, microfiber surface — soft touch and excellent flight stability.',
      'status': 'Borrowed',
      'image': 'assets/images/Football.png',
    },
  ];

  static const Color _scaffoldBgColor = Color(0xFF1F1F1F);
  static const Color _darkCardColor = Color(0xFF434343);
  static const Color _accentColor = Color(0xFFD4FF00);
  static const Color _lightTextColor = Color(0xFFD9D9D9);

  int _selectedIndex = 1;
  int? _tappedIndex;
  bool _loggingOut = false;

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
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Asset List',
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

      // ... ใน Widget build(BuildContext context) ...
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          // --- 1. สร้างตัวแปรเช็คสถานะ ---
          final bool isAvailable = asset['status'] == 'Available';

          return GestureDetector(
            // --- 2. ใส่เงื่อนไขการ tap ที่นี่ ---
            onTapDown: isAvailable
                ? (_) => setState(() => _tappedIndex = index)
                : null,
            onTapUp: isAvailable
                ? (_) => setState(() => _tappedIndex = null)
                : null,
            onTapCancel: isAvailable
                ? () => setState(() => _tappedIndex = null)
                : null,
            onTap: isAvailable
                ? () {
                    // --- 3. ย้าย Logic การกดมาไว้ที่นี่ ---
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentRequestForm(asset: asset),
                      ),
                    );
                  }
                : null, // --- ถ้าไม่ Available ก็กดไม่ได้ ---
            child: AnimatedScale(
              scale: _tappedIndex == index ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              // --- 4. เพิ่ม Opacity เพื่อทำให้ Card จางลง ---
              child: Opacity(
                opacity: isAvailable ? 1.0 : 0.6, // จางลง 40%
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
                        // ... (ส่วน Image เหมือนเดิม)
                        width: 100,
                        height: 100,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
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
                            // ... (ส่วน Text Title และ Description เหมือนเดิม)
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
                              // --- 5. เรียกใช้ function ใหม่ ---
                              child: _buildAvailableChip(asset),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      // ... (ส่วน BottomNavBar เหมือนเดิม)
      bottomNavigationBar: NavBar(
        index: _selectedIndex,
        onTap: (index) {
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
              // อยู่หน้าปัจจุบัน
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CancelStatusScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
