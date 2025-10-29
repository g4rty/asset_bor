import 'package:flutter/material.dart';

class EditAssetPage extends StatelessWidget {
  final String assetName;
  final String description;
  final String status;
  final String imageUrl;

  const EditAssetPage({
    super.key,
    required this.assetName,
    required this.description,
    required this.status,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272727),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272727),
        title: const Text('Edit Asset', style: TextStyle(color: Colors.white)),
        actions: [
          // 🔴 ปุ่ม Delete
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              // ⚠️ แสดง Popup ยืนยันการลบ
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFF1F1F1F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Are you sure to delete this item!!',
                      style: TextStyle(color: Colors.white),
                    ),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFD8FFA3),
                        ),
                        onPressed: () {
                          // ลบ asset และปิด popup + กลับไปหน้า list
                          Navigator.pop(context); // ปิด popup
                          Navigator.pop(context, 'deleted'); // ส่งกลับค่า
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA3A3),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // ปิด popup
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: assetName,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Asset Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              initialValue: description,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: 'Available', child: Text('Available')),
                DropdownMenuItem(value: 'Borrowed', child: Text('Borrowed')),
                DropdownMenuItem(value: 'Disabled', child: Text('Disabled')),
              ],
              onChanged: (value) {},
              dropdownColor: const Color(0xFF424242),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Status',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const Spacer(),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD8FFA3),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                Navigator.pop(context); // Save แล้วกลับ
              },
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
