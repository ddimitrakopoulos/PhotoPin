import 'package:flutter/material.dart';

import '../../domain/memory.dart';
import '../controllers/memories_controller.dart';
import '../widgets/memory_card.dart';
import 'photo_detail_screen.dart';


class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key, required this.controller});

  final MemoriesController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        //final theme = Theme.of(context);
        //final isDark = theme.brightness == Brightness.dark;

        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<Memory> memories = controller.memories;

        // Show empty state if no memories
        if (memories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No memories yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the camera button to add your first memory',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      return MemoryCard(
                        memory: memory,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PhotoDetailScreen(
                                memory: memory,
                                memoriesController: controller,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemCount: memories.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
