import 'dart:io';
import 'package:flutter/material.dart';
import 'package:asset_bor/staff/add_asset_page.dart';
import 'package:asset_bor/staff/edit_asset_page.dart';
import 'package:asset_bor/staff/staff_handin-out_page.dart';
import 'package:asset_bor/staff/staff_history_page.dart';
import 'package:asset_bor/staff/staff_home_page.dart';
import 'package:asset_bor/shared/logout.dart';
import 'package:asset_bor/shared/navbar.dart';

class StaffAssetsList extends StatefulWidget {
  const StaffAssetsList({super.key});

  @override
  State<StaffAssetsList> createState() => _StaffAssetsListState();
}

class _StaffAssetsListState extends State<StaffAssetsList> {
  final int _selectedIndex = 1;
  final Color _scaffoldBgColor = const Color.fromARGB(255, 39, 39, 39);

  // รายการ assets ทั้งหมด
  final List<Map<String, dynamic>> _assets = [
    {
      'imageFile': null,
      'imageUrl':
          'https://static.vecteezy.com/system/resources/previews/001/844/211/non_2x/tennis-racket-design-illustration-isolated-on-white-background-free-vector.jpg',
      'name': '01 : Tennis Model AVC-23',
      'description':
          '24 lbs tension, light head, stiff shaft — fast and precise handling.',
      'status': 'Available',
    },
    {
      'imageFile': null,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGZNbQ9wHn8pyRwabz1tBIfpEJdaQfi0DPLw&s',
      'name': '02 : Basketball',
      'description':
          'Size 7, 600 g weight, composite leather grip — stable bounce and strong durability.',
      'status': 'Disabled',
    },
    {
      'imageFile': null,
      'imageUrl':
          'https://img.freepik.com/free-vector/soccer-ball-realistic-white-black-picture_1284-8506.jpg?semt=ais_hybrid&w=740&q=80',
      'name': '03 : Football',
      'description':
          'Size 5, 0.8 bar pressure, 32 panel PU shell — precise flight and consistent touch.',
      'status': 'Borrowed',
    },
    {
      'imageFile': null,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcpvSD8HmYBtoa_-hfQm9U2R-5EugTuMlypQ&s',
      'name': '04 : Volleyball',
      'description':
          'Size 5, 260–280 g weight, microfiber PU cover — soft touch and stable trajectory for indoor play.',
      'status': 'Disabled',
    },
  ];

  void handleNavTap(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StaffHomePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StaffHandPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StaffHistoryPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: _scaffoldBgColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Assets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          LogoutButton(iconColor: Colors.white),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header + Add Button
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

                        if (newAsset != null) {
                          setState(() {
                            _assets.add(newAsset);
                          });
                        }
                      },
                      label: const Text('Add'),
                      icon: const Icon(Icons.create_new_folder_sharp),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // แสดงรายการ asset
                Column(
                  children: List.generate(_assets.length, (index) {
                    final asset = _assets[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildAssetCard(asset: asset, index: index),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavTap),
    );
  }

  Widget _buildAssetCard({
    required Map<String, dynamic> asset,
    required int index,
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
          // รูปภาพ
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: asset['imageFile'] != null
                  ? DecorationImage(
                      image: FileImage(asset['imageFile']),
                      fit: BoxFit.cover,
                    )
                  : asset['imageUrl'] != null
                  ? DecorationImage(
                      image: NetworkImage(asset['imageUrl']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: asset['imageFile'] == null && asset['imageUrl'] == null
                ? const Icon(Icons.image_not_supported, color: Colors.white70)
                : null,
          ),
          const SizedBox(width: 16),
          // รายละเอียด
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset['name'],
                  style: const TextStyle(
                    color: Color(0xFFD8FFA3),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  asset['description'],
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: asset['status'] == 'Available'
                            ? const Color(0xFFD8FFA3)
                            : asset['status'] == 'Disabled'
                            ? Colors.grey
                            : const Color.fromARGB(255, 111, 214, 255),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        asset['status'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAssetPage(
                              assetName: asset['name'],
                              description: asset['description'],
                              status: asset['status'],
                              imageUrl: asset['imageFile'] ?? asset['imageUrl'],
                              index: index,
                            ),
                          ),
                        );

                        if (result != null) {
                          if (result['action'] == 'delete') {
                            setState(() {
                              _assets.removeAt(result['index']);
                            });
                          } else if (result['action'] == 'update') {
                            setState(() {
                              _assets[result['index']]['name'] = result['name'];
                              _assets[result['index']]['description'] =
                                  result['description'];
                              _assets[result['index']]['status'] =
                                  result['status'];
                              _assets[result['index']]['imageFile'] =
                                  result['imageFile'];
                            });
                          }
                        }
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
