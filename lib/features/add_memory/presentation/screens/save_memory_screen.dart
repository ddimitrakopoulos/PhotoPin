import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../memories/presentation/controllers/memories_controller.dart';
import '../../../memories/domain/memory.dart';

class SaveMemoryScreen extends StatefulWidget {
  const SaveMemoryScreen({
    super.key,
    required this.imageFile,
    required this.memoriesController,
  });

  final File imageFile;
  final MemoriesController memoriesController;

  @override
  State<SaveMemoryScreen> createState() => _SaveMemoryScreenState();
}

class _SaveMemoryScreenState extends State<SaveMemoryScreen> {
  final captionController = TextEditingController();
  bool _saving = false;

  Future<Position> _getPosition() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      await Geolocator.openLocationSettings();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    return Geolocator.getCurrentPosition();
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    final place = placemarks.first;

    final locality = place.locality;
    final administrativeArea = place.administrativeArea;
    final country = place.country;

    return [
      if (locality != null && locality.isNotEmpty) locality,
      if (administrativeArea != null && administrativeArea.isNotEmpty)
        administrativeArea,
      if (country != null && country.isNotEmpty) country,
    ].join(', ');
  }

  Future<String> _copyImageToPermanentStorage(File imageFile) async {
    // Get app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(directory.path, 'images'));
    
    // Create images directory if it doesn't exist
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    // Create unique filename with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(imageFile.path);
    final fileName = 'memory_$timestamp$extension';
    final permanentPath = path.join(imagesDir.path, fileName);
    
    // Copy file to permanent location
    await imageFile.copy(permanentPath);
    return permanentPath;
  }

  Future<void> _saveMemory() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final pos = await _getPosition();
      final locationString = await _reverseGeocode(pos.latitude, pos.longitude);
      
      // Copy image to permanent storage
      final permanentImagePath = await _copyImageToPermanentStorage(widget.imageFile);

      final caption = captionController.text.trim();

      final memory = Memory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: caption.isEmpty ? 'New Memory' : caption,
        caption: caption.isEmpty ? null : caption,
        date: DateTime.now(),
        location: locationString,
        imageAsset: '', // not used for user photos
        imagePath: permanentImagePath, // Use permanent path instead of temp
        lat: pos.latitude,
        lng: pos.longitude,
      );

      await widget.memoriesController.addMemory(memory);

      if (!mounted) return;
      Navigator.of(context).pop(); // close SaveMemoryScreen
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Stack(
                  children: [
                    // Centered text - fixed position
                    Center(
                      child: Text(
                        'Save Memory',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    // X button positioned to the left of centered text
                    Positioned(
                      left: MediaQuery.of(context).size.width / 2 - 160, // More to the left
                      top: -7.5,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        color: const Color(0xFFFF5A5F), // App orange color
                        iconSize: 32,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.file(
                  widget.imageFile,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Add Caption:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: captionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Type Here..',
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withAlpha(15)
                      : Colors.black.withAlpha(8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),

              // Save Memory button (centered)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveMemory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5A5F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Memory'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
