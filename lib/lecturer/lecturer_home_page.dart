import '../auth_storage.dart';
import 'lecturer_asset_list.dart';
import 'lecturer_history.dart';
import 'lecturer_requested_item.dart';
import 'widgets/lecturer_nav_bar.dart';
import 'package:flutter/material.dart';

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage({super.key});

  @override
  State<LecturerHomePage> createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  @override
  void initState() {
    super.initState();
    _ensureUser();
  }

  Future<void> _ensureUser() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null && mounted) {
      await AuthStorage.clearUserId();
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _handleNavTap(int i) {
    if (i == 0) return; // already on Home
    if (i == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LecturerAssetList()),
      );
    } else if (i == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LecturerRequestedItem()),
      );
    } else if (i == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LecturerHistory()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: const SafeArea(
        child: Center(
          child: Text(
            'Lecturer Home',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: LecturerNavBar(index: 0, onTap: _handleNavTap),
    );
  }
}
