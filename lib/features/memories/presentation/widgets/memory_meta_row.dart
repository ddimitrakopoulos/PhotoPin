import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MemoryMetaRow extends StatelessWidget {
  const MemoryMetaRow({
    super.key,
    required this.iconAsset,
    required this.text,
    this.iconColor,
  });

  final String iconAsset;
  final String text;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        SvgPicture.asset(
          iconAsset,
          height: 16,
          width: 16,
          colorFilter: ColorFilter.mode(
            iconColor ??
                (isDark ? const Color(0xFFFF5A5F) : const Color(0xFFFF5A5F)),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? Colors.white.withAlpha(230)
                  : const Color(0xFF444444),
            ),
          ),
        ),
      ],
    );
  }
}
