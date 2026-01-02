import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/memory.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard({super.key, required this.memory, required this.onTap});

  final Memory memory;
  final VoidCallback onTap;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF181818) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final dateLocationBgColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEAEAEA);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0x19000000),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Image on the left
            Padding(
              padding: const EdgeInsets.only(left: 9, top: 12, bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: _memoryImage(memory),
                ),
              ),
            ),
            // Right side content (Date/Location box + Caption)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 10, top: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date/Location box
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: dateLocationBgColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/svg/calendar.svg',
                                width: 14,
                                height: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(memory.date),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/svg/pin.svg',
                                width: 14,
                                height: 14,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  memory.location,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Spacer
                    const SizedBox(height: 11),
                    // Caption
                    Text(
                      memory.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 28,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _memoryImage(Memory m) {
    if (m.imagePath != null && m.imagePath!.isNotEmpty) {
      final imageFile = File(m.imagePath!);
      
      // Check if file exists
      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          // Performance: cache images
          cacheWidth: 240, // 2x for retina displays
          cacheHeight: 240,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image can't be loaded
            return Container(
              width: 120,
              height: 120,
              color: Colors.grey.shade300,
              child: Icon(Icons.broken_image, color: Colors.grey.shade600),
            );
          },
        );
      } else {
        // File doesn't exist - show missing image placeholder
        return Container(
          width: 120,
          height: 120,
          color: Colors.grey.shade300,
          child: Icon(Icons.image_not_supported, color: Colors.grey.shade600),
        );
      }
    }
    return Image.asset(
      m.imageAsset,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      // Performance: cache images
      cacheWidth: 240,
      cacheHeight: 240,
    );
  }
}
