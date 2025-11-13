import 'dart:io';
import 'package:flutter/material.dart';

class EditAssetPage extends StatefulWidget {
  final int index;
  final String assetName;
  final String description;
  final int quantity;
  final String status;
  final dynamic imageUrl;

  const EditAssetPage({
    super.key,
    required this.index,
    required this.assetName,
    required this.description,
    required this.quantity,
    required this.status,
    required this.imageUrl,
  });

  @override
  State<EditAssetPage> createState() => _EditAssetPageState();
}

class _EditAssetPageState extends State<EditAssetPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _quantityController;
  late String _status;
  late dynamic _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.assetName);
    _descController = TextEditingController(text: widget.description);
    _quantityController = TextEditingController(
      text: widget.quantity.toString(),
    );
    _status = widget.status;
  }

  // เลือกรูปจาก gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  // บันทึก asset
  Future<void> _saveAsset() async {
    setState(() => _isSaving = true);

    final uri = Uri.parse(
      'http://192.168.1.100:3000/api/assets/${widget.assetId}',
    );
    var request = http.MultipartRequest('PUT', uri);
    request.fields['name'] = _nameController.text;
    request.fields['description'] = _descController.text;
    request.fields['status'] = _status;

    if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
          filename: _imageFile!.path.split('/').last,
        ),
      );
    }

    try {
      final response = await request.send();
      setState(() => _isSaving = false);

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Asset updated successfully')),
        );
        Navigator.pop(context, {'action': 'update', 'assetId': widget.assetId});
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to update asset (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
    }
  }

  // ลบ asset
  Future<void> _deleteAsset() async {
    final uri = Uri.parse(
      'http://192.168.1.100:3000/api/assets/${widget.assetId}',
    );
    try {
      final response = await http.delete(uri);
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Asset deleted successfully')),
        );
        Navigator.pop(context, {'action': 'delete', 'assetId': widget.assetId});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to delete asset: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
    }
  }

  // ยืนยันการลบ
  void _showDeletePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Are you sure you want to delete this item?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFD8FFA3),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAsset();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFFA3A3),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // แสดงรูป (รองรับทั้ง asset และ upload)
  Widget _buildImageWidget() {
    ImageProvider? imageProvider;

    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (widget.imageUrl != null) {
      if (widget.imageUrl!.startsWith('http')) {
        imageProvider = NetworkImage(widget.imageUrl!);
      } else {
        imageProvider = AssetImage(widget.imageUrl!);
      }
    }

    return GestureDetector(
      onTap: _pickImage,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 150,
          height: 150,
          color: Colors.black26,
          child: imageProvider != null
              ? Image(image: imageProvider, fit: BoxFit.cover)
              : const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 50,
                ),
        ),
      ),
    );
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
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: _buildImageWidget()),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Asset Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _status,
                    dropdownColor: Colors.grey[900],
                    items: const [
                      DropdownMenuItem(
                        value: 'Available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'Borrowed',
                        child: Text('Borrowed'),
                      ),
                      DropdownMenuItem(
                        value: 'Disable',
                        child: Text('Disable'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _status = value!),
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveAsset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD8FFA3),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
