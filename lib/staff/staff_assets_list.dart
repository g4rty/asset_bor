import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:asset_bor/staff/add_asset_page.dart';
import 'package:asset_bor/staff/edit_asset_page.dart';
import 'package:asset_bor/config.dart';
import 'package:asset_bor/shared/logout.dart';
import 'package:asset_bor/shared/navbar.dart';
import 'package:asset_bor/staff/staff_handin-out_page.dart';
import 'package:asset_bor/staff/staff_history_page.dart';
import 'package:asset_bor/staff/staff_home_page.dart';

class StaffAssetsList extends StatefulWidget {
  const StaffAssetsList({super.key});

  @override
  State<StaffAssetsList> createState() => _StaffAssetsListState();
}

class _StaffAssetsListState extends State<StaffAssetsList> {
  final Color _scaffoldBgColor = const Color.fromARGB(255, 39, 39, 39);
  static const int _selectedIndex = 1;

  late Future<List<dynamic>> _assetsFuture;

  Future<List<dynamic>> fetchAssets() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/assets'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data;
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load assets');
    }
  }

  @override
  void initState() {
    super.initState();
    _assetsFuture = fetchAssets();
  }

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
          'Asset List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: const [LogoutButton(iconColor: Colors.white)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<dynamic>>(
            future: _assetsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No assets found',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final assets = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Asset List',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
                                _assetsFuture = fetchAssets();
                              });
                            }
                          },
                          label: const Text('Add'),
                          icon: const Icon(Icons.create_new_folder_sharp),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 🔹 รายการทรัพย์สิน
                    Column(
                      children: List.generate(assets.length, (index) {
                        final asset = assets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildAssetCard(asset, index),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavTap),
    );
  }

  // 🔹 การ์ดแสดงข้อมูลแต่ละรายการ
  Widget _buildAssetCard(Map<String, dynamic> asset, int index) {
    final id = asset['asset_id']?.toString() ?? '-';
    final name = asset['asset_name'] ?? 'Unnamed';
    final status = asset['asset_status'] ?? 'Unknown';
    final desc = asset['description'] ?? '';
    final imageFile = asset['image'] ?? '';
    final isUploadFile = imageFile.contains('-'); // ไฟล์จาก upload

    // กำหนด imageUrl สำหรับส่งไป EditAssetPage
    final imageUrl = isUploadFile
        ? 'http://192.168.1.100:3000/uploads/$imageFile' // ไฟล์จาก upload
        : 'assets/images/$imageFile'; // ไฟล์จาก assets

    Color getStatusColor() {
      switch (status) {
        case 'Available':
          return const Color(0xFFD8FFA3);
        case 'Borrowed':
          return const Color.fromARGB(255, 111, 214, 255);
        case 'Disable':
          return Colors.grey;
        default:
          return Colors.white70;
      }
    }

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
          // 🔹 รูปภาพ
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black12,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imageFile.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
                    )
                  : isUploadFile
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.white70),
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.white70),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // 🔹 รายละเอียด + ปุ่ม
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔸 ชื่อ
                Text(
                  "$id : $name",
                  style: const TextStyle(
                    color: Color(0xFFD8FFA3),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // 🔸 คำอธิบาย
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),

                // 🔹 แถวปุ่ม status + edit
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 🔸 Status
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: getStatusColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 🔸 ปุ่ม Edit
                    SizedBox(
                      height: 36,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF69E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditAssetPage(
                                assetId: asset['asset_id'],
                                assetName: name,
                                description: desc,
                                status: status,
                                imageUrl: imageUrl,
                                quantity: asset['quantity'],
                              ),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              _assetsFuture = fetchAssets();
                            });
                          }
                        },
                        child: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.black),
                        ),
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
