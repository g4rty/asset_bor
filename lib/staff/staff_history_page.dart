import 'package:asset_bor/staff/staff_assets_list.dart';
import 'package:asset_bor/staff/staff_handin-out_page.dart';
import 'package:flutter/material.dart';

class StaffHistoryPage extends StatefulWidget {
  const StaffHistoryPage({super.key});

  @override
  State<StaffHistoryPage> createState() => _StaffHistoryPageState();
}

class _StaffHistoryPageState extends State<StaffHistoryPage> {
  // ------------------- COLORS -------------------
  final Color scaffoldBgColor = const Color(0xFF1F1F1F);
  final Color cardBgColor = const Color(0xFF3A3A3A);
  final Color accentGreen = const Color(0xFFB8FF8A);
  final Color accentRed = const Color(0xFFFF8080);
  final Color _accentColor = const Color(0xFFD8FFA3);

  // ------------------- NAV STATE -------------------
  int _selectedIndex = 3; // หน้านี้คือ History

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,

      // ------------------- APP BAR -------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: scaffoldBgColor,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 16,
          title: const Text(
            'History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(16),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFBFBFBF),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),

      // ------------------- BODY -------------------
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          HistoryCard(
            cardBgColor: cardBgColor,
            thumbnail: Icons.sports_basketball,
            lines: const [
              '02 Basketball',
              'Borrower: Pub P.',
              'Objective : Practice',
              'Approver (Lecturer): Pub',
              'Date : 12 Aug 25 - 13 Aug 25',
              'Handout by: Staff B',
              'Returned To: Staff A',
            ],
            badgeText: 'Returned: 13 Aug 25',
            badgeColor: Color(0xFFB8FF8A),
            textColor: Colors.black,
          ),
          const SizedBox(height: 16),

          HistoryCard(
            cardBgColor: cardBgColor,
            thumbnail: Icons.sports_tennis,
            lines: const [
              '01 Tennis',
              'Borrower: PubPub P.',
              'Objective : Practice',
              'Approver (Lecturer): Pub',
              'Date : 12 Aug 25',
              'Handout by: Staff A',
              'Returned To: -',
            ],
            badgeText: 'Rejected: Under repair',
            badgeColor: Color(0xFFFF8080),
            textColor: Colors.white,
          ),
          const SizedBox(height: 16),

          HistoryCard(
            cardBgColor: cardBgColor,
            thumbnail: Icons.sports_soccer,
            lines: const [
              '03 Football',
              'Borrower: PubPubPub P.',
              'Objective : Practice',
              'Approver (Lecturer): Pub',
              'Date : 13 Aug 25 ',
              'Handout by: Staff A',
              'Returned To: - ',
            ],
            badgeText: 'Borrowed : PubPubPub',
            badgeColor: Color(0xFF54D7FF),
            textColor: Colors.black,
          ),
          const SizedBox(height: 80),
        ],
      ),

      // ------------------- NAVBAR -------------------
      bottomNavigationBar: SafeArea(top: false, child: _buildBottomNavBar()),
    );
  }

  // ------------------- BOTTOM NAV BAR -------------------
  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      color: scaffoldBgColor,
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

  // ------------------- EACH NAV ITEM -------------------
  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () async {
        setState(() => _selectedIndex = index);

        //✅ ตรงนี้คือจุดที่จะเปลี่ยนหน้าเวลาจิ้ม tab
        if (index == 0) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffHandPage()),
          );
        } else if (index == 1) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffAssetsList()),
          );
        } else if (index == 2) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffHandPage()),
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

// ------------------- HISTORY CARD -------------------
class HistoryCard extends StatelessWidget {
  final Color cardBgColor;
  final IconData thumbnail;
  final List<String> lines;
  final String badgeText;
  final Color badgeColor;
  final Color textColor;

  const HistoryCard({
    super.key,
    required this.cardBgColor,
    required this.thumbnail,
    required this.lines,
    required this.badgeText,
    required this.badgeColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final String title = lines.isNotEmpty ? lines.first : '';
    final List<String> detailLines = lines.length > 1
        ? lines.sublist(1)
        : const [];

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // จัดกลางแนวตั้ง
        children: [
          // ---- Thumbnail ----
          Container(
            width: 100, // ขยายกรอบรูป
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(16), // มนขึ้น
            ),
            alignment: Alignment.center,
            child: Icon(
              thumbnail,
              size: 45, // ขยายไอคอนในรูป
              color: Colors.black87,
            ),
          ),

          const SizedBox(width: 24), // ระยะห่างระหว่างรูปกับข้อความ
          // ---- Text Section ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center, // ข้อความอยู่ตรงกลางแนวตั้ง
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),

                // Detail lines
                for (final line in detailLines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      line,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),

                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
