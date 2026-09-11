import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class MintyLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double fontSize;
  final bool isLight;

  const MintyLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.fontSize = 24,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF34D399),
            Color(0xFF10B981),
            Color(0xFF059669),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: AppColors.mintPrimary.withValues(alpha: 0.3),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.15),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          color: Colors.white,
          size: size * 0.58,
        ),
      ),
    );

    if (!showText) return iconWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        SizedBox(width: size * 0.28),
        Text(
          'Minty',
          style: GoogleFonts.plusJakartaSans(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: isLight ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
