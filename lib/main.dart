import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';
import 'features/root/presentation/screens/root_nav.dart';


void main() {
  final themeController = ThemeController();
  runApp(PhotoPinApp(themeController: themeController));
}

class PhotoPinApp extends StatelessWidget {
  const PhotoPinApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'PhotoPin',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: themeController.themeMode,
          home: RootNav(themeController: themeController),
        );
      },
    );
  }
}
