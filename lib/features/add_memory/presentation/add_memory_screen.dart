import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../memories/controller/memories_controller.dart';
import 'save_memory_screen.dart';

class AddMemoryScreen extends StatelessWidget {
  const AddMemoryScreen({super.key, required this.memoriesController});

  /// Shared MemoriesController – passed down from RootNav
  final MemoriesController memoriesController;

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();

    final XFile? picked = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 90,
    );

    if (picked == null) return;

    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaveMemoryScreen(
          imageFile: File(picked.path),
          memoriesController: memoriesController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _pickImage(context),
        child: const Text('Open Camera'),
      ),
    );
  }
}