import 'dart:convert';

import 'package:asset_bor/auth_storage.dart';
import 'package:asset_bor/config.dart';
import 'package:asset_bor/lecturer/lecturer_history.dart';
import 'package:asset_bor/lecturer/lecturer_home_page.dart';
import 'package:asset_bor/lecturer/lecturer_requested_item.dart';
import 'package:asset_bor/lecturer/widgets/lecturer_logout.dart';
import 'package:asset_bor/lecturer/widgets/lecturer_nav_bar.dart';
import 'package:asset_bor/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LecturerAssetList extends StatefulWidget {
  const LecturerAssetList({super.key});

  @override
  State<LecturerAssetList> createState() => _LecturerAssetListState();
}

class _LecturerAssetListState extends State<LecturerAssetList> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    loadAssets();
  }


  Future<void> loadAssets() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/lecturers/assets'));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      final data = List<Map<String, dynamic>>.from(jsonDecode(response.body) as List);
      if (!mounted) return;
      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMsg = '$e';
        isLoading = false;
      });
    }
  }

  Widget BodyBuilder() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4FF00)));
    }

    if (errorMsg != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $errorMsg', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadAssets,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('No assets', style: TextStyle(color: Colors.white70)),
      );
    }

    return RefreshIndicator(
      onRefresh: loadAssets,
      backgroundColor: const Color(0xFF1F1F1F),
      color: const Color(0xFFD4FF00),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 108),
        itemCount: items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Text(
              'Asset List',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            );
          }
          final item = items[index - 1];
          return buildAssetCard(index, item);
        },
      ),
    );
  }

  Widget buildAssetCard(int index, Map<String, dynamic> item) {
    final imagePath = ((item['image'] as String?) ?? '').trim();
    final status = ((item['asset_status'] as String?) ?? '').trim();
    final name = ((item['asset_name'] as String?) ?? '').trim();

    Color bg;
    Color fg;
    String chip;
    switch (status) {
      case 'Available':
        bg = const Color(0xFFDFFFAE);
        fg = Colors.black;
        chip = 'Available';
        break;
      case 'Borrowed':
        bg = const Color(0xFFAEE4FF);
        fg = Colors.black;
        chip = 'Borrowed';
        break;
      case 'Disable':
        bg = const Color(0xFF9E9E9E);
        fg = Colors.black;
        chip = 'Disabled';
        break;
      default:
        bg = const Color(0xFFBDBDBD);
        fg = Colors.black;
        chip = status.isEmpty ? '-' : status;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 130,
              height: 130,
              color: const Color(0xFF2C2C2E),
              child: (() {
                if (imagePath.isEmpty) {
                  return const Icon(Icons.image, color: Colors.white24, size: 36);
                }
                if (imagePath.startsWith('http')) {
                  return Image.network(imagePath, fit: BoxFit.cover);
                }
                return Image.asset('assets/images/$imagePath', fit: BoxFit.cover);
              }()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index.toString().padLeft(2, '0')} ${name.isEmpty ? '-' : name}',
                  style: const TextStyle(
                    color: Color(0xFFD4FF00),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Description unavailable.',
                  style: TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(color: fg, fontWeight: FontWeight.w600),
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

  void handleNavTap(int index) {
    if (index == 1) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LecturerHomePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LecturerRequestedItem()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LecturerHistory()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Assets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: const [
          LecturerLogoutButton(iconColor: Colors.white),
        ],
      ),
      body: SafeArea(child: BodyBuilder()),
      bottomNavigationBar: LecturerNavBar(index: 1, onTap: handleNavTap),
    );
  }
}
