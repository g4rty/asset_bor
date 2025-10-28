import 'package:flutter/material.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _selectedIndex = 0;
  final Color _scaffoldBgColor = const Color.fromARGB(255, 39, 39, 39);
  final Color _accentColor = const Color(0xFFD8FFA3);

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

        // ✅ เมื่อกด icon แต่ละอัน จะไปหน้าอื่น
        // if (index == 1) {
        //   await Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => const StudentAssetsList()),
        //   );
        // } else if (index == 2) {
        //   await Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => const RequestsPage()),
        //   );
        // } else if (index == 3) {
        //   await Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => const HistoryPage()),
        //   );
        // }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🔹 Header
                Row(
                  children: [
                    const Text(
                      'Asset List',
                      style: TextStyle(color: Colors.white, fontSize: 36),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () {},
                      label: const Text('Add'),
                      icon: const Icon(Icons.create_new_folder_sharp),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 🔹 Asset Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF424242),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📦 รูปภาพ
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 📄 รายละเอียด Tennis
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '01 : Tennis Model AVC-23',
                              style: TextStyle(
                                color: Color(0xFFD8FFA3),
                                fontSize: 18,
                                fontFamily: 'IBM Plex Sans Thai',
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const Text(
                              'Description: 24 lbs tension, light head, stiff shaft — fast and precise handling.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'IBM Plex Sans Thai',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 🔘 ปุ่มสถานะ + ปุ่มแก้ไข
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Available Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD8FFA3),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Available',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 🟡 ปุ่ม Edit (แท้)
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFFFFF69E,
                                    ), // สีเหลือง
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 🔹 Asset Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF424242),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📦 รูปภาพ
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 📄 รายละเอียด
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '02 : Basketball',
                              style: TextStyle(
                                color: Color(0xFFD8FFA3),
                                fontSize: 18,
                                fontFamily: 'IBM Plex Sans Thai',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'Size 7, 600 g weight, composite leather grip — stable bounce and strong durability indoor/outdoor.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'IBM Plex Sans Thai',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 🔘 ปุ่มสถานะ + ปุ่มแก้ไข
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Available Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      185,
                                      185,
                                      185,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Disabled',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 🟡 ปุ่ม Edit (แท้)
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFFFFF69E,
                                    ), // สีเหลือง
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 🔹 Asset Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF424242),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📦 รูปภาพ
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 📄 รายละเอียด
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '03 : Football',
                              style: TextStyle(
                                color: Color(0xFFD8FFA3),
                                fontSize: 18,
                                fontFamily: 'IBM Plex Sans Thai',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'Size 5, 0.8 bar pressure, 32 panel PU shell — precise flight and consistent touch.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'IBM Plex Sans Thai',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 🔘 ปุ่มสถานะ + ปุ่มแก้ไข
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Available Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      129,
                                      230,
                                      255,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Borrowed',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 🟡 ปุ่ม Edit (แท้)
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFFFFF69E,
                                    ), // สีเหลือง
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 🔹 Asset Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF424242),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📦 รูปภาพ
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 📄 รายละเอียด
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '04 : Volleyball',
                              style: TextStyle(
                                color: Color(0xFFD8FFA3),
                                fontSize: 18,
                                fontFamily: 'IBM Plex Sans Thai',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'Size 5, 260–280 g weight, microfiber PU cover — soft touch and stable trajectory for indoor play.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'IBM Plex Sans Thai',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 🔘 ปุ่มสถานะ + ปุ่มแก้ไข
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Available Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      185,
                                      185,
                                      185,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Disabled',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 🟡 ปุ่ม Edit (แท้)
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFFFFF69E,
                                    ), // สีเหลือง
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
