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
