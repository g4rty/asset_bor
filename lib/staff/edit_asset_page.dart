import 'dart:io';
import 'package:flutter/material.dart';

class EditAssetPage extends StatefulWidget {
  final int index;
  final String assetName;
  final String description;
  final String status;
  final dynamic imageUrl;

  const EditAssetPage({
    super.key,
    required this.index,
    required this.assetName,
    required this.description,
    required this.status,
    required this.imageUrl,
  });

  @override
  State<EditAssetPage> createState() => _EditAssetPageState();
}

class _EditAssetPageState extends State<EditAssetPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late String _status;
  late dynamic _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.assetName);
    _descController = TextEditingController(text: widget.description);
    _status = widget.status;
    _image = widget.imageUrl;
  }

  void _showDeletePopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Are you sure to delete this item?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFD8FFA3),
              ),
              onPressed: () {
                Navigator.pop(context); // ปิด popup
                Navigator.pop(context, {
                  'action': 'delete',
                  'index': widget.index,
                });
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
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveAsset() {
    Navigator.pop(context, {
      'action': 'update',
      'index': widget.index,
      'name': _nameController.text,
      'description': _descController.text,
      'status': _status,
      'imageFile': _image is File ? _image : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272727),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272727),
        title: const Text('Edit Asset', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _showDeletePopup,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _image != null
                  ? (_image is File
                        ? Image.file(
                            _image,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            _image,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ))
                  : Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey,
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Asset Name',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              items: const [
                DropdownMenuItem(value: 'Available', child: Text('Available')),
                DropdownMenuItem(value: 'Borrowed', child: Text('Borrowed')),
                DropdownMenuItem(value: 'Disabled', child: Text('Disabled')),
              ],
              onChanged: (value) => setState(() => _status = value!),
              dropdownColor: const Color(0xFF424242),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Status',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF424242),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _saveAsset,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD8FFA3),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
