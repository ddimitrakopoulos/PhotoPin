import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/memory.dart';
import '../controllers/memories_controller.dart';

class PhotoDetailScreen extends StatefulWidget {
  const PhotoDetailScreen({
    super.key,
    required this.memory,
    required this.memoriesController,
  });

  final Memory memory;
  final MemoriesController memoriesController;

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[date.month - 1];
    return '${date.day} $month, ${date.year}';
  }

  Widget _buildPhoto() {
    final memory = widget.memory;

    // 1) User-captured image (file path)
    if (memory.imagePath != null && memory.imagePath!.isNotEmpty) {
      final imageFile = File(memory.imagePath!);
      
      // Check if file exists to handle deleted/missing images
      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image can't be loaded
            return Container(
              width: double.infinity,
              height: 220,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.grey.shade600),
                  const SizedBox(height: 8),
                  Text(
                    'Image not available',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // File doesn't exist - show missing image placeholder
        return Container(
          width: double.infinity,
          height: 220,
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 48, color: Colors.grey.shade600),
              const SizedBox(height: 8),
              Text(
                'Image file missing',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }
    }

    // 2) Seeded dummy asset
    if (memory.imageAsset.isNotEmpty) {
      return Image.asset(
        memory.imageAsset,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    // 3) Fallback placeholder
    return Container(
      width: double.infinity,
      height: 220,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.photo, size: 48, color: Colors.white70),
    );
  }

  Future<void> _confirmAndDelete() async {
    final theme = Theme.of(context);
    //final isDark = theme.brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            'Delete memory?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'This memory will be removed. This action cannot be undone.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await widget.memoriesController.deleteMemory(widget.memory);
      if (!mounted) return;
      Navigator.of(context).pop(); // close detail screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final memory = widget.memory;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
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
                          'Photo Detail',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: _buildPhoto(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFF6F61),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 6,
                            offset: Offset(0, -2),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDate(memory.date),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              memory.location,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              memory.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Map
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: SizedBox(
                        height: 260,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(memory.lat, memory.lng),
                            initialZoom: 17.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.PhotoPin',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(memory.lat, memory.lng),
                                  width: 50,
                                  height: 60,
                                  alignment: Alignment.topCenter,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Color(0xFFFF5A5F),
                                    size: 50,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    
                    // Delete memory button
                    Center(
                      child: ElevatedButton(
                        onPressed: _confirmAndDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF2D1B1B) : const Color(0xFFFFEBEE),
                          foregroundColor: const Color(0xFFD32F2F),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete Memory',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
