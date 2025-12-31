import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PhotoPinFooter extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback onCameraTap;

  const PhotoPinFooter({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onCameraTap,
  });

  // Static colors
  static const Color activeColor = Color(0xFFFF6F61); // Coral Orange

  @override
  Widget build(BuildContext context) {
    // 1. Detect Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Define Dynamic Colors
    final backgroundColor = isDark ? Colors.black : Colors.white;
    // Dark mode border needs to be subtle grey, Light mode is standard grey
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0);
    // Inactive icons need to be visible on black (so lighter grey)
    final inactiveColor = const Color(0xD3D3D3D3);
    final centerBtnBg = const Color(0xD3D3D3D3); // Always light grey

    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(width: 1, color: borderColor),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : const Color(0x19000000),
            blurRadius: 6,
            offset: const Offset(0, -1),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. LEFT: Map Button
          IconButton(
            icon: SvgPicture.asset(
              'assets/svg/map.svg',
              width: 60,
              height: 60,
              colorFilter: ColorFilter.mode(
                selectedIndex == 0 ? activeColor : inactiveColor,
                BlendMode.srcIn,
              ),
            ),
            iconSize: 60,
            onPressed: () => onItemTapped(0),
          ),

          // 2. CENTER: Add Photo Button
          GestureDetector(
            onTap: onCameraTap,
            child: Container(
              width: 60,
              height: 60,
              decoration: ShapeDecoration(
                color: centerBtnBg,
                shape: const OvalBorder(),
                shadows: [
                  BoxShadow(
                    color: const Color(0x3F000000),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  isDark ? 'assets/svg/camera_simple_dark.svg' : 'assets/svg/camera_simple.svg'
                ),
              ),
            ),
          ),

          // 3. RIGHT: List Button
          IconButton(
            icon: SvgPicture.asset(
              'assets/svg/memories.svg',
              width: 60,
              height: 60,
              colorFilter: ColorFilter.mode(
                selectedIndex == 1 ? activeColor : inactiveColor,
                BlendMode.srcIn,
              ),
            ),
            iconSize: 60,
            onPressed: () => onItemTapped(1),
          ),
        ],
      ),
    );
  }
}
