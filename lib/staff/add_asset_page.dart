import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({super.key});

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _status = 'Available';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // เลือกรูปจาก gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // แสดง popup ยืนยันและอัปโหลดไป backend
  void _showConfirmDialog() {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2F2F2F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: const Text(
            'Are you sure to add new item?',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD8FFA3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              onPressed: () async {
                Navigator.pop(context); // ปิด popup

                final uri = Uri.parse('http://192.168.1.100:3000/api/assets');
                final request = http.MultipartRequest('POST', uri);
                request.fields['name'] = _nameController.text;
                request.fields['description'] = _descriptionController.text;
                request.fields['status'] = _status;
                request.fields['quantity'] = '1';

                if (_imageFile != null) {
                  request.files.add(
                    await http.MultipartFile.fromPath(
                      'image',
                      _imageFile!.path,
                    ),
                  );
                }

                try {
                  final response = await request.send();
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Asset added successfully!'),
                      ),
                    );
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to add asset: ${response.statusCode}',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF9E9E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Asset', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF424242),
      ),
      backgroundColor: const Color(0xFF2F2F2F),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF424242),
                    borderRadius: BorderRadius.circular(20),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? const Icon(
                          Icons.add_a_photo,
                          color: Colors.white70,
                          size: 40,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Asset Name',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF424242),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF424242),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Available', 'Borrowed', 'Disabled']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
                decoration: const InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF424242),
                ),
                dropdownColor: const Color(0xFF424242),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _showConfirmDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF69E),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Add Asset',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
