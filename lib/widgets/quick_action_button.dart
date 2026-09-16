import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum QuickActionType { expense, income, pay }

class QuickActionButton extends StatelessWidget {
  final QuickActionType type;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;
    Color bgColor;
    Color iconColor;
    Color textColor;
    Border? border;

    switch (type) {
      case QuickActionType.expense:
        label = '+ Expense';
        icon = Icons.add_circle_outline_rounded;
        bgColor = AppColors.cardSurface;
        iconColor = const Color(0xFFE11D48);
        textColor = AppColors.textPrimary;
        border = Border.all(color: AppColors.cardBorder, width: 1.2);
        break;
      case QuickActionType.income:
        label = 'Income';
        icon = Icons.arrow_downward_rounded;
        bgColor = AppColors.cardSurface;
        iconColor = AppColors.mintPrimary;
        textColor = AppColors.textPrimary;
        border = Border.all(color: AppColors.cardBorder, width: 1.2);
        break;
      case QuickActionType.pay:
        label = 'Pay';
        icon = Icons.send_rounded;
        bgColor = AppColors.mintPrimary;
        iconColor = Colors.white;
        textColor = Colors.white;
        border = null;
        break;
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: border,
              boxShadow: type == QuickActionType.pay
                  ? [
                      BoxShadow(
                        color: AppColors.mintPrimary.withValues(alpha: 0.32),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x06172033),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: type == QuickActionType.pay
                        ? Colors.white.withValues(alpha: 0.2)
                        : (type == QuickActionType.expense
                            ? const Color(0xFFFFF1F2)
                            : AppColors.mintLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
