import 'package:flutter/material.dart';
import '../widgets/footer_nav.dart';
import '../widgets/app_topbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0 = Map, 1 = List

  // Updates the state when footer icons are tapped
  void _onFooterItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------------------------------------------------
      // TOP BAR
      // We do NOT pass 'actionButton' here.
      // This forces the widget to use its default 'assets/gear.png'.
      // ---------------------------------------------------------
      appBar: AppTopBar(
        onSettingsPressed: () {
          print("Settings Gear Clicked");
        },
      ),

      // ---------------------------------------------------------
      // BODY CONTENT
      // Switches between Map and List text based on _selectedIndex
      // ---------------------------------------------------------
      body: Center(
        child: Text(
          _selectedIndex == 0 ? 'Map View Content' : 'List View Content',
          style: const TextStyle(color: Colors.white54, fontSize: 24),
        ),
      ),

      // ---------------------------------------------------------
      // FOOTER NAV
      // ---------------------------------------------------------
      bottomNavigationBar: PhotoPinFooter(
        selectedIndex: _selectedIndex,
        onItemTapped: _onFooterItemTapped,
      ),
    );
  }
}
