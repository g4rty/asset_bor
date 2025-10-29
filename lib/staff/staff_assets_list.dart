import 'package:asset_bor/staff/staff_home_page.dart';
import 'package:asset_bor/staff/edit_asset_page.dart';
import 'package:asset_bor/staff/add_asset_page.dart';
import 'package:flutter/material.dart';

class StaffAssetsList extends StatefulWidget {
  const StaffAssetsList({super.key});

  @override
  State<StaffAssetsList> createState() => _StaffAssetsListState();
}

class _StaffAssetsListState extends State<StaffAssetsList> {
  int _selectedIndex = 1;
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

        if (index == 0) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffHomePage()),
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
                      onPressed: () async {
                        final newAsset = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddAssetPage(),
                          ),
                        );
                        // if (newAsset != null) {
                        //   // เพิ่ม asset ใหม่ลงใน list ของคุณ
                        //   // ตอนนี้คุณยังใช้ static list อยู่ ให้ลองเก็บใน state
                        //   setState(() {
                        //     // สมมติว่าคุณมี list assets จริง ๆ
                        //     // _assets.add(newAsset);
                        //     // สำหรับตัวอย่างนี้ เราอาจต้องเปลี่ยน _buildAssetCard ให้ใช้ list
                        //   });
                        // }
                      },
                      label: const Text('Add'),
                      icon: const Icon(Icons.create_new_folder_sharp),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 🔹 Tennis
                _buildAssetCard(
                  imageUrl:
                      'https://static.vecteezy.com/system/resources/previews/001/844/211/non_2x/tennis-racket-design-illustration-isolated-on-white-background-free-vector.jpg',
                  name: '01 : Tennis Model AVC-23',
                  description:
                      '24 lbs tension, light head, stiff shaft — fast and precise handling.',
                  status: 'Available',
                  statusColor: const Color(0xFFD8FFA3),
                ),
                const SizedBox(height: 20),

                // 🔹 Basketball
                _buildAssetCard(
                  imageUrl:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGZNbQ9wHn8pyRwabz1tBIfpEJdaQfi0DPLw&s',
                  name: '02 : Basketball',
                  description:
                      'Size 7, 600 g weight, composite leather grip — stable bounce and strong durability indoor/outdoor.',
                  status: 'Disabled',
                  statusColor: const Color.fromARGB(255, 185, 185, 185),
                ),
                const SizedBox(height: 20),

                // 🔹 Football
                _buildAssetCard(
                  imageUrl:
                      'https://img.freepik.com/free-vector/soccer-ball-realistic-white-black-picture_1284-8506.jpg?semt=ais_hybrid&w=740&q=80',
                  name: '03 : Football',
                  description:
                      'Size 5, 0.8 bar pressure, 32 panel PU shell — precise flight and consistent touch.',
                  status: 'Borrowed',
                  statusColor: const Color.fromARGB(255, 129, 230, 255),
                ),
                const SizedBox(height: 20),

                // 🔹 Volleyball
                _buildAssetCard(
                  imageUrl:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcpvSD8HmYBtoa_-hfQm9U2R-5EugTuMlypQ&s',
                  name: '04 : Volleyball',
                  description:
                      'Size 5, 260–280 g weight, microfiber PU cover — soft touch and stable trajectory for indoor play.',
                  status: 'Disabled',
                  statusColor: const Color.fromARGB(255, 185, 185, 185),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // 🔹 ฟังก์ชันสร้างการ์ด (ลดโค้ดซ้ำ)
  Widget _buildAssetCard({
    required String imageUrl,
    required String name,
    required String description,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูป
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // รายละเอียด
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFFD8FFA3),
                    fontSize: 18,
                    fontFamily: 'IBM Plex Sans Thai',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'IBM Plex Sans Thai',
                  ),
                ),
                const SizedBox(height: 12),

                // ปุ่ม
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // ปุ่ม Edit
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF69E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAssetPage(
                              assetName: name,
                              description: description,
                              status: status,
                              imageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
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
    );
  }
}
