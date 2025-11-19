import 'dart:convert';
import 'package:asset_bor/config.dart';
import 'package:asset_bor/auth_storage.dart';
import 'package:asset_bor/shared/backend_image.dart';
import 'package:asset_bor/shared/logout.dart';
import 'package:asset_bor/shared/navbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:asset_bor/staff/add_asset_page.dart';
import 'package:asset_bor/staff/edit_asset_page.dart';
import 'package:asset_bor/staff/staff_handin-out_page.dart';
import 'package:asset_bor/staff/staff_history_page.dart';
import 'package:asset_bor/staff/staff_home_page.dart';

class StaffAssetsList extends StatefulWidget {
  const StaffAssetsList({super.key});

  @override
  State<StaffAssetsList> createState() => _StaffAssetsListState();
}

class _StaffAssetsListState extends State<StaffAssetsList> {
  int _selectedIndex = 1;
  final Color _scaffoldBgColor = const Color.fromARGB(255, 39, 39, 39);
  final Color _accentColor = const Color(0xFFD8FFA3);

  List<dynamic> assets = [];

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  Future<void> fetchAssets() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/assets'),
        headers: await AuthStorage.withSessionCookie(null),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            assets = data;
          });
        }
      } else {
        print('Failed to fetch assets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching assets: $e');
    }
  }

  void handleNavTap(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffHomePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffHandPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffHistoryPage()),
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return const Color(0xFFD8FFA3);
      case 'Out of Stock':
        return const Color.fromARGB(255, 111, 214, 255);
      case 'Disable':
        return Colors.grey;
      default:
        return Colors.white70;
    }
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    final id = asset['asset_id']?.toString() ?? '-';
    final name = asset['asset_name'] ?? 'Unnamed';
    final qty = asset['quantity'] ?? 0;
    // แปลง borrowed = Out of Stock
    final statusRaw = asset['asset_status'] ?? asset['status'] ?? 'Unknown';
    final status = statusRaw.toLowerCase() == 'borrowed' || qty == 0
        ? 'Out of Stock'
        : statusRaw;
    final desc = asset['description'] ?? '';
    final imageUrl = backendImageUrl(asset['image'] as String?)!;

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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black12,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imageUrl == null
                  ? const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, color: Colors.white70),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$id : $name",
                  style: const TextStyle(
                    color: Color(0xFFD8FFA3),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: getStatusColor(status),
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
                              builder: (_) => EditAssetPage(
                                assetId: asset['asset_id'],
                                assetName: name,
                                description: desc,
                                status: status,
                                imageUrl: imageUrl,
                                quantity: qty,
                              ),
                            ),
                          );
                          if (result != null) fetchAssets();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                        MaterialPageRoute(builder: (_) => const AddAssetPage()),
                      );
                      if (newAsset != null) fetchAssets();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 82, 243, 255),
                      foregroundColor: Colors.black,
                    ),
                    label: const Text('Add'),
                    icon: const Icon(Icons.create_new_folder_sharp),
                  ),
                  const LogoutButton(iconColor: Colors.white),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: assets.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: assets.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildAssetCard(assets[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavTap),
    );
  }
}
