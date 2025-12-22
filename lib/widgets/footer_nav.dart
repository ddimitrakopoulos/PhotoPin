import 'package:flutter/material.dart';

class PhotoPinFooter extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const PhotoPinFooter({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // Colors
  static const Color activeColor = Color(0xFFFF6F61); // Coral Orange
  static const Color inactiveColor = Color(0xFFD3D3D3); // Light Grey
  static const Color centerBgColor = Color(0xFFD3D3D3); // #D3D3D3
  static const Color borderColor = Color(0xFFE0E0E0); // Border

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(width: 1, color: borderColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, -1),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. LEFT: Map Button
          IconButton(
            icon: const Icon(Icons.map),
            iconSize: 60,
            color: selectedIndex == 0 ? activeColor : inactiveColor,
            onPressed: () => onItemTapped(0),
          ),

          // 2. CENTER: Add Photo Button (Camera with Plus)
          Container(
            width: 56,
            height: 56,
            decoration: const ShapeDecoration(
              color: centerBgColor,
              shape: OvalBorder(),
              shadows: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: IconButton(
              // CHANGED ICON HERE:
              icon: const Icon(Icons.add_a_photo),
              color: Colors.white,
              // Size 22 matches your 22.40px requirement closely
              iconSize: 22,
              onPressed: () {
                print("Add Photo Action");
              },
            ),
          ),

          // 3. RIGHT: List Button
          IconButton(
            icon: const Icon(Icons.list),
            iconSize: 60,
            color: selectedIndex == 1 ? activeColor : inactiveColor,
            onPressed: () => onItemTapped(1),
          ),
        ],
      ),
    );
  }
}
