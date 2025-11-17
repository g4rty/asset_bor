import 'package:asset_bor/staff/staff_assets_list.dart';
import 'package:asset_bor/staff/staff_history_page.dart';
import 'package:asset_bor/staff/staff_home_page.dart';
import 'package:flutter/material.dart';

class StaffHandPage extends StatefulWidget {
  const StaffHandPage({super.key});

  @override
  State<StaffHandPage> createState() => _StaffHandPageState();
}

class _StaffHandPageState extends State<StaffHandPage> {
  int _selectedIndex = 2;

  // สีธีมตามที่ให้มา
  final Color _scaffoldBgColor = const Color.fromARGB(255, 39, 39, 39); // #272727
  final Color _accentColor = const Color(0xFFD8FFA3); // สีเขียวอ่อนไฮไลต์ปุ่ม nav

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: _scaffoldBgColor,
        elevation: 0,
        title: const Text(
          "Hand out- Hand in",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: const [
            ItemCard(
              image: '',
              title: '02 Basketball',
              borrower: 'Kuroko',
              date: '12 Aug 25 - 13 Aug 25',
              approved: 'Lecturer',
              handout: '-',
              returned: '-',
              objective: 'Practice',
              initialHandedOut: false,
            ),
            SizedBox(height: 16),
            ItemCard(
              image: '',
              title: '01 Tennis',
              borrower: 'Yuki',
              date: '12 Aug 25 - 13 Aug 25',
              approved: 'Lecturer',
              handout: '-',
              returned: '-',
              objective: 'Practice',
              initialHandedOut: false,
            ),
            SizedBox(height: 16),
            ItemCard(
              image: '',
              title: '03 Football',
              borrower: 'Benjo',
              date: '13 Aug 25 - 14 Aug 25',
              approved: 'Lecturer',
              handout: 'Staff',
              returned: '-',
              objective: 'Competition',
              initialHandedOut: true,
            ),
            SizedBox(height: 24),
          ],
        ),
      ),

      // ใช้ bottom nav bar แบบ custom จากโค้ดแรก
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ===== Bottom Nav =====

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
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

        // ถ้าอยากให้กดแล้วไปหน้าอื่น ให้ uncomment ส่วนนี้แล้วใส่หน้าเอง
        
        if (index == 0) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffHomePage()),
          );
        } else if (index == 1) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffAssetsList()),
          );
        } else if (index == 3) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffHistoryPage()),
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

// ===== Card ยืมอุปกรณ์ =====

class ItemCard extends StatefulWidget {
  final String image;
  final String title;
  final String borrower;
  final String date;
  final String approved;
  final String handout;
  final String returned;
  final String objective;
  final bool initialHandedOut;

  const ItemCard({
    super.key,
    required this.image,
    required this.title,
    required this.borrower,
    required this.date,
    required this.approved,
    required this.handout,
    required this.returned,
    required this.objective,
    this.initialHandedOut = false,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  late bool isHandedOut;

  @override
  void initState() {
    super.initState();
    isHandedOut = widget.initialHandedOut;
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = isHandedOut ? 'Hand in' : 'Handout';
    final buttonColor =
        isHandedOut ? const Color(0xFF8CE8FF) : const Color(0xFFB8F28C);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // เนื้อหาหลัก
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // รูป / placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: widget.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          widget.image,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.image_outlined,
                        color: Colors.black38,
                        size: 36,
                      ),
              ),

              const SizedBox(width: 16),

              // ข้อมูล text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Borrower : ${widget.borrower}\n'
                      'Date: ${widget.date}\n'
                      'Approved by: ${widget.approved}\n'
                      'Handout by: ${widget.handout}\n'
                      'Returned by: ${widget.returned}\n'
                      'Objective: ${widget.objective}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ปุ่มมุมล่างขวา
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isHandedOut = !isHandedOut;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
