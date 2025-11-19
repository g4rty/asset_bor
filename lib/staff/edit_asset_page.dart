import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:asset_bor/auth_storage.dart';

class EditAssetPage extends StatefulWidget {
  final int assetId;
  final String assetName;
  final String description;
  final int quantity;
  final String status;
  final String imageUrl;

  const EditAssetPage({
    super.key,
    required this.assetId,
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
  File? _imageFile;
  bool _isSaving = false;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _saveAsset() async {
    setState(() => _isSaving = true);
    int qty = int.tryParse(_quantityController.text) ?? 0;
    String statusToSend = qty == 0 ? 'Out of Stock' : _status;

    final uri = Uri.parse(
      '${AppConfig.baseUrl}/staff/assets/${widget.assetId}',
    );
    var request = http.MultipartRequest('PUT', uri);
    request.headers.addAll(
      await AuthStorage.withSessionCookie(request.headers),
    );

    request.fields['name'] = _nameController.text;
    request.fields['description'] = _descController.text;
    request.fields['quantity'] = qty.toString();
    request.fields['status'] = statusToSend;

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

  Future<void> _deleteAsset() async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}/staff/assets/${widget.assetId}',
    );

    try {
      final response = await http.delete(
        uri,
        headers: await AuthStorage.withSessionCookie(null),
      );
      if (!mounted) return;

      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Unknown error';

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Asset deleted successfully')),
        );
        Navigator.pop(context, {'action': 'delete', 'assetId': widget.assetId});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $message (${response.statusCode})')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
    }
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
              onPressed: () async {
                Navigator.pop(context);
                await _deleteAsset();
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

  Widget _buildImageWidget() {
    ImageProvider? imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (widget.imageUrl.isNotEmpty) {
      if (widget.imageUrl.startsWith('http')) {
        imageProvider = NetworkImage(widget.imageUrl);
      } else {
        imageProvider = AssetImage(widget.imageUrl);
      }
    }

    return GestureDetector(
      onTap: _pickImage,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildStatusField() {
    int qty = int.tryParse(_quantityController.text) ?? 0;

    if (qty == 0) {
      // quantity = 0 → แสดง Out of Stock
      _status = 'Out of Stock';
      return Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(
            255,
            111,
            214,
            255,
          ), // สีเดียวกับ Borrowed เดิม
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Out of Stock',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      // quantity > 0 → Dropdown ปกติ
      if (_status == 'Out of Stock') _status = 'Available';
      return DropdownButtonFormField<String>(
        value: _status,
        dropdownColor: const Color(0xFF424242), // สี background ของ dropdown
        items: const [
          DropdownMenuItem(
            value: 'Available',
            child: Text('Available', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'Disable',
            child: Text('Disable', style: TextStyle(color: Colors.white)),
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Edit Asset'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _buildImageWidget()),
                  const SizedBox(height: 16),
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
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusField(),
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
