import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../generated/assets.dart';
import '../../domain/memory.dart';
import 'memory_meta_row.dart';

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

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    offset: const Offset(0, 10),
                    blurRadius: 30,
                    color: Colors.black.withAlpha(15),
                  ),
                ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: _memoryImage(memory),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  MemoryMetaRow(
                    iconAsset: Assets.svgCalendar,
                    text: _formatDate(memory.date),
                  ),
                  const SizedBox(height: 4),
                  MemoryMetaRow(
                    iconAsset: Assets.svgLocation,
                    text: memory.location,
                  ),
                ],
              ),
            ),
          ],
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
          width: 84,
          height: 84,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image can't be loaded
            return Container(
              width: 84,
              height: 84,
              color: Colors.grey.shade300,
              child: Icon(Icons.broken_image, color: Colors.grey.shade600),
            );
          },
        );
      } else {
        // File doesn't exist - show missing image placeholder
        return Container(
          width: 84,
          height: 84,
          color: Colors.grey.shade300,
          child: Icon(Icons.image_not_supported, color: Colors.grey.shade600),
        );
      }
    }
    return Image.asset(m.imageAsset, width: 84, height: 84, fit: BoxFit.cover);
  }
}
