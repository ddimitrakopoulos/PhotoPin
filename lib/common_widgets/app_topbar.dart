import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSettingsPressed;
  final Widget? actionButton;
  final String? title;
  final bool centerTitle;

  const AppTopBar({
    super.key,
    this.onSettingsPressed,
    this.actionButton,
    this.title,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Detect Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Define Colors based on Theme
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white.withAlpha(10) : const Color(0x19000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Spacer
              const SizedBox(width: 56),

              // Title + Pin (centered)
              Expanded(
                child: title != null && title != 'PhotoPin'
                    ? Center(
                        child: Text(
                          title!,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 32,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'PhotoPin',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 32,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 18,
                            height: 32,
                            child: SvgPicture.asset(
                              'assets/svg/pin.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
              ),

              // Right: Gear Icon
              Container(
                width: 56,
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onSettingsPressed,
                  child: actionButton ??
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Image.asset(
                      'assets/gear.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
