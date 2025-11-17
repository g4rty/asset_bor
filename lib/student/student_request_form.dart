import 'dart:convert';
import 'package:asset_bor/student/cancel_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:intl/intl.dart';
import 'student_home_page.dart';
import 'student_assets_list.dart';
import 'cancel_status_screen.dart';
import 'history_screen.dart';

import '../../auth_storage.dart';

class StudentRequestForm extends StatefulWidget {
  final Map<String, dynamic> asset;
  const StudentRequestForm({super.key, required this.asset});

  @override
  State<StudentRequestForm> createState() => _StudentRequestFormState();
}

class _StudentRequestFormState extends State<StudentRequestForm> {
  final TextEditingController _objectiveController = TextEditingController();

  static const Color _scaffoldBg = Color(0xFF1F1F1F);
  static const Color _cardBg = Color(0xFF434343);
  static const Color _confirmColor = Color(0xFFD4FFAA);
  static const Color _cancelColor = Color(0xFFFFB0B0);

  bool _isSubmitting = false;

  Future<void> _submitRequest() async {
    final reason = _objectiveController.text.trim();
    final assetId = widget.asset['id'] ?? widget.asset['asset_id'];
    final borrowerId = await AuthStorage.getUserId();

    if (reason.isEmpty || borrowerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter an objective and make sure you are logged in.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      final borrowDate = DateFormat('yyyy-MM-dd').format(now);
      final returnDate = DateFormat('yyyy-MM-dd').format(tomorrow);

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/student/request_form'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'asset_id': assetId,
          'borrower_id': borrowerId,
          'borrow_date': borrowDate,
          'return_date': returnDate,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CancelStatusScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.greenAccent,
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.black),
                SizedBox(width: 10),
                Text(
                  'Borrow request submitted successfully!',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );
      } else {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final msg = data['error'] ?? 'Failed to submit request';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.amberAccent,
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.black),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      msg,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Failed to submit request'),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Error submitting request: $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Are you sure to Confirm your asset?',
          style: TextStyle(color: Colors.white),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: _confirmColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CancelStatusScreen()),
              );
              _submitRequest();
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: _cancelColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    String formatDate(DateTime date) {
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

    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Request Form',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.grey[700],
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 3,
                      child: asset['image'] != null
                          ? Image.asset(asset['image'], fit: BoxFit.contain)
                          : const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.white54,
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request ${asset['id'] ?? asset['asset_id']} : ${asset['name'] ?? "Unknown"}',
                      style: const TextStyle(
                        color: Color(0xFFD4FF00),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Item: ${asset['name'] ?? "Unknown"}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Borrow Date: ${formatDate(now)} — Return: ${formatDate(tomorrow)}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Text(
                      "Objective",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 6),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _objectiveController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Enter your objective...",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: _confirmColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  if (_objectiveController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter an objective.',
                                        ),
                                      ),
                                    );
                                  } else {
                                    _showConfirmDialog(context);
                                  }
                                },
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Confirm',
                                  style: TextStyle(color: Colors.black),
                                ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: _cancelColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
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
        ),
      ),
    );
  }
}
