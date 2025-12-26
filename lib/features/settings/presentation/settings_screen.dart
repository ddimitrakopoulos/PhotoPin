import 'package:flutter/material.dart';

import '../../../core/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final theme = Theme.of(context);
        final isDark = themeController.isDarkMode;

        final cardColor = isDark ? const Color(0xFF181818) : Colors.white;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
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
                          'Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      // X button positioned to the left of centered text
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2 - 120, // More to the right
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

                const SizedBox(height: 8),

                // Dark mode card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                offset: const Offset(0, 10),
                                blurRadius: 30,
                                color: Colors.black.withAlpha(20),
                              ),
                            ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Switch(
                          value: themeController.isDarkMode,
                          activeThumbColor: const Color(0xFFFF5A5F),
                          onChanged: themeController.toggleDarkMode,
                        ),
                      ],
                    ),
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
