import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/insights_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/charts/category_pie_chart.dart';
import '../widgets/charts/income_expense_chart.dart';
import 'budgets_screen.dart';
import 'monthly_summary_screen.dart';
import 'recurring_expenses_screen.dart';
import 'round_off_wallet_screen.dart';
import 'savings_goals_screen.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(insightsPeriodProvider);
    final activeDate = ref.watch(activeInsightsDateProvider);
    final analyticsAsync = ref.watch(activeMonthAnalyticsProvider);
    final prevAnalyticsAsync = ref.watch(previousMonthAnalyticsProvider);
    final insightsAsync = ref.watch(financialInsightsProvider);

    final monthLabel = DateFormat('MMMM yyyy').format(activeDate);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Insights & Analytics',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_outlined,
                color: AppColors.textPrimary),
            tooltip: 'Monthly Summary',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MonthlySummaryScreen(initialMonth: activeDate),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Period Switcher: "This Month" vs "Last Month"
                  _buildPeriodSelector(ref, period),
                  const SizedBox(height: 16),

                  // Analytics Data Binding
                  analyticsAsync.when(
                    data: (data) {
                      final prevData = prevAnalyticsAsync.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overview Financial Health Card
                          _buildOverviewCard(context, data, monthLabel),
                          const SizedBox(height: 16),

                          // 2x Key Metrics Row
                          _buildMetricCardsRow(data),
                          const SizedBox(height: 20),

                          // Income vs Expense Chart
                          IncomeExpenseChart(
                            income: data.totalIncome,
                            expense: data.totalExpense,
                            prevIncome: prevData?.totalIncome ?? 0.0,
                            prevExpense: prevData?.totalExpense ?? 0.0,
                            showComparison: true,
                          ),
                          const SizedBox(height: 16),

                          // Category Spending Donut Chart
                          CategoryPieChart(
                            categorySpendings: data.categorySpendings,
                            totalExpense: data.totalExpense,
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'Loading financial analytics...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Text(
                        'Failed to load analytics: $err',
                        style:
                            GoogleFonts.plusJakartaSans(color: AppColors.error),
                      ),
                    ),
                  ),

                  // Financial Observations & Rule-Based Insights Section
                  Text(
                    'Smart Financial Insights',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time observations from your transaction data',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  insightsAsync.when(
                    data: (insights) => _buildInsightsList(insights),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Analyzing observations...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    error: (err, stack) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 28),

                  // Financial Planning Hub Links
                  Text(
                    'Financial Planning Hub',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildPlanningShortcut(
                    context: context,
                    title: 'Category Budgets',
                    subtitle: 'Set limits and monitor remaining balance',
                    icon: Icons.pie_chart_outline_rounded,
                    iconColor: AppColors.indigoSecondary,
                    iconBgColor: AppColors.indigoLight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BudgetsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildPlanningShortcut(
                    context: context,
                    title: 'Savings Goals',
                    subtitle: 'Track goal targets and contribute funds',
                    icon: Icons.savings_outlined,
                    iconColor: AppColors.mintDark,
                    iconBgColor: AppColors.mintLight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SavingsGoalsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildPlanningShortcut(
                    context: context,
                    title: 'Recurring Subscriptions & Bills',
                    subtitle: 'Track active monthly commitments',
                    icon: Icons.autorenew_rounded,
                    iconColor: const Color(0xFF6366F1),
                    iconBgColor: const Color(0xFFEEF2FF),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RecurringExpensesScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildPlanningShortcut(
                    context: context,
                    title: 'Round-Off Spare Change Wallet',
                    subtitle: 'View micro-savings accumulated from payments',
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.mintDark,
                    iconBgColor: AppColors.mintLight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RoundOffWalletScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(WidgetRef ref, InsightsPeriod period) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodTab(
              label: 'This Month',
              isSelected: period == InsightsPeriod.thisMonth,
              onTap: () => ref
                  .read(insightsPeriodProvider.notifier)
                  .selectThisMonth(),
            ),
          ),
          Expanded(
            child: _buildPeriodTab(
              label: 'Last Month',
              isSelected: period == InsightsPeriod.lastMonth,
              onTap: () => ref
                  .read(insightsPeriodProvider.notifier)
                  .selectLastMonth(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0A172033),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
      BuildContext context, MonthlyAnalyticsData data, String monthLabel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF115E59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.28),
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
                    monthLabel.toUpperCase(),
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
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MonthlySummaryScreen(
                          initialMonth: data.monthDate),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Full Report',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Total Outflow',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${NumberFormat('#,##0.00').format(data.totalExpense)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Savings Rate: ${data.savingsRate.toStringAsFixed(0)}%',
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
                  '${data.transactionCount} transactions',
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

  Widget _buildMetricCardsRow(MonthlyAnalyticsData data) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.mintLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_downward_rounded,
                          size: 13, color: AppColors.mintDark),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Income',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '₹${NumberFormat('#,##0').format(data.totalIncome)}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.savings_outlined,
                          size: 13, color: AppColors.mintDark),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Net Saved',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '₹${NumberFormat('#,##0').format(data.netSavings > 0 ? data.netSavings : 0.0)}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: data.netSavings >= 0
                        ? AppColors.mintDark
                        : const Color(0xFFF43F5E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsList(List<FinancialInsight> insights) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: insights.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = insights[index];
        Color badgeBg;
        Color badgeText;
        Color iconBg;
        Color iconColor;

        switch (item.type) {
          case InsightType.positive:
            badgeBg = const Color(0xFFF0FDF4);
            badgeText = AppColors.mintDark;
            iconBg = AppColors.mintLight;
            iconColor = AppColors.mintDark;
            break;
          case InsightType.warning:
            badgeBg = const Color(0xFFFFFBEB);
            badgeText = const Color(0xFFB45309);
            iconBg = const Color(0xFFFEF3C7);
            iconColor = const Color(0xFFD97706);
            break;
          case InsightType.info:
            badgeBg = const Color(0xFFEEF2FF);
            badgeText = const Color(0xFF4F46E5);
            iconBg = AppColors.indigoLight;
            iconColor = AppColors.indigoSecondary;
            break;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04172033),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.tag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: badgeText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
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
      },
    );
  }

  Widget _buildPlanningShortcut({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
