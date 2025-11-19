import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:asset_bor/student/cancel_status_screen.dart';
import 'student_home_page.dart';
import 'student_request_form.dart';
import 'package:asset_bor/student/history_screen.dart';
import '../config.dart';
import 'package:asset_bor/shared/backend_image.dart';
import '../../auth_storage.dart';
import '../../login.dart';

class StudentAssetsList extends StatefulWidget {
  const StudentAssetsList({super.key});

  @override
  State<StudentAssetsList> createState() => _StudentAssetsListState();
}

class _StudentAssetsListState extends State<StudentAssetsList> {
  final List<Map<String, dynamic>> assets = [];

  static const Color _scaffoldBgColor = Color(0xFF1F1F1F);
  static const Color _darkCardColor = Color(0xFF434343);
  static const Color _accentColor = Color(0xFFD4FF00);
  static const Color _lightTextColor = Color(0xFFD9D9D9);

  int _selectedIndex = 1;
  bool _loggingOut = false;
  bool _isLoading = true;

  bool _canBorrowToday = true;

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Warning',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getCardBackgroundColor(Map<String, dynamic> asset) {
    final status = asset['status'];
    final quantity = asset['quantity'] ?? 0;

    if (status == 'Disabled' || status == 'Disable') {
      return const Color(0xFF2A2A2A);
    } else if (quantity <= 0) {
      return const Color(0xFF3A3A3A);
    } else if (status == 'Available') {
      return const Color(0xFF434343);
    } else {
      return _darkCardColor;
    }
  }

  Future<void> _fetchAssets() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/assets'),
        headers: await AuthStorage.withSessionCookie(null),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          assets.clear();
          assets.addAll(
            data.map((e) {
              final imageFile = (e['image'] as String?) ?? '';
              final imageUrl = backendImageUrl(imageFile);
              return {
                'id': e['asset_id'],
                'name': e['asset_name'] ?? 'Unnamed',
                'description': e['description'] ?? 'No description',
                'status': e['asset_status'] ?? 'Unknown',
                'quantity': e['quantity'] ?? 0,
                'imageUrl': imageUrl,
              };
            }).toList(),
          );
          _isLoading = false;
        });
      } else {
        print('❌ Failed to load assets: ${response.body}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error fetching assets: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkCanBorrow() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) return;

    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/student/assetlist?borrowerId=$userId',
    );
    final res = await http.get(
      url,
      headers: await AuthStorage.withSessionCookie(null),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        _canBorrowToday = data['canBorrow'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAssets();
    _checkCanBorrow();
  }

  Widget _buildAvailableChip(Map<String, dynamic> asset) {
    final status = asset['status'];
    final int quantity = asset['quantity'] ?? 0;

    String label;
    Color bgColor;

    if (status == 'Disable' || status == 'Disabled') {
      label = 'Disabled';
      bgColor = const Color(0xFFB0B0B0);
    } else if (quantity <= 0) {
      label = 'Out of Stock';
      bgColor = const Color(0xFFB0B0B0);
    } else if (status == 'Available') {
      label = 'Available';
      bgColor = const Color(0xFFD4FFAA);
    } else {
      label = status;
      bgColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        if (status != 'Available') {
          _showAlert("This item is not available for borrowing.");
          return;
        }

        if (quantity <= 0) {
          _showAlert("This item is out of stock.");
          return;
        }

        if (!_canBorrowToday) {
          _showAlert("You can borrow only 1 item per day.");
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentRequestForm(asset: asset),
          ),
        );
      },
      child: Opacity(
        opacity: (status == 'Available' && quantity > 0) ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 15, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF424242)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 210, 245, 160),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    await _logout();
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      await AuthStorage.clearUserId();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF1F1F1F),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Asset List',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            _loggingOut
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: _confirmAndLogout,
                  ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : assets.isEmpty
          ? const Center(
              child: Text(
                'No assets found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: Opacity(
                    opacity: asset['status'] == 'Available' ? 1.0 : 0.6,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getCardBackgroundColor(asset),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.black26,
                            ),
                            child: backendImageWidget(
                              asset['imageUrl'] as String?,
                              fit: BoxFit.cover,
                              placeholder: const Icon(
                                Icons.image_outlined,
                                color: Colors.white30,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${(index + 1).toString().padLeft(2, '0')} : ${asset['name']}",
                                  style: const TextStyle(
                                    color: _accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Description: ${asset['description']}",
                                  style: const TextStyle(
                                    color: _lightTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: _buildAvailableChip(asset),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: NavBar(
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StudentHomePage()),
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CancelStatusScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
