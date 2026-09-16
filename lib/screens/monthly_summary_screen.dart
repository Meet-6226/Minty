import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/insights_providers.dart';
import '../theme/app_colors.dart';
import '../utils/icon_helper.dart';
import '../widgets/charts/income_expense_chart.dart';
import '../widgets/charts/category_pie_chart.dart';

class MonthlySummaryScreen extends ConsumerStatefulWidget {
  final DateTime? initialMonth;

  const MonthlySummaryScreen({super.key, this.initialMonth});

  @override
  ConsumerState<MonthlySummaryScreen> createState() =>
      _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends ConsumerState<MonthlySummaryScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = widget.initialMonth ?? DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(monthlyAnalyticsProvider(_selectedMonth));
    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Monthly Summary',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: analyticsAsync.when(
          data: (data) => _buildContent(context, data, monthName),
          loading: () => const Center(
            child: Text(
              'Loading monthly summary...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error loading monthly summary: $err',
              style: GoogleFonts.plusJakartaSans(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, MonthlyAnalyticsData data, String monthName) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Selector Bar
              _buildMonthNavigator(monthName),
              const SizedBox(height: 16),

              // Hero Monthly Financial Health Card
              _buildHeroReportCard(data, monthName),
              const SizedBox(height: 16),

              // 4-Card Key Metrics Grid
              _buildMetricsGrid(data),
              const SizedBox(height: 16),

              // Month-over-Month Comparison Card
              if (data.prevMonthIncome > 0 || data.prevMonthExpense > 0) ...[
                _buildMonthOverMonthCard(data),
                const SizedBox(height: 16),
              ],

              // Top Spending Category Banner
              if (data.topCategory != null) ...[
                _buildTopCategoryCard(data.topCategory!),
                const SizedBox(height: 16),
              ],

              // Charts
              IncomeExpenseChart(
                income: data.totalIncome,
                expense: data.totalExpense,
                prevIncome: data.prevMonthIncome,
                prevExpense: data.prevMonthExpense,
                showComparison: true,
              ),
              const SizedBox(height: 16),

              CategoryPieChart(
                categorySpendings: data.categorySpendings,
                totalExpense: data.totalExpense,
              ),
              const SizedBox(height: 16),

              // Round-Off Savings Box
              _buildRoundOffSummaryCard(data),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthNavigator(String monthName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded,
                color: AppColors.textPrimary),
            onPressed: _previousMonth,
            splashRadius: 20,
          ),
          Text(
            monthName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textPrimary),
            onPressed: _nextMonth,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroReportCard(MonthlyAnalyticsData data, String monthName) {
    final isSurplus = data.netSavings >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSurplus
              ? [const Color(0xFF0F766E), const Color(0xFF134E4A)]
              : [const Color(0xFFBE123C), const Color(0xFF881337)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isSurplus ? const Color(0xFF0F766E) : const Color(0xFFBE123C))
                .withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    monthName.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSurplus
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isSurplus ? 'Net Surplus' : 'Net Deficit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            isSurplus ? 'Net Monthly Savings' : 'Net Monthly Deficit',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${NumberFormat('#,##0.00').format(data.netSavings.abs())}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Progress and Savings Rate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Savings Rate: ${data.savingsRate.toStringAsFixed(1)}%',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${data.transactionCount} transactions logged',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(MonthlyAnalyticsData data) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Total Income',
            amount: '₹${NumberFormat('#,##0').format(data.totalIncome)}',
            icon: Icons.arrow_downward_rounded,
            iconColor: AppColors.mintDark,
            iconBgColor: AppColors.mintLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            title: 'Total Expenses',
            amount: '₹${NumberFormat('#,##0').format(data.totalExpense)}',
            icon: Icons.arrow_upward_rounded,
            iconColor: const Color(0xFFF43F5E),
            iconBgColor: const Color(0xFFFFF1F2),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthOverMonthCard(MonthlyAnalyticsData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Month-over-Month Comparison',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Income Change
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurfaceSecondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income Shift',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            (data.incomeChangePct ?? 0) >= 0
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 14,
                            color: (data.incomeChangePct ?? 0) >= 0
                                ? AppColors.mintDark
                                : const Color(0xFFF43F5E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.incomeChangePct != null
                                ? '${data.incomeChangePct!.abs().toStringAsFixed(1)}%'
                                : '0.0%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: (data.incomeChangePct ?? 0) >= 0
                                  ? AppColors.mintDark
                                  : const Color(0xFFF43F5E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Expense Change
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurfaceSecondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expense Shift',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            (data.expenseChangePct ?? 0) <= 0
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            size: 14,
                            color: (data.expenseChangePct ?? 0) <= 0
                                ? AppColors.mintDark
                                : const Color(0xFFF43F5E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.expenseChangePct != null
                                ? '${data.expenseChangePct!.abs().toStringAsFixed(1)}%'
                                : '0.0%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: (data.expenseChangePct ?? 0) <= 0
                                  ? AppColors.mintDark
                                  : const Color(0xFFF43F5E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoryCard(CategorySpending topCat) {
    final iconData = CategoryIconHelper.getIconData(topCat.category.icon);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: const Color(0xFFF43F5E), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'TOP EXPENSE CATEGORY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: const Color(0xFFF43F5E),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  topCat.category.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${NumberFormat('#,##0').format(topCat.amount)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${topCat.percentage.toStringAsFixed(1)}% of total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundOffSummaryCard(MonthlyAnalyticsData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.mintPrimary.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mintPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.savings_outlined,
              color: AppColors.mintDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Round-Off Wallet Savings',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mintDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${NumberFormat('#,##0.00').format(data.roundOffSaved)} saved automatically this month.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
