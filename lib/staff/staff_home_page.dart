import 'package:flutter/material.dart';
import 'package:asset_bor/staff/staff_assets_list.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _selectedIndex = 0; // ตำแหน่ง Nav ปัจจุบัน (Dashboard)
  final Color _scaffoldBgColor = const Color.fromARGB(255, 39, 39, 39);
  final Color _accentColor = const Color(0xFFD8FFA3);

  // 🔹 Bottom Navigation Bar
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
        setState(() => _selectedIndex = index);
        if (index == 1) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffAssetsList()),
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

  // 🔹 Widget แสดงกราฟแท่ง
  Widget _buildBarChart() {
    final barHeights = [120.0, 80.0, 60.0, 100.0];
    final barColors = [
      const Color(0xFFB9FF9A),
      const Color(0xFF9FD7FF),
      const Color(0xFFAAAAAA),
      const Color(0xFFFFF69E),
    ];
    final labels = ['Available', 'Borrowing', 'Disabled', 'Pending'];

    return SizedBox(
      height: 220,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(barHeights.length, (i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 28,
                height: barHeights[i],
                decoration: BoxDecoration(
                  color: barColors[i],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 60,
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // 🔹 กล่องข้อมูลสรุป
  Widget _buildCountBox(String label, int count) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 🔹 กราฟแท่ง
                _buildBarChart(),
                const SizedBox(height: 30),

                // 🔹 กล่องสรุปสถานะ (2x2)
                Center(
                  child: SizedBox(
                    width: 300, // กำหนดความกว้างทั้งหมดของกริด
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _buildCountBox('Available', 6),
                        _buildCountBox('Pending', 4),
                        _buildCountBox('Disable', 5),
                        _buildCountBox('Borrowed', 13),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
