import 'student_home_page.dart';
import 'student_assets_list.dart';
import 'history_screen.dart';
import 'package:flutter/material.dart';

import '../../auth_storage.dart';
import '../../login.dart';

class CancelStatusScreen extends StatefulWidget {
  const CancelStatusScreen({super.key});

  @override
  _CancelStatusScreenState createState() => _CancelStatusScreenState();
}

class _CancelStatusScreenState extends State<CancelStatusScreen> {
  int _selectedIndex = 2;
  bool _loggingOut = false;

  void _showCancelDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF333333),
          title: const Text(
            'Are you sure to Cancel your asset?',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: const Text(
            'This action can\'t be undone',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4FFAA),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0A6A6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

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
        // อยู่หน้าปัจจุบัน
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HistoryScreen()),
        );
        break;
    }
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
      backgroundColor: Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: Color(0xFF1F1F1F),
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
              'Checking Status',
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: const Color(0xFF434343),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 25,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ ปุ่ม Pending ด้านบน
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E683),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ รูปภาพ
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/Tennis.png',
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ ข้อมูล
                const Text(
                  '01 : Tennis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Borrow date: 12 Aug 25',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Objective: Practice',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),

                const SizedBox(height: 12),

                // ✅ ปุ่ม Cancel ด้านล่าง
                Center(
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: _showCancelDialog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: const Color(0xFFF0A6A6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavbar),
    );
  }
}
