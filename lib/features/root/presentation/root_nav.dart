// lib/features/root/presentation/root_nav.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/app_colors.dart';
import '../../../core/theme_controller.dart';
import '../../../generated/assets.dart';
import '../../../widgets/photo_pin_app_bar.dart';
import '../../map/presentation/map_screen.dart';
import '../../add_memory/presentation/save_memory_screen.dart';
import '../../memories/controller/memories_controller.dart';
import '../../memories/data/memory_local_data_source.dart';
import '../../memories/presentation/memories_screen.dart';
import '../../settings/presentation/settings_screen.dart';

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

    if (picked == null) return;
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaveMemoryScreen(
          imageFile: File(picked.path),
          memoriesController: _memoriesController,
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 1) {
      // Add Memory → open camera directly, keep current tab selection
      _openCamera();
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MapScreen(memoriesController: _memoriesController),
      const SizedBox.shrink(), // placeholder, never shown
      MemoriesScreen(controller: _memoriesController),
    ];

    final titles = ['PhotoPin', 'PhotoPin', 'My Memories'];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor =
        theme.bottomNavigationBarTheme.backgroundColor ??
        (isDark ? AppColors.darkBottomNavBg : AppColors.lightBottomNavBg);

    return Scaffold(
      appBar: PhotoPinAppBar(
        title: titles[_currentIndex],
        showLogo: _currentIndex != 2, // Hide logo on My Memories screen
        onSettingsTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  SettingsScreen(themeController: widget.themeController),
            ),
          );
        },
      ),
      body: IndexedStack(index: _currentIndex, children: pages),

      // 🔻 Custom bottom navigation bar
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Material(
              color: bgColor, // no system background, just this container
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      index: 0,
                      currentIndex: _currentIndex,
                      asset: Assets.svgMap,
                      label: 'My Map',
                      onTap: _onNavTap,
                    ),
                    _NavItem(
                      index: 1,
                      currentIndex: _currentIndex,
                      asset: Assets.svgPhoto,
                      label: 'Add Memory',
                      onTap: _onNavTap,
                    ),
                    _NavItem(
                      index: 2,
                      currentIndex: _currentIndex,
                      asset: Assets.svgGallary,
                      label: 'My Memories',
                      onTap: _onNavTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final String asset;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == currentIndex;
    final Color iconColor = isSelected
        ? AppColors.bottomNavSelected
        : AppColors.bottomNavUnselected;
    final Color textColor = iconColor;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              asset,
              height: 22,
              width: 22,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
