import 'dart:convert';

import '/config.dart';
import '/lecturer/lecturer_history.dart';
import '/lecturer/lecturer_home_page.dart';
import '/lecturer/lecturer_requested_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Asset {
  const Asset({
    required this.id,
    required this.name,
    required this.status,
    this.description,
    this.imagePath,
  });

  final int id;
  final String name;
  final String status;
  final String? description;
  final String? imagePath;

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['asset_id'] as int? ?? 0,
      name: (json['asset_name'] ?? 'Untitled asset').toString(),
      status: (json['asset_status'] ?? 'Unknown').toString(),
      description: (json['description'] ?? '').toString(),
      imagePath: json['image'] as String?,
    );
  }
}

class LecturerAssetList extends StatefulWidget {
  const LecturerAssetList({super.key});

  @override
  State<LecturerAssetList> createState() => _LecturerAssetListState();
}

class _LecturerAssetListState extends State<LecturerAssetList> {
  final List<Asset> _assets = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedTab = 1;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/assets'));
      if (response.statusCode != 200) {
        throw Exception('Server responded with ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      final loadedAssets =
          data.map((item) => Asset.fromJson(item as Map<String, dynamic>)).toList();

      setState(() {
        _assets
          ..clear()
          ..addAll(loadedAssets);
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Could not load assets. $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _imageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    if (path.startsWith('http')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${AppConfig.baseUrl}/$cleanPath';
  }

  Color _chipColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFFC4FF9D);
      case 'borrowed':
        return const Color(0xFF7ED9FF);
      case 'disabled':
        return const Color(0xFFBDBDBD);
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Text(
                    'Asset List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _BottomNavBar(
                currentIndex: _selectedTab,
                onTap: _onTabSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTabSelected(int index) {
    if (index == _selectedTab) {
      return;
    }

    Widget? destination;
    switch (index) {
      case 0:
        destination = const LecturerHomePage();
        break;
      case 1:
        return; // Already on asset list.
      case 2:
        destination = const LecturerRequestedItem();
        break;
      case 3:
        destination = const LecturerHistory();
        break;
    }

    if (destination != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination!),
      );
    }
  }

  Widget _buildBody() {
    if (_isLoading && _assets.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC4FF9D)),
        ),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAssets,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC4FF9D),
              foregroundColor: Colors.black,
            ),
            child: const Text('Try again'),
          ),
        ],
      );
    }

    if (_assets.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: const [
          Icon(Icons.inventory_2_outlined, color: Colors.white30, size: 72),
          SizedBox(height: 12),
          Text(
            'No assets found.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 140),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        final imageUrl = _imageUrl(asset.imagePath);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: _AssetCard(
            index: index + 1,
            asset: asset,
            imageUrl: imageUrl,
            chipColor: _chipColor(asset.status),
          ),
        );
      },
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.index,
    required this.asset,
    required this.imageUrl,
    required this.chipColor,
  });

  final int index;
  final Asset asset;
  final String? imageUrl;
  final Color chipColor;

  @override
  Widget build(BuildContext context) {
    final description = asset.description?.isNotEmpty == true
        ? asset.description!
        : 'No description available.';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E6E6),
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl == null
                ? const Icon(Icons.image_not_supported_outlined, color: Colors.black38, size: 32)
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.black38,
                      size: 32,
                    ),
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index.toString().padLeft(2, '0')} : ${asset.name}',
                  style: const TextStyle(
                    color: Color(0xFFB6FF7B),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      asset.status,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Material(
        color: Colors.black,
        elevation: 18,
        shadowColor: Colors.black54,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Assets',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.shopping_basket_outlined,
                label: 'Requests',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.access_time,
                label: 'History',
                selected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black : Colors.white70;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFC4FF9D) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
