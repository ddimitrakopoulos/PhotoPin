import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  stt.SpeechToText? _speech;
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _speechInitialized = false;

  @override
  void initState() {
    super.initState();
    // Don't initialize speech immediately - wait until user needs it
  }

  Future<void> _initSpeech() async {
    if (_speechInitialized) return;
    
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech!.initialize(
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech recognition error: ${error.errorMsg}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onStatus: (status) {
        if (status == 'notAvailable' && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition not available on this device'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
    _speechInitialized = true;
    if (mounted) setState(() {});
  }

  void _startListening() async {
    // Initialize speech on first use
    if (!_speechInitialized) {
      await _initSpeech();
    }
    
    if (!_speechAvailable || _speech == null) return;
    
    await _speech!.listen(
      onResult: (result) {
        setState(() {
          captionController.text = result.recognizedWords;
        });
      },
    );
    setState(() => _isListening = true);
  }

  void _stopListening() async {
    if (_speech == null) return;
    await _speech!.stop();
    setState(() => _isListening = false);
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  Future<Position> _getPosition() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        await Geolocator.openLocationSettings();
        // Check again after opening settings
        enabled = await Geolocator.isLocationServiceEnabled();
        if (!enabled) {
          throw Exception('Location services are disabled');
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Location permission denied');
        }
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isEmpty) {
        return 'Unknown location';
      }
      
      final place = placemarks.first;

      final locality = place.locality;
      final administrativeArea = place.administrativeArea;
      final country = place.country;

      final locationParts = [
        if (locality != null && locality.isNotEmpty) locality,
        if (administrativeArea != null && administrativeArea.isNotEmpty)
          administrativeArea,
        if (country != null && country.isNotEmpty) country,
      ];
      
      return locationParts.isNotEmpty ? locationParts.join(', ') : 'Unknown location';
    } catch (e) {
      // Return coordinates if geocoding fails
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
  }

  Future<String> _copyImageToPermanentStorage(File imageFile) async {
    try {
      // Verify source file exists
      if (!await imageFile.exists()) {
        throw Exception('Source image file does not exist');
      }
      
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
      final copiedFile = await imageFile.copy(permanentPath);
      
      // Verify the copy succeeded
      if (!await copiedFile.exists()) {
        throw Exception('Failed to verify copied file exists');
      }
      
      return permanentPath;
    } catch (e) {
      throw Exception('Error copying image to permanent storage: $e');
    }
  }

  Future<void> _saveMemory() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final pos = await _getPosition();
      final locationString = await _reverseGeocode(pos.latitude, pos.longitude);
      
      // Copy image to permanent storage
      final permanentImagePath = await _copyImageToPermanentStorage(widget.imageFile);
      
      // Verify the file was copied successfully
      final copiedFile = File(permanentImagePath);
      if (!await copiedFile.exists()) {
        throw Exception('Failed to copy image to permanent storage');
      }

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

      // Save memory and WAIT for completion
      await widget.memoriesController.addMemory(memory);
      
      // Add a small delay to ensure SharedPreferences write completes
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;
      Navigator.of(context).pop(); // close SaveMemoryScreen
    } catch (e) {
      // Handle errors gracefully
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save memory: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    captionController.dispose();
    _speech?.stop();
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
                child: Row(
                  children: [
                    // X button aligned to the left
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: const Color(0xFFFF5A5F), // App orange color
                      iconSize: 32,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    // Spacer to push text to center
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 48), // Compensate for X button width
                          child: Text(
                            'Add Memory',
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                              fontSize: 32,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
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

              // Caption input field (Figma design - theme aware)
              Container(
                width: double.infinity,
                height: 52,
                decoration: ShapeDecoration(
                  color: isDark ? const Color(0xFF252525) : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFF79747E),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 6,
                      offset: Offset(0, -2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: captionController,
                        maxLines: 1,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                          fontSize: 32,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a caption ...',
                          hintStyle: TextStyle(
                            color: isDark 
                                ? Colors.white.withOpacity(0.6) 
                                : const Color(0xFF1E1E1E).withOpacity(0.6),
                            fontSize: 32,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 1.25,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        ),
                      ),
                    ),
                    // Microphone button
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening 
                            ? const Color(0xFFFF5A5F)
                            : (isDark ? Colors.white70 : Colors.black54),
                        size: 28,
                      ),
                      onPressed: _toggleListening,
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveMemory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F61),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 2,
                      shadowColor: const Color(0x4C000000),
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
                        : const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 0.63,
                              letterSpacing: 0.10,
                            ),
                          ),
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
