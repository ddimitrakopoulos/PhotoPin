import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../add_memory/presentation/screens/save_memory_screen.dart';
import '../../../map/presentation/screens/map_screen.dart';
import '../../../memories/data/memory_local_data_source.dart';
import '../../../memories/presentation/controllers/memories_controller.dart';
import '../../../memories/presentation/screens/memories_screen.dart';
import '../../../settings/presentation/controllers/theme_controller.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

import '../widgets/footer_nav.dart';
import '../../../../common_widgets/app_topbar.dart';

class RootNav extends StatefulWidget {
  const RootNav({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  late final MemoriesController _memoriesController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _memoriesController = MemoriesController(MemoryLocalDataSource())..init();
  }

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 90,
    );

    if (picked == null || !mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaveMemoryScreen(
          imageFile: File(picked.path),
          memoriesController: _memoriesController,
        ),
      ),
    );
  }

  void _onFooterItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 0 = Map, 1 = List (Memories)
    final List<Widget> pages = [
      MapScreen(memoriesController: _memoriesController),
      MemoriesScreen(controller: _memoriesController),
    ];

    return Scaffold(
      appBar: AppTopBar(
        title: _currentIndex == 1 ? 'My Memories' : null,
        onSettingsPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SettingsScreen(themeController: widget.themeController),
            ),
          );
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: PhotoPinFooter(
        selectedIndex: _currentIndex,
        onItemTapped: _onFooterItemTapped,
        onCameraTap: _openCamera,
      ),
    );
  }
}
