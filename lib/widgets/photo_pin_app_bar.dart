import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../generated/assets.dart';

class PhotoPinAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PhotoPinAppBar({
    super.key, 
    required this.title, 
    this.onSettingsTap,
    this.showLogo = true,
  });

  final String title;
  final VoidCallback? onSettingsTap;
  final bool showLogo;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        color: theme.appBarTheme.backgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Invisible spacer to balance the settings button
            const SizedBox(width: 40),
            // Centered logo and text
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.appBarTheme.titleTextStyle?.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                if (showLogo) ...[
                  const SizedBox(width: 8),
                  SvgPicture.asset(Assets.svgLogo, height: 28),
                ],
              ],
            ),
            // Settings button
            GestureDetector(
              onTap: onSettingsTap,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141414) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(0xffDEDEDE)),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  Assets.svgGear,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
