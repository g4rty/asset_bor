import 'dart:convert';

import '../auth_storage.dart';
import '../config.dart';
import '../login.dart';
import 'lecturer_history.dart';
import 'lecturer_home_page.dart';
import 'lecturer_requested_item.dart';
import 'widgets/lecturer_nav_bar.dart';
import 'widgets/lecturer_logout.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LecturerAssetList extends StatefulWidget {
  const LecturerAssetList({super.key});
  @override
  State<LecturerAssetList> createState() => _LecturerAssetListState();
}

class _LecturerAssetListState extends State<LecturerAssetList> {
  int index = 1; // start on second tab

  Future<List<AssetItem>> _fetchAssets() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      await AuthStorage.clearUserId();
      if (!mounted) return const [];
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return const [];
    }

    final url = Uri.parse('${AppConfig.baseUrl}/lecturers/assets');
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }

    final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
    return data
        .map((item) => AssetItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Assets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: const [
          LecturerLogoutButton(iconColor: Colors.white),
        ],
      ),
      body: SafeArea(child: AssetListView(fetch: _fetchAssets)),
      bottomNavigationBar: LecturerNavBar(
        index: index,
        onTap: (i) {
          setState(() => index = i);
          if (i == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LecturerHomePage()),
            );
          } else if (i == 1) {
            // current page
            return;
          } else if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LecturerRequestedItem()),
            );
          } else if (i == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LecturerHistory(),
              ),
            );
          }
        },
      ),
    );
  }
}

class AssetItem {
  final int id;
  final String name;
  final String status;
  final String image;
  AssetItem({
    required this.id,
    required this.name,
    required this.status,
    required this.image,
  });
  factory AssetItem.fromJson(Map<String, dynamic> j) => AssetItem(
    id: j['asset_id'] as int,
    name: j['asset_name'] as String,
    status: j['asset_status'] as String,
    image: (j['image'] as String?) ?? '',
  );
}

class AssetListView extends StatelessWidget {
  const AssetListView({super.key, required this.fetch});
  final Future<List<AssetItem>> Function() fetch;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssetItem>>(
      future: fetch(),
      builder: (context, s) {
        if (s.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4FF00)),
          );
        }
        if (s.hasError) {
          return Center(
            child: Text(
              'Error: ${s.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        final items = s.data!;
        if (items.isEmpty) {
          return const Center(
            child: Text('No assets', style: TextStyle(color: Colors.white70)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24 + 84),
          itemCount: items.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, i) {
            if (i == 0) {
              return const Text(
                'Asset List',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            final a = items[i - 1];
            return AssetCard(index: i, item: a);
          },
        );
      },
    );
  }
}

class AssetCard extends StatelessWidget {
  const AssetCard({super.key, required this.index, required this.item});
  final int index; // 1-based display number
  final AssetItem item;

  static const Color _card = Color(0xFF3A3A3C);
  static const Color _imgBg = Color(0xFF2C2C2E);
  static const Color _title = Color(0xFFD4FF00); // lime

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
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
              color: _imgBg,
              child: item.image.isNotEmpty
                  ? Image.asset(
                      'assets/images/${item.image}',
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, color: Colors.white24, size: 36),
            ),
          ),

          const SizedBox(width: 16),
          // text + chip
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index.toString().padLeft(2, '0')} ${item.name}',
                  style: const TextStyle(
                    color: _title,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  // replace when backend returns description
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
                  child: _statusChip(item.status),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    late Color bg;
    late Color fg;
    late String label;
    switch (status) {
      case 'Available':
        bg = const Color(0xFFDFFFAE);
        fg = Colors.black;
        label = 'Available';
        break;
      case 'Borrowed':
        bg = const Color(0xFFAEE4FF);
        fg = Colors.black;
        label = 'Borrowed';
        break;
      case 'Disable':
        bg = const Color(0xFF9E9E9E);
        fg = Colors.black;
        label = 'Disabled';
        break;
      default:
        bg = const Color(0xFFBDBDBD);
        fg = Colors.black;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
