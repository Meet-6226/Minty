import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/database_providers.dart';
import '../providers/insights_providers.dart';
import '../theme/app_colors.dart';
import '../utils/icon_helper.dart';
import '../widgets/balance_card.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/insight_card.dart';
import '../widgets/minty_logo.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/transaction_tile.dart';
import 'activity_screen.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import 'insights_screen.dart';
import 'login_screen.dart';
import 'pay_screen.dart';
import 'profile_screen.dart';
import 'savings_goals_screen.dart';
import 'transaction_details_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTabIndex = 0;

  void _handleLogout() {
    ref.read(authProvider.notifier).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: AppColors.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.mintLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.savings_outlined, color: AppColors.mintDark, size: 20),
                  ),
                  title: Text(
                    'Goal Update: MacBook Air M3',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'You are 68% towards your goal. Keep it up!',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileMenu() {
    final user = ref.read(authProvider).user;
    final userName = user?.name ?? 'Meet Alshi';
    final userEmail = user?.email ?? 'meet@minty.app';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'M';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: AppColors.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.mintLight,
                      child: Text(
                        userInitial,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mintDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            userEmail,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: Text(
                    'Log Out',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final user = ref.watch(authProvider).user;
    final userName = user?.name ?? 'Meet Alshi';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'M';

    final totalBalanceAsync = ref.watch(totalAccountBalanceProvider);
    final monthIncomeAsync = ref.watch(currentMonthIncomeProvider);
    final monthExpenseAsync = ref.watch(currentMonthExpenseProvider);
    final totalSavingsAsync = ref.watch(totalSavingsProvider);
    final recentTransactionsAsync =
        ref.watch(recentTransactionsWithDetailsProvider);

    final totalBalanceStr = totalBalanceAsync.maybeWhen(
      data: (val) => '₹${NumberFormat('#,##0.00').format(val)}',
      orElse: () => '₹0.00',
    );
    final incomeStr = monthIncomeAsync.maybeWhen(
      data: (val) => '₹${NumberFormat('#,##0').format(val)}',
      orElse: () => '₹0',
    );
    final spentStr = monthExpenseAsync.maybeWhen(
      data: (val) => '₹${NumberFormat('#,##0').format(val)}',
      orElse: () => '₹0',
    );
    final savedStr = totalSavingsAsync.maybeWhen(
      data: (val) => '₹${NumberFormat('#,##0').format(val)}',
      orElse: () => '₹0',
    );

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MintyLogo(size: 34, fontSize: 18),
                    Row(
                      children: [
                        // Notification Icon with badge
                        Material(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: _showNotificationsSheet,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.cardBorder, width: 1),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.textPrimary,
                                    size: 20,
                                  ),
                                  Positioned(
                                    top: 9,
                                    right: 9,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Avatar Profile Icon
                        GestureDetector(
                          onTap: _showProfileMenu,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.mintLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.mintPrimary, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                userInitial,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mintDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Balance Card
                BalanceCard(
                  totalBalance: totalBalanceStr,
                  income: incomeStr,
                  spent: spentStr,
                  saved: savedStr,
                ),
                const SizedBox(height: 16),

                // Quick Actions
                Row(
                  children: [
                    QuickActionButton(
                      type: QuickActionType.expense,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddExpenseScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    QuickActionButton(
                      type: QuickActionType.income,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddIncomeScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    QuickActionButton(
                      type: QuickActionType.pay,
                      onTap: () {
                        setState(() {
                          _currentTabIndex = 2; // Switch to Pay tab
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Savings Goal Section Header & Live Card
                () {
                  final goalDetails =
                      ref.watch(primarySavingsGoalWithDetailsProvider).asData?.value;
                  final title =
                      goalDetails?.goal.name ?? 'Set a Savings Goal';
                  final currentAmount = goalDetails != null
                      ? '₹${NumberFormat('#,##0').format(goalDetails.savedAmount)}'
                      : '₹0';
                  final targetAmount = goalDetails != null
                      ? '₹${NumberFormat('#,##0').format(goalDetails.goal.targetAmount)}'
                      : '₹0';
                  final progress = goalDetails?.progress ?? 0.0;
                  final remainingAmount = goalDetails != null
                      ? '₹${NumberFormat('#,##0').format(goalDetails.remaining)}'
                      : '₹0';

                  return SavingsGoalCard(
                    title: title,
                    currentAmount: currentAmount,
                    targetAmount: targetAmount,
                    progress: progress,
                    remainingAmount: remainingAmount,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavingsGoalsScreen(),
                        ),
                      );
                    },
                  );
                }(),
                const SizedBox(height: 20),

                // Financial Insight Section Header & Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Financial Insight',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentTabIndex = 3; // Switch to Insights tab
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'See all',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mintPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                () {
                  final insightsAsync = ref.watch(financialInsightsProvider);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentTabIndex = 3; // Switch to Insights tab
                      });
                    },
                    child: insightsAsync.when(
                      data: (insights) {
                        if (insights.isNotEmpty) {
                          final top = insights.first;
                          return InsightCard(
                            tag: top.tag,
                            title: top.title,
                            subtitle: top.subtitle,
                          );
                        }
                        return const InsightCard(
                          tag: 'SMART TIP',
                          title:
                              'Track your regular purchases to unlock personalized insights.',
                          subtitle:
                              'Add daily expenses or link recurring bills to monitor your spending habits.',
                        );
                      },
                      loading: () => const InsightCard(
                        tag: 'INSIGHT',
                        title: 'Analyzing your monthly transactions...',
                        subtitle: 'Calculating your top category breakdown.',
                      ),
                      error: (_, _) => const InsightCard(
                        tag: 'INSIGHT',
                        title: 'Spend smarter with Minty.',
                        subtitle:
                            'Track expenses regularly to view detailed monthly summaries.',
                      ),
                    ),
                  );
                }(),
                const SizedBox(height: 20),

                // Recent Activity Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Recent Activity',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentTabIndex = 1; // Switch to Activity tab
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'See All',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mintPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Recent Transactions List from Drift Database
                recentTransactionsAsync.when(
                  loading: () => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.cardBorder, width: 1),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.mintPrimary),
                      ),
                    ),
                  ),
                  error: (err, _) => const SizedBox.shrink(),
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: AppColors.cardBorder, width: 1),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.receipt_long_outlined,
                                  size: 32, color: AppColors.textTertiary),
                              const SizedBox(height: 8),
                              Text(
                                'No recent transactions',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06172033),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 70,
                          endIndent: 16,
                          color: AppColors.cardBorder,
                        ),
                        itemBuilder: (context, index) {
                          final item = transactions[index];
                          final tx = item.transaction;
                          final cat = item.category;
                          final acc = item.account;
                          final isIncome = tx.type == 'income';
                          final style = CategoryIconHelper.getStyle(
                            cat.icon,
                            isIncome: isIncome,
                          );
                          final formattedAmount =
                              NumberFormat('#,##0.00').format(tx.amount);

                          return TransactionTile(
                            title: tx.description.isNotEmpty
                                ? tx.description
                                : cat.name,
                            subtitle: '${cat.name} • ${acc.name}',
                            amount: formattedAmount,
                            isIncome: isIncome,
                            icon: style.icon,
                            iconBgColor: style.backgroundColor,
                            iconColor: style.foregroundColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionDetailsScreen(
                                    transactionId: tx.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildHomeContent(),
          const ActivityScreen(),
          const PayScreen(),
          const InsightsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: MintyBottomNav(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
    );
  }
}
