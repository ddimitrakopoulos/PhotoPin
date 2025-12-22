import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Import the home screen

void main() {
  runApp(const PhotoPinApp());
}

class PhotoPinApp extends StatelessWidget {
  const PhotoPinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PhotoPin',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const HomeScreen(),
    );
  }
}
