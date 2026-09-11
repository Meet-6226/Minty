import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/balance_card.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/insight_card.dart';
import '../widgets/minty_logo.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/transaction_tile.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  void _showQuickActionModal(String title, String subtitle, IconData icon, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mintPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Got it',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
                      'M',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mintDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meet Alshi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'meet@minty.app',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.mintDark,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This module will be available in the next release.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentTabIndex = 0;
                });
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.mintPrimary, width: 1.5),
                foregroundColor: AppColors.mintDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder, width: 1),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  color: AppColors.textPrimary,
                                  size: 22,
                                ),
                                Positioned(
                                  top: 10,
                                  right: 11,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // User Avatar
                      GestureDetector(
                        onTap: _showProfileMenu,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.mintPrimary, width: 2),
                            color: AppColors.mintLight,
                          ),
                          child: Center(
                            child: Text(
                              'M',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
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
              const SizedBox(height: 20),

              // Greeting
              Text(
                'Good afternoon, Meet 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),

              // Main Balance Card
              const BalanceCard(
                totalBalance: '₹42,850.00',
                income: '₹65,000',
                spent: '₹22,150',
                saved: '₹14,500',
              ),
              const SizedBox(height: 20),

              // Quick Actions
              Row(
                children: [
                  QuickActionButton(
                    type: QuickActionType.expense,
                    onTap: () => _showQuickActionModal(
                      'Add Expense',
                      'Record an outgoing expense quickly.',
                      Icons.add_circle_outline_rounded,
                      const Color(0xFFE11D48),
                    ),
                  ),
                  const SizedBox(width: 12),
                  QuickActionButton(
                    type: QuickActionType.income,
                    onTap: () => _showQuickActionModal(
                      'Add Income',
                      'Record incoming funds or salary deposit.',
                      Icons.arrow_downward_rounded,
                      AppColors.mintPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  QuickActionButton(
                    type: QuickActionType.pay,
                    onTap: () => _showQuickActionModal(
                      'Quick Pay',
                      'Send money or scan UPI QR code securely.',
                      Icons.send_rounded,
                      AppColors.mintPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Savings Goal Section Header & Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Savings Goal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const SavingsGoalCard(
                title: 'MacBook Air M3',
                currentAmount: '₹58,000',
                targetAmount: '₹85,000',
                progress: 0.68,
                remainingAmount: '₹27,000 to go',
                icon: Icons.laptop_mac_rounded,
              ),
              const SizedBox(height: 24),

              // Financial Insight
              Row(
                children: [
                  Text(
                    'Insight',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const InsightCard(
                tag: 'WEEKLY HIGHLIGHT',
                title: 'You spent 14% less on food delivery this week.',
                subtitle: 'You have ₹3,200 extra buffer.',
              ),
              const SizedBox(height: 24),

              // Recent Activity Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentTabIndex = 1; // Switch to Activity tab
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'See All',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.indigoSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3 Recent Transactions
              Container(
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
                child: Column(
                  children: [
                    TransactionTile(
                      title: 'Starbucks Coffee',
                      subtitle: 'Food & Drink',
                      amount: '₹280.00',
                      isIncome: false,
                      icon: Icons.local_cafe_outlined,
                      iconBgColor: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFEA580C),
                      onTap: () => _showQuickActionModal(
                        'Starbucks Coffee',
                        'Food & Drink • Paid ₹280.00 on Today at 10:45 AM',
                        Icons.local_cafe_rounded,
                        const Color(0xFFEA580C),
                      ),
                    ),
                    const Divider(height: 1, indent: 70, endIndent: 16, color: AppColors.cardBorder),
                    TransactionTile(
                      title: 'Freelance UI Payout',
                      subtitle: 'Upwork Client',
                      amount: '₹18,500.00',
                      isIncome: true,
                      icon: Icons.work_outline_rounded,
                      iconBgColor: AppColors.mintLight,
                      iconColor: AppColors.mintDark,
                      onTap: () => _showQuickActionModal(
                        'Freelance UI Payout',
                        'Upwork Client • Received ₹18,500.00 Yesterday',
                        Icons.work_rounded,
                        AppColors.mintDark,
                      ),
                    ),
                    const Divider(height: 1, indent: 70, endIndent: 16, color: AppColors.cardBorder),
                    TransactionTile(
                      title: 'Blinkit Groceries',
                      subtitle: 'Daily Needs',
                      amount: '₹435.00',
                      isIncome: false,
                      icon: Icons.shopping_bag_outlined,
                      iconBgColor: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      onTap: () => _showQuickActionModal(
                        'Blinkit Groceries',
                        'Daily Needs • Paid ₹435.00 2 days ago',
                        Icons.shopping_bag_rounded,
                        const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;
    switch (_currentTabIndex) {
      case 0:
        currentBody = _buildHomeContent();
        break;
      case 1:
        currentBody = _buildPlaceholderTab('Activity & History', Icons.receipt_long_rounded);
        break;
      case 2:
        currentBody = _buildPlaceholderTab('Payments & UPI', Icons.send_rounded);
        break;
      case 3:
        currentBody = _buildPlaceholderTab('Insights & Analytics', Icons.insights_rounded);
        break;
      case 4:
        currentBody = _buildPlaceholderTab('My Profile & Settings', Icons.person_rounded);
        break;
      default:
        currentBody = _buildHomeContent();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: currentBody,
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
