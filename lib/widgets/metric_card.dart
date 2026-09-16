import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum MetricType { income, spent, saved }

class MetricCard extends StatelessWidget {
  final String title;
  final String amount;
  final MetricType type;

  const MetricCard({
    super.key,
    required this.title,
    required this.amount,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color iconBg;
    Color iconColor;
    IconData iconData;

    switch (type) {
      case MetricType.income:
        iconBg = const Color(0xFFECFDF5);
        iconColor = AppColors.mintPrimary;
        iconData = Icons.south_west_rounded;
        break;
      case MetricType.spent:
        iconBg = const Color(0xFFFEF2F2);
        iconColor = const Color(0xFFEF4444);
        iconData = Icons.north_east_rounded;
        break;
      case MetricType.saved:
        iconBg = const Color(0xFFEEF2FF);
        iconColor = AppColors.indigoSecondary;
        iconData = Icons.savings_outlined;
        break;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardSurfaceSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.cardBorder.withValues(alpha: 0.6), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    size: 12,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
