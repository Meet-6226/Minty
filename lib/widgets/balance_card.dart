import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'metric_card.dart';

class BalanceCard extends StatelessWidget {
  final String totalBalance;
  final String income;
  final String spent;
  final String saved;

  const BalanceCard({
    super.key,
    this.totalBalance = '₹42,850.00',
    this.income = '₹65,000',
    this.spent = '₹22,150',
    this.saved = '₹14,500',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A172033),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'TOTAL AVAILABLE BALANCE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mintLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.mintPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Live',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mintDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              totalBalance,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              MetricCard(
                title: 'Income',
                amount: income,
                type: MetricType.income,
              ),
              const SizedBox(width: 8),
              MetricCard(
                title: 'Spent',
                amount: spent,
                type: MetricType.spent,
              ),
              const SizedBox(width: 8),
              MetricCard(
                title: 'Saved',
                amount: saved,
                type: MetricType.saved,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
