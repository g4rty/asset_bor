import 'package:flutter/material.dart';

class StudentRequestForm extends StatefulWidget {
  final Map<String, dynamic> asset;
  const StudentRequestForm({super.key, required this.asset});

  @override
  State<StudentRequestForm> createState() => _StudentRequestFormState();
}

class _StudentRequestFormState extends State<StudentRequestForm> {
  final TextEditingController _objectiveController = TextEditingController();

  static const Color _scaffoldBg = Color(0xFF000000);
  static const Color _cardBg = Color(0xFF1C1C1E);
  static const Color _confirmColor = Color(0xFFD4FFAA);
  static const Color _cancelColor = Color(0xFFFFB0B0);

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
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Asset confirmed successfully!')),
              );
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

    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Request Form',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🖼️ รูปภาพจาก asset
            // 🖼️ รูปภาพจาก asset (เวอร์ชันใหม่)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio:
                    16 / 9, // ✅ ควบคุมอัตราส่วนรูป (ปรับได้ เช่น 3/2, 4/3)
                child: InteractiveViewer(
                  // ✅ ให้ขยาย/ย่อรูปได้ด้วยนิ้วหรือเมาส์
                  minScale: 1,
                  maxScale: 3,
                  child: asset['image'] != null
                      ? Image.asset(
                          asset['image'],
                          fit: BoxFit.cover, // ✅ ให้เต็มกรอบโดยไม่ผิดสัดส่วน
                        )
                      : Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.black54,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🧾 การ์ดรายละเอียด + ช่องพิมพ์ Objective
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "01 ${asset['name']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "23 Aug 25 - 24 Aug 25",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Objective",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 6),

                  // 📝 ช่องพิมพ์ Objective
                  TextField(
                    controller: _objectiveController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter your objective...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[700],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ ปุ่ม Confirm / Cancel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: _confirmColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (_objectiveController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter an objective.'),
                              ),
                            );
                          } else {
                            _showConfirmDialog(context);
                          }
                        },
                        child: const Text(
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
                        onPressed: () => Navigator.pop(context),
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
    );
  }
}
