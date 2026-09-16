import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/insights_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/icon_helper.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategorySpending> categorySpendings;
  final double totalExpense;

  const CategoryPieChart({
    super.key,
    required this.categorySpendings,
    required this.totalExpense,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  static const List<Color> _palette = [
    Color(0xFF0D9488), // Mint / Teal
    Color(0xFF6366F1), // Indigo
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF97316), // Orange
    Color(0xFF64748B), // Slate
  ];

  Color _getColorForIndex(int index) {
    return _palette[index % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
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
                      'Spending by Category',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Expense distribution breakdown',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardSurfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.categorySpendings.length} categories',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.categorySpendings.isEmpty || widget.totalExpense <= 0)
            Container(
              height: 160,
              alignment: Alignment.center,
              child: Text(
                'No expenses logged for this month',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else ...[
            // Donut Chart Container with Center Summary
            SizedBox(
              height: 190,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      startDegreeOffset: -90,
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 3,
                      centerSpaceRadius: 55,
                      sections: _buildPieSections(),
                    ),
                  ),
                  // Center Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _touchedIndex >= 0 &&
                                _touchedIndex < widget.categorySpendings.length
                            ? widget.categorySpendings[_touchedIndex].category.name
                            : 'Total Spent',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _touchedIndex >= 0 &&
                                _touchedIndex < widget.categorySpendings.length
                            ? '₹${NumberFormat('#,##0').format(widget.categorySpendings[_touchedIndex].amount)}'
                            : '₹${NumberFormat('#,##0').format(widget.totalExpense)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_touchedIndex >= 0 &&
                          _touchedIndex < widget.categorySpendings.length)
                        Text(
                          '${widget.categorySpendings[_touchedIndex].percentage.toStringAsFixed(1)}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _getColorForIndex(_touchedIndex),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 12),
            // Category List Breakdown
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.categorySpendings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = widget.categorySpendings[index];
                final color = _getColorForIndex(index);
                final isSelected = _touchedIndex == index;
                final iconData =
                    CategoryIconHelper.getIconData(item.category.icon);

                return InkWell(
                  onTap: () {
                    setState(() {
                      _touchedIndex = _touchedIndex == index ? -1 : index;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(iconData, color: color, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.category.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${NumberFormat('#,##0').format(item.amount)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${item.percentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    return List.generate(widget.categorySpendings.length, (i) {
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 28.0 : 22.0;
      final item = widget.categorySpendings[i];
      final color = _getColorForIndex(i);

      return PieChartSectionData(
        color: color,
        value: item.amount,
        title: '',
        radius: radius,
        badgeWidget: null,
      );
    });
  }
}
