import 'package:asset_bor/student/cancel_status_screen.dart';
import 'package:asset_bor/student/history_screen.dart';
import 'package:asset_bor/student/student_assets_list.dart';
import 'package:flutter/material.dart';

import '../../auth_storage.dart';
import '../../login.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _selectedIndex = 0;
  bool _loggingOut = false;

  static const Color _scaffoldBgColor = Color(0xFF000000);
  static const Color _darkCardColor = Color.fromARGB(255, 29, 29, 31);
  static const Color _accentColor = Color(0xFFD4FF00);
  static const Color _lightTextColor = Color.fromARGB(255, 224, 224, 224);

  void handleNavbar(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StudentAssetsList()),
        );
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
              backgroundColor: Color.fromARGB(255, 210, 245, 160),
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
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
                                size: 28,
                              ),
                              onPressed: _confirmAndLogout,
                            ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildRulesSection(),
                  const SizedBox(height: 32),
                  _buildAssetCard(
                    imagePath: 'assets/images/Tennis.png',
                    title: '01 : TENNIS RACKET',
                    subtitle: '24 lbs tension, light head, stiff shaft',
                  ),
                  const SizedBox(height: 16),
                  _buildAssetCard(
                    imagePath: 'assets/images/Basketball.png',
                    title: '02 : BASKETBALL',
                    subtitle: '600 g weight, composite leather cover',
                  ),
                  const SizedBox(height: 16),
                  _buildAssetCard(
                    imagePath: 'assets/images/Football.png',
                    title: '03 : FOOTBALL',
                    subtitle: 'Size 5, 0.8 bar pressure, 32-panel PU shell',
                  ),
                  const SizedBox(height: 16),
                  _buildAssetCard(
                    imagePath: 'assets/images/Volleyball.png',
                    title: '04 : VOLLEYBALL',
                    subtitle: 'Official size, microfiber surface',
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavbar),
    );
  }

  Widget _buildRulesSection() {
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: const [
        SizedBox(
          width: 130,
          child: _RuleCard(
            number: '01',
            title: 'FIRST',
            description: 'One asset per day\nStudents can borrow only',
          ),
        ),
        SizedBox(
          width: 130,
          child: _RuleCard(
            number: '02',
            title: 'AVAILABLE',
            description: 'Only borrow items marked "Available"',
          ),
        ),
        SizedBox(
          width: 130,
          child: _RuleCard(
            number: '03',
            title: 'VALID',
            description: 'Borrowing must start today or later.',
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCard({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: _lightTextColor, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _buildAvailableChip(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _accentColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Available',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const Color _bg = Colors.black;
  static const Color _active = Color.fromARGB(255, 210, 245, 160);
  static const Color _inactive = Colors.white;

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home,
      Icons.shopping_bag_outlined,
      Icons.list_alt_outlined,
      Icons.history,
    ];
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: 72 + bottomInset,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottomInset > 0 ? bottomInset * 0.4 : 12,
      ),
      color: _bg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (i) {
          final selected = i == index;
          return InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? _active : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icons[i],
                size: 24,
                color: selected ? Colors.black : _inactive,
              ),
            ),
          );
        }),
      ),
    );
  }
}
