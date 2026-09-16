import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';

class IncomeExpenseChart extends StatelessWidget {
  final double income;
  final double expense;
  final double prevIncome;
  final double prevExpense;
  final bool showComparison;

  const IncomeExpenseChart({
    super.key,
    required this.income,
    required this.expense,
    this.prevIncome = 0.0,
    this.prevExpense = 0.0,
    this.showComparison = true,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = [income, expense, prevIncome, prevExpense]
        .reduce((curr, next) => curr > next ? curr : next);
    final maxY = maxVal > 0 ? (maxVal * 1.25) : 1000.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06172033),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash Flow Overview',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Income vs Expenses',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Legend
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendItem(
                    color: AppColors.mintPrimary,
                    label: 'Income',
                  ),
                  const SizedBox(width: 8),
                  _buildLegendItem(
                    color: const Color(0xFFF43F5E),
                    label: 'Expense',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: (income == 0 && expense == 0 && prevIncome == 0 && prevExpense == 0)
                ? Center(
                    child: Text(
                      'No transactions to display',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.textPrimary,
                          tooltipPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final isIncome = rodIndex == 0;
                            final label = isIncome ? 'Income' : 'Expense';
                            final value = NumberFormat('#,##0').format(rod.toY);
                            return BarTooltipItem(
                              '$label: ₹$value',
                              GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 || value == maxY) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                _formatCompact(value),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              String title = '';
                              if (showComparison && (prevIncome > 0 || prevExpense > 0)) {
                                if (value == 0) title = 'Last Month';
                                if (value == 1) title = 'This Month';
                              } else {
                                if (value == 0) title = 'Selected Month';
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY / 3,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.cardBorder.withValues(alpha: 0.8),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                      ),
                      barGroups: _buildBarGroups(showComparison && (prevIncome > 0 || prevExpense > 0)),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          // Sub-footer metrics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardSurfaceSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_downward_rounded,
                          color: AppColors.mintDark, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '₹${NumberFormat('#,##0').format(income)}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mintDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 14,
                  color: AppColors.cardBorder,
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_upward_rounded,
                          color: Color(0xFFF43F5E), size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '₹${NumberFormat('#,##0').format(expense)}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF43F5E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 14,
                  color: AppColors.cardBorder,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      income >= expense
                          ? '+₹${NumberFormat('#,##0').format(income - expense)}'
                          : '-₹${NumberFormat('#,##0').format(expense - income)}',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: income >= expense
                            ? AppColors.mintDark
                            : const Color(0xFFF43F5E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(bool includeComparison) {
    if (includeComparison) {
      return [
        BarChartGroupData(
          x: 0,
          barsSpace: 8,
          barRods: [
            BarChartRodData(
              toY: prevIncome,
              color: AppColors.mintPrimary.withValues(alpha: 0.5),
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            BarChartRodData(
              toY: prevExpense,
              color: const Color(0xFFF43F5E).withValues(alpha: 0.5),
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barsSpace: 8,
          barRods: [
            BarChartRodData(
              toY: income,
              color: AppColors.mintPrimary,
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            BarChartRodData(
              toY: expense,
              color: const Color(0xFFF43F5E),
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
      ];
    } else {
      return [
        BarChartGroupData(
          x: 0,
          barsSpace: 12,
          barRods: [
            BarChartRodData(
              toY: income,
              color: AppColors.mintPrimary,
              width: 24,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            BarChartRodData(
              toY: expense,
              color: const Color(0xFFF43F5E),
              width: 24,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
      ];
    }
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatCompact(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(0)}k';
    }
    return '₹${value.toInt()}';
  }
}
