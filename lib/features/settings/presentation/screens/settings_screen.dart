import 'package:flutter/material.dart';

import '../controllers/theme_controller.dart';


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
                              'Settings',
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
