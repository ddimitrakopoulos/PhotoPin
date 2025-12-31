import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_theme.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';
import 'features/root/presentation/screens/root_nav.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Hide system UI overlays (status bar and navigation bar)
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );
  
  // Initialize theme controller and load saved preference
  final themeController = ThemeController();
  await themeController.loadTheme();
  
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
