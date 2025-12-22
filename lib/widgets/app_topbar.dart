import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSettingsPressed;
  final Widget? actionButton;

  const AppTopBar({
    super.key,
    this.onSettingsPressed,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 4,
            offset: Offset(0, 2),
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
              // 1. LEFT SPACER (Increased to 56 to balance the new bigger icon)
              const SizedBox(width: 56),

              // 2. CENTER: Title + SVG Pin
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'PhotoPin',
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 32,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 18,
                      height: 32,
                      child: SvgPicture.string(
                        _pinSvgData,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. RIGHT: Gear Icon
              Container(
                // Increased container width to 56 so the icon has room
                width: 56,
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onSettingsPressed,
                  child: actionButton ?? SizedBox(
                    // UPDATED: Increased size to 46 (Big & Clear)
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

const String _pinSvgData = '''
<svg width="18" height="32" viewBox="0 0 18 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M7 19.8088V29.6019L8.37625 31.6656C8.67313 32.1106 9.3275 32.1106 9.62438 31.6656L11 29.6019V19.8088C10.3506 19.9288 9.68375 20 9 20C8.31625 20 7.64937 19.9288 7 19.8088ZM9 0C4.02938 0 0 4.02938 0 9C0 13.9706 4.02938 18 9 18C13.9706 18 18 13.9706 18 9C18 4.02938 13.9706 0 9 0ZM9 4.75C6.65625 4.75 4.75 6.65625 4.75 9C4.75 9.41375 4.41375 9.75 4 9.75C3.58625 9.75 3.25 9.41375 3.25 9C3.25 5.82938 5.83 3.25 9 3.25C9.41375 3.25 9.75 3.58625 9.75 4C9.75 4.41375 9.41375 4.75 9 4.75Z" fill="#FF6F61"/>
</svg>
''';
