import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'student_home_page.dart';
import 'student_assets_list.dart';
import 'history_screen.dart';
import '../../auth_storage.dart';
import '../../login.dart';
import '../config.dart';

class CancelStatusScreen extends StatefulWidget {
  const CancelStatusScreen({super.key});

  @override
  _CancelStatusScreenState createState() => _CancelStatusScreenState();
}

class _CancelStatusScreenState extends State<CancelStatusScreen> {
  int _selectedIndex = 2;
  bool _loggingOut = false;

  String? _itemId;
  String? _itemName;
  String? _borrowDate;
  String? _returnDate;
  String? _objective;
  String? _currentStatus;
  String? _assetImage;

  String formatDate(String? rawDate) {
    if (rawDate == null) return '';

    final date = DateTime.parse(rawDate);

    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month]} ${date.year % 100}';
  }

  bool _loading = true;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _fetchLatestRequest();
  }

  Future<void> _fetchLatestRequest() async {
    try {
      final userId = await AuthStorage.getUserId();
      if (userId == null) return;

      final url = Uri.parse('${AppConfig.baseUrl}/api/student/$userId/status');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!['pending', 'Borrowed', 'approved'].contains(data['status'])) {
          setState(() => _loading = false);
          return;
        }
        if (data['status'] == 'cancelled') {
          setState(() => _loading = false);
          return;
        }
        setState(() {
          _itemId = data['request_id'].toString();
          _itemName = data['asset_name'];
          _borrowDate = data['borrow_date'];
          _returnDate = data['return_date'];
          _objective = data['reason'];
          _currentStatus = data['status'];
          _assetImage = data['asset_image'];
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error fetching latest request: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _cancelRequest() async {
    if (_itemId == null || _isCancelling) return;
    setState(() => _isCancelling = true);

    final userId = await AuthStorage.getUserId();
    final url = Uri.parse('${AppConfig.baseUrl}/api/request/$_itemId/cancel');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'borrowerId': userId}),
    );

    if (!mounted) return;
    setState(() => _isCancelling = false);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Cancelled')));

      setState(() {
        _currentStatus = 'cancelled';
        _itemId = null;
        _itemName = null;
        _borrowDate = null;
        _returnDate = null;
        _objective = null;
        _assetImage = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel request: ${res.body}')),
      );
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF333333),
          title: const Text(
            'Are you sure to Cancel your asset?',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: const Text(
            'This action can\'t be undone',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _cancelRequest();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4FFAA),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0A6A6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void handleNavbar(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentHomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentAssetsList()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
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
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        leading: null,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Checking Status',
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _itemName == null
          ? const Center(
              child: Text(
                'No active requests found',
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: const Color(0xFF434343),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 25,
                        offset: Offset(0, 15),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/${_assetImage ?? "default.png"}',
                          width: double.infinity,
                          height: 280,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        'Request ${_itemId ?? "??"} : ${_itemName ?? ""}',

                        style: const TextStyle(
                          color: Color(0xFFD4FF00),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Item: ${_itemName ?? ""}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Date: ${formatDate(_borrowDate)} — ${formatDate(_returnDate)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Objective: ${_objective ?? ""}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          const Text(
                            'Status:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (_currentStatus?.toLowerCase() == 'approved' ||
                                    _currentStatus?.toLowerCase() == 'borrowed')
                                ? 'Borrowing'
                                : _currentStatus?.toUpperCase() ?? "",
                            style: TextStyle(
                              color: _currentStatus == 'pending'
                                  ? Colors.yellow
                                  : (_currentStatus?.toLowerCase() ==
                                            'approved' ||
                                        _currentStatus?.toLowerCase() ==
                                            'borrowed')
                                  ? Colors.lightBlueAccent
                                  : _currentStatus == 'cancelled'
                                  ? Colors.redAccent
                                  : Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      if (_currentStatus == 'pending')
                        Center(
                          child: SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: _isCancelling
                                  ? null
                                  : _showCancelDialog,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                backgroundColor: const Color(0xFFF0A6A6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                              child: _isCancelling
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: NavBar(index: _selectedIndex, onTap: handleNavbar),
    );
  }
}
