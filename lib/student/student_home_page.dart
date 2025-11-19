import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../../auth_storage.dart';
import '../../login.dart';
import 'cancel_status_screen.dart';
import 'history_screen.dart';
import 'student_assets_list.dart';
import 'package:asset_bor/shared/backend_image.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _selectedIndex = 0;
  bool _loggingOut = false;

  List<dynamic> _assets = [];
  bool _loadingAssets = true;

  static const Color _scaffoldBgColor = Color(0xFF000000);
  static const Color _darkCardColor = Color(0xFF434343);
  static const Color _accentColor = Color(0xFFD4FF00);
  static const Color _lightTextColor = Color.fromARGB(255, 224, 224, 224);

  @override
  void initState() {
    super.initState();
    _fetchAllAssets();
  }

  Future<void> _fetchAllAssets() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/assets'),
        headers: await AuthStorage.withSessionCookie(null),
      );
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final availableAssets = (data as List)
            .where(
              (asset) =>
                  asset['asset_status'] == 'Available' &&
                  (asset['quantity'] ?? 1) > 0,
            )
            .map((asset) {
              final imageFile = ((asset['image'] as String?) ?? '').trim();
              final imageUrl = backendImageUrl(imageFile);
              return {...asset as Map<String, dynamic>, 'imageUrl': imageUrl};
            })
            .toList()
            .reversed
            .toList();

        setState(() {
          _assets = availableAssets;
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Fetch error: $e');
    } finally {
      setState(() => _loadingAssets = false);
    }
  }

  void handleNavbar(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentAssetsList()),
        ).then((_) {
          setState(() => _selectedIndex = 0);
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CancelStatusScreen()),
        ).then((_) {
          setState(() => _selectedIndex = 0);
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        ).then((_) {
          setState(() => _selectedIndex = 0);
        });
        break;
    }
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
              backgroundColor: Color.fromARGB(255, 210, 245, 160),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Home Page',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
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
                            size: 28,
                          ),
                          onPressed: _confirmAndLogout,
                        ),
                ],
              ),
              const SizedBox(height: 24),
              _buildRulesSection(),
              const SizedBox(height: 32),

              if (_loadingAssets)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else if (_assets.isEmpty)
                const Center(
                  child: Text(
                    'No available asset found.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              else
                Column(
                  children: () {
                    int displayCount = _assets.length >= 3 ? 3 : _assets.length;
                    return List.generate(displayCount, (index) {
                      final asset = _assets[index];
                      final isNew = index == 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildAssetCard(
                          imageUrl: asset['imageUrl'] as String? ?? '',
                          title: asset['asset_name'] ?? 'Unnamed',
                          subtitle: asset['asset_status'] ?? '',
                          assetId: asset['asset_id'],
                          description: asset['description'] ?? '',
                          isNew: isNew,
                        ),
                      );
                    });
                  }(),
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavbar),
    );
  }

  Widget _buildRulesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.rule, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Rule',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _RuleCard(
            number: '01',
            title: 'FIRST',
            description: 'One asset per day Students only.',
          ),
          SizedBox(height: 12),
          _RuleCard(
            number: '02',
            title: 'AVAILABLE',
            description: 'Borrow only "Available" items.',
          ),
          SizedBox(height: 12),
          _RuleCard(
            number: '03',
            title: 'VALID',
            description: 'Borrowing must start today or later.',
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard({
    required String? imageUrl,
    required String title,
    required String subtitle,
    required int assetId,
    required String description,
    bool isNew = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isNew)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6),
            child: Text(
              'NEW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _darkCardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black26,
                ),
                clipBehavior: Clip.antiAlias,
                child: backendImageWidget(
                  imageUrl,
                  fit: BoxFit.cover,
                  placeholder: const Icon(
                    Icons.image_outlined,
                    color: Colors.white24,
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
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description.isNotEmpty
                          ? description
                          : 'No description available',
                      style: const TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Available',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _RuleCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 42, 42, 44),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 6),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  static const Color _bg = Colors.black;
  static const Color _active = Color.fromARGB(255, 210, 245, 160);
  static const Color _inactive = Colors.white;

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home,
      Icons.shopping_bag_outlined,
      Icons.list_alt_outlined,
      Icons.history,
    ];
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: 72 + bottomInset,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottomInset > 0 ? bottomInset * 0.4 : 12,
      ),
      color: _bg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (i) {
          final selected = i == index;
          return InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? _active : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icons[i],
                size: 24,
                color: selected ? Colors.black : _inactive,
              ),
            ),
          );
        }),
      ),
    );
  }
}
