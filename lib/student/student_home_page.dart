import 'package:asset_bor/student/student_assets_list.dart';
import 'package:flutter/material.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _selectedIndex = 0;

  static const Color _scaffoldBgColor = Color(0xFF000000);
  static const Color _darkCardColor = Color(0xFF1C1C1E);
  static const Color _imageBgColor = Color(0xFF2C2C2E);
  static const Color _accentColor = Color(0xFFD4FF00);
  static const Color _ruleNumberBgColor = Color(0xFFE53935);
  static const Color _lightTextColor = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dash Borad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildRulesSection(),
              const SizedBox(height: 32),
              _buildAssetCard(
                imagePath: 'assets/images/Latte.png',
                title: 'TENNIS RACKET',
                subtitle: '24 lbs tension, light head, stiff shaft',
              ),
              const SizedBox(height: 16),
              _buildAssetCard(
                imagePath: 'assets/images/delete.png',
                title: 'TENNIS BALL',
                subtitle: '24 lbs tension, light head, stiff shaft',
              ),
              const SizedBox(height: 16),
              _buildAssetCard(
                imagePath: 'assets/images/delete.png',
                title: 'TENNIS BALL',
                subtitle: '24 lbs tension, light head, stiff shaft',
              ),
              const SizedBox(height: 16),
              _buildAssetCard(
                imagePath: 'assets/images/delete.png',
                title: 'TENNIS BALL',
                subtitle: '24 lbs tension, light head, stiff shaft',
              ),
            ],
          ),
        ),
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
      onTap: () async {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 1) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentAssetsList()),
          );

          // ✅ ถ้ากลับมาพร้อมสัญญาณ refresh
          if (result == 'refresh') {
            setState(() {
              _selectedIndex = 0;
            });
          }
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
          // ✅ รูปภาพ
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _imageBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),

          const SizedBox(width: 16),

          // ✅ ส่วนของข้อความและปุ่ม
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: _lightTextColor, fontSize: 12),
                ),

                // ✅ ดันปุ่มลงล่าง
                const SizedBox(height: 10),
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
        color: const Color(0xFF1C1C1E),
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
