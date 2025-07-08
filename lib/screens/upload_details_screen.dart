import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class UploadDetailsScreen extends StatefulWidget {
  final String label;

  const UploadDetailsScreen({super.key, required this.label});

  @override
  State<UploadDetailsScreen> createState() => _UploadDetailsScreenState();
}

class _UploadDetailsScreenState extends State<UploadDetailsScreen> {
  File? _selectedImage;
  Position? _currentPosition;
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _getLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('❌ Location error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to get location")),
      );
    }
  }

  void _submitDetails() async {
    if (_selectedImage == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image and location required")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // TODO: Store in local DB and send to backend
    print('✅ Submitted image: ${_selectedImage!.path}');
    print('📍 Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    Navigator.pop(context, {
      'imagePath': _selectedImage!.path,
      'location': _currentPosition,
    });

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Details (${widget.label})")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : const Placeholder(fallbackHeight: 200),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _getLocation,
              icon: const Icon(Icons.my_location),
              label: const Text("Fetch My Location"),
            ),
            if (_currentPosition != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "📍 ${_currentPosition!.latitude}, ${_currentPosition!.longitude}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitDetails,
              icon: const Icon(Icons.upload),
              label: _isSubmitting ? const Text("Submitting...") : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
