import 'dart:convert';

import 'package:asset_bor/auth_storage.dart';
import 'package:asset_bor/config.dart';
import 'package:asset_bor/lecturer/lecturer_asset_list.dart';
import 'package:asset_bor/lecturer/lecturer_history.dart';
import 'package:asset_bor/lecturer/lecturer_home_page.dart';
import 'package:asset_bor/lecturer/widgets/lecturer_logout.dart';
import 'package:asset_bor/lecturer/widgets/lecturer_nav_bar.dart';
import 'package:asset_bor/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LecturerRequestedItem extends StatefulWidget {
  const LecturerRequestedItem({super.key});

  @override
  State<LecturerRequestedItem> createState() => _LecturerRequestedItemState();
}

class _LecturerRequestedItemState extends State<LecturerRequestedItem> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  String? errorMsg;

  static const rejectRequestOptions = <String>[
    'Unavailable on requested dates',
    'Reserved for class or maintenance',
    'Invalid or incomplete request',
    'Temporarily under repair',
  ];

  @override
  void initState() {
    super.initState();
    loadPending();
  }

  Future<void> loadPending() async {
    final userId = await AuthStorage.getUserId();
    if (!mounted) return;
    if (userId == null) {
      await AuthStorage.clearUserId();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/requests/pending');
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      final data = List<Map<String, dynamic>>.from(
        jsonDecode(response.body) as List,
      );
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

  Future approveAPI(int requestId) async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) return;
    final url = Uri.parse('${AppConfig.baseUrl}/requests/$requestId/approve');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'lecturerId': userId}),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future rejectAPI(int requestId, String reason) async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) return;
    final url = Uri.parse('${AppConfig.baseUrl}/requests/$requestId/reject');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'lecturerId': userId, 'reason': reason}),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<void> confirmApprove(Map<String, dynamic> item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Approve request',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3C),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFF2C2C2E),
                  child: (() {
                    final path = item['asset_image'] as String?;
                    if (path == null || path.trim().isEmpty) {
                      return const Icon(
                        Icons.image,
                        color: Colors.white24,
                        size: 28,
                      );
                    }
                    if (path.startsWith('http')) {
                      return Image.network(path, fit: BoxFit.cover);
                    }
                    return Image.asset(
                      'assets/images/$path',
                      fit: BoxFit.cover,
                    );
                  }()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (item['asset_name'] as String? ?? '-').trim().isEmpty
                          ? '-'
                          : (item['asset_name'] as String).trim(),
                      style: const TextStyle(
                        color: Color(0xFFD4FF00),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Borrower: ${(item['borrower_name'] as String? ?? '').trim().isEmpty ? '-' : (item['borrower_name'] as String).trim()}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Return: ${formatDate(item['return_date'])}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFDFFFAE),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF07A7A),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await approveAPI(item['request_id'] as int);
      if (!mounted) return;
      await loadPending();
    }
  }

  Future<void> confirmReject(Map<String, dynamic> item) async {
    final controller = TextEditingController();
    String selected = rejectRequestOptions.first;
    String? reason;
    try {
      reason = await showDialog<String>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (_, setState) => AlertDialog(
            backgroundColor: const Color(0xFF2C2C2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Rejected Requests',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...rejectRequestOptions.map(
                    (option) => RadioListTile<String>(
                      value: option,
                      groupValue: selected,
                      onChanged: (value) =>
                          setState(() => selected = value ?? selected),
                      activeColor: const Color(0xFFDFFFAE),
                      title: Text(
                        option,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  RadioListTile<String>(
                    value: 'Other',
                    groupValue: selected,
                    onChanged: (value) =>
                        setState(() => selected = value ?? selected),
                    activeColor: const Color(0xFFDFFFAE),
                    title: const Text(
                      'Other',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if (selected == 'Other')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Reason',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFDFFFAE),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  final v = selected == 'Other'
                      ? controller.text.trim()
                      : selected;
                  Navigator.pop(context, v);
                },
                child: const Text('Confirm'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF07A7A),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );
    } finally {
      controller.dispose();
    }

    if (reason != null && reason.trim().isNotEmpty) {
      await rejectAPI(item['request_id'] as int, reason.trim());
      if (!mounted) return;
      await loadPending();
    }
  }

  String formatDate(dynamic value) {
    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }
    if (date == null) return '-';

    const month = [
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

    return '${date.day.toString().padLeft(2, '0')} ${month[date.month]} ${date.year % 100}';
  }

  Widget RequestCardBuilder(Map<String, dynamic> item) {
    final assetName = ((item['asset_name'] as String?) ?? '').trim();
    final borrower = ((item['borrower_name'] as String?) ?? '').trim();
    final borrowDate = item['borrow_date'];
    final returnDate = item['return_date'];
    final reason = ((item['reason'] as String?) ?? '').trim();
    final imagePath = ((item['asset_image'] as String?) ?? '').trim();

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
              width: 110,
              height: 110,
              color: const Color(0xFF2C2C2E),
              child: (() {
                if (imagePath.isEmpty) {
                  return const Icon(
                    Icons.image,
                    color: Colors.white24,
                    size: 36,
                  );
                }
                if (imagePath.startsWith('http')) {
                  return Image.network(imagePath, fit: BoxFit.cover);
                }
                return Image.asset(
                  'assets/images/$imagePath',
                  fit: BoxFit.cover,
                );
              }()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request ${item['request_id']} • Asset ${item['asset_id']}',
                  style: const TextStyle(
                    color: Color(0xFFD4FF00),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Item: ',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        TextSpan(
                          text: assetName.isEmpty ? '-' : assetName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Borrower: ',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        TextSpan(
                          text: borrower.isEmpty ? '-' : borrower,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Date: ',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        TextSpan(
                          text: '${formatDate(borrowDate)} - ${formatDate(returnDate)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Objective : ',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        TextSpan(
                          text: reason.isEmpty ? '-' : reason,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => confirmApprove(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFFFAE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(
                            color: const Color(0xFF396001),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => confirmReject(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF07A7A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget bodyBuilder() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4FF00)),
      );
    }

    if (errorMsg != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Error: $errorMsg',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadPending,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('No requests', style: TextStyle(color: Colors.white70)),
      );
    }

    return RefreshIndicator(
      onRefresh: loadPending,
      backgroundColor: const Color(0xFF1F1F1F),
      color: const Color(0xFFD4FF00),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 108),
        itemCount: items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Text(
              'Requests List',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            );
          }
          final item = items[index - 1];
          return RequestCardBuilder(item);
        },
      ),
    );
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
        actions: const [LecturerLogoutButton(iconColor: Colors.white)],
      ),
      body: SafeArea(child: bodyBuilder()),
      bottomNavigationBar: LecturerNavBar(
        index: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LecturerHomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LecturerAssetList(),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LecturerHistory()),
            );
          }
        },
      ),
    );
  }
}
