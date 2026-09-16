import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_providers.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import 'budgets_screen.dart';
import 'category_management_screen.dart';
import 'login_screen.dart';
import 'monthly_summary_screen.dart';
import 'recurring_expenses_screen.dart';
import 'round_off_wallet_screen.dart';
import 'savings_goals_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final bool showBackButton;

  const ProfileScreen({
    super.key,
    this.showBackButton = false,
  });

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final cardBg =
            isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
        final textPri =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final textSec =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Log Out?',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: textPri,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of Minty? Your local financial records and database will remain safely stored on this device.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: textSec,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: textSec,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(authProvider.notifier).logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  void _showAppearanceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {

        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final cardBg =
            isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
        final textPri =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final textSec =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        final borderCol =
            isDark ? AppColors.darkCardBorder : AppColors.cardBorder;

        return Material(
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            side: BorderSide(color: borderCol),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SafeArea(
            child: Consumer(
              builder: (context, ref, child) {
                final activeMode = ref.watch(themeModeProvider);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardBorder
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Appearance',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPri,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: textSec),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildThemeOption(
                      title: 'System Default',
                      subtitle: 'Match system device settings',
                      icon: Icons.brightness_auto_rounded,
                      mode: ThemeMode.system,
                      selectedMode: activeMode,
                      textPri: textPri,
                      textSec: textSec,
                      isDark: isDark,
                      onTap: () {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(ThemeMode.system);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildThemeOption(
                      title: 'Light Mode',
                      subtitle: 'Clean white surfaces with mint accents',
                      icon: Icons.light_mode_rounded,
                      mode: ThemeMode.light,
                      selectedMode: activeMode,
                      textPri: textPri,
                      textSec: textSec,
                      isDark: isDark,
                      onTap: () {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(ThemeMode.light);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildThemeOption(
                      title: 'Dark Mode',
                      subtitle: 'Deep dark navy with mint glow',
                      icon: Icons.dark_mode_rounded,
                      mode: ThemeMode.dark,
                      selectedMode: activeMode,
                      textPri: textPri,
                      textSec: textSec,
                      isDark: isDark,
                      onTap: () {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(ThemeMode.dark);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode selectedMode,
    required Color textPri,
    required Color textSec,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == selectedMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkMintLight : AppColors.mintLight)
              : (isDark
                  ? AppColors.darkCardSurfaceSecondary
                  : AppColors.cardSurfaceSecondary),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.mintPrimary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.mintPrimary
                    : (isDark ? AppColors.darkCardSurface : Colors.white),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                size: 20,
              ),
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
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: textPri,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: textSec,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.mintPrimary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  void _showCurrencySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final cardBg =
            isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
        final textPri =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final textSec =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        final borderCol =
            isDark ? AppColors.darkCardBorder : AppColors.cardBorder;

        return Material(
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            side: BorderSide(color: borderCol),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SafeArea(
            child: Consumer(
              builder: (context, ref, child) {
                final currentCurrency = ref.watch(currencyProvider);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardBorder
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Currency',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPri,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: textSec),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Primary currency for balances, transactions, and budgets',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: textSec,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...CurrencyConfig.supportedCurrencies.map((curr) {
                      final isSelected = curr.code == currentCurrency.code;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(currencyProvider.notifier)
                                .setCurrency(curr);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.darkMintLight
                                      : AppColors.mintLight)
                                  : (isDark
                                      ? AppColors.darkCardSurfaceSecondary
                                      : AppColors.cardSurfaceSecondary),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.mintPrimary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  curr.flag,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${curr.name} (${curr.symbol})',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: textPri,
                                        ),
                                      ),
                                      Text(
                                        curr.code,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: textSec,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.mintPrimary,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
  }

  void _showNotificationsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final cardBg =
            isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
        final textPri =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final textSec =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        final borderCol =
            isDark ? AppColors.darkCardBorder : AppColors.cardBorder;

        return Material(
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            side: BorderSide(color: borderCol),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SafeArea(
            child: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(notificationSettingsProvider);
                final notifier =
                    ref.read(notificationSettingsProvider.notifier);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardBorder
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifications',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPri,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: textSec),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: AppColors.mintPrimary,
                      activeThumbColor: Colors.white,
                      title: Text(
                        'Instant Payment Alerts',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPri,
                        ),
                      ),
                      subtitle: Text(
                        'Notify on transactions and round-off transfers',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textSec,
                        ),
                      ),
                      value: settings.transactionAlerts,
                      onChanged: notifier.toggleTransactionAlerts,
                    ),
                    Divider(height: 1, color: borderCol),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: AppColors.mintPrimary,
                      activeThumbColor: Colors.white,
                      title: Text(
                        'Budget Warning Alerts',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPri,
                        ),
                      ),
                      subtitle: Text(
                        'Warn when category spending exceeds 80% and 100%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textSec,
                        ),
                      ),
                      value: settings.budgetWarnings,
                      onChanged: notifier.toggleBudgetWarnings,
                    ),
                    Divider(height: 1, color: borderCol),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: AppColors.mintPrimary,
                      activeThumbColor: Colors.white,
                      title: Text(
                        'Weekly Financial Summaries',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPri,
                        ),
                      ),
                      subtitle: Text(
                        'Receive weekly smart spending observations',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textSec,
                        ),
                      ),
                      value: settings.weeklyInsights,
                      onChanged: notifier.toggleWeeklyInsights,
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
  }

  void _showSecuritySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final cardBg =
            isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
        final textPri =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final textSec =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        final borderCol =
            isDark ? AppColors.darkCardBorder : AppColors.cardBorder;

        return Material(
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            side: BorderSide(color: borderCol),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SafeArea(
            child: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(securitySettingsProvider);
                final notifier = ref.read(securitySettingsProvider.notifier);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardBorder
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Security & Privacy',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPri,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: textSec),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: AppColors.mintPrimary,
                      activeThumbColor: Colors.white,
                      title: Text(
                        'Biometric Authentication',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPri,
                        ),
                      ),
                      subtitle: Text(
                        'Require Face ID or fingerprint on app open',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textSec,
                        ),
                      ),
                      value: settings.biometricAuthEnabled,
                      onChanged: notifier.toggleBiometrics,
                    ),
                    Divider(height: 1, color: borderCol),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: AppColors.mintPrimary,
                      activeThumbColor: Colors.white,
                      title: Text(
                        'Hide Balances on Resume',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPri,
                        ),
                      ),
                      subtitle: Text(
                        'Mask sensitive balance figures when resuming the app',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textSec,
                        ),
                      ),
                      value: settings.hideBalancesOnResume,
                      onChanged: notifier.toggleHideBalances,
                    ),
                    const SizedBox(height: 12),

                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
  }

  void _showAboutMintySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final cardBg =
            isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
        final textPri =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final textSec =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        final borderCol =
            isDark ? AppColors.darkCardBorder : AppColors.cardBorder;

        return Material(
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            side: BorderSide(color: borderCol),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCardBorder
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.mintAccent, AppColors.mintPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mintPrimary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Minty Finance',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textPri,
                  ),
                ),
                Text(
                  'Version 1.0.0 (Build 2026)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textSec,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCardSurfaceSecondary
                        : AppColors.cardSurfaceSecondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Minty is an intelligent, modern personal finance companion engineered with Flutter, Riverpod, Drift SQLite, and fl_chart.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: textPri,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shield_outlined,
                              size: 16, color: AppColors.mintDark),
                          const SizedBox(width: 6),
                          Text(
                            '100% Local & Private Database',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mintDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Close'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    },
  );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPri =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardBg =
        isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
    final borderCol =
        isDark ? AppColors.darkCardBorder : AppColors.cardBorder;

    final user = ref.watch(authProvider).user;
    final userName = user?.name ?? 'Meet Alshi';
    final userEmail = user?.email ?? 'meet@minty.app';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'M';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: textPri, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar Card
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderCol, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.mintAccent, AppColors.mintPrimary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mintPrimary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            userInitial,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textPri,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userEmail,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: textSec,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkMintLight
                                    : AppColors.mintLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Personal Account',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mintDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Financial Management Section
              Text(
                'Financial Management',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderCol, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.pie_chart_outline_rounded,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Monthly Budgets',
                      subtitle: 'Set limits and track category spending',
                      textPri: textPri,
                      textSec: textSec,
                      borderCol: borderCol,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BudgetsScreen()),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.savings_outlined,
                      iconBg: AppColors.mintLight,
                      iconColor: AppColors.mintDark,
                      title: 'Savings Goals',
                      subtitle: 'Track milestones and contributions',
                      textPri: textPri,
                      textSec: textSec,
                      borderCol: borderCol,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SavingsGoalsScreen()),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.autorenew_rounded,
                      iconBg: const Color(0xFFEEF2FF),
                      iconColor: const Color(0xFF6366F1),
                      title: 'Recurring Expenses',
                      subtitle: 'Subscriptions, rent and regular bills',
                      textPri: textPri,
                      textSec: textSec,
                      borderCol: borderCol,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const RecurringExpensesScreen()),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.account_balance_wallet_outlined,
                      iconBg: AppColors.mintLight,
                      iconColor: AppColors.mintDark,
                      title: 'Round-Off Wallet',
                      subtitle: 'Spare change micro-savings',
                      textPri: textPri,
                      textSec: textSec,
                      borderCol: borderCol,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const RoundOffWalletScreen()),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.calendar_month_outlined,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: 'Monthly Summary',
                      subtitle: 'Deep dive into cash flow and breakdown',
                      textPri: textPri,
                      textSec: textSec,
                      borderCol: borderCol,
                      isLast: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MonthlySummaryScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Preferences & Settings Section
              Text(
                'Settings & Preferences',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderCol, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.palette_outlined,
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF9333EA),
                      title: 'Appearance',
                      subtitle: 'Light, Dark Mode (Navy), System Default',
                      textPri: textPri,
                      textSec: textSec,
                      borderCol: borderCol,
                      onTap: () => _showAppearanceSheet(context, ref),
                    ),
                    _buildSettingsTile(
                      icon: Icons.currency_rupee_rounded,
                      iconBg: AppColors.mintLight,
                      iconColor: AppColors.mintDark,
                      title: 'Currency',
                      subtitle: 'INR (₹) Indian Rupee',
                      textPri: textPri,
                      textSec: textSec,
                      borderCol: borderCol,
                      onTap: () => _showCurrencySheet(context, ref),
                    ),
                    _buildSettingsTile(
                      icon: Icons.category_outlined,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Categories',
                      subtitle: 'Manage expense & income categories',
                      textPri: textPri,
                      textSec: textSec,
                      borderCol: borderCol,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CategoryManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: 'Notifications',
                      subtitle: 'Alerts, weekly summaries & warnings',
                      textPri: textPri,
                      textSec: textSec,
                      borderCol: borderCol,
                      onTap: () => _showNotificationsSheet(context, ref),
                    ),
                    _buildSettingsTile(
                      icon: Icons.lock_outline_rounded,
                      iconBg: const Color(0xFFEEF2FF),
                      iconColor: const Color(0xFF6366F1),
                      title: 'Security',
                      subtitle: 'Biometrics & balance privacy',
                      textPri: textPri,
                      textSec: textSec,
                      borderCol: borderCol,
                      onTap: () => _showSecuritySheet(context, ref),
                    ),
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconBg: const Color(0xFFF4F3FA),
                      iconColor: AppColors.textSecondary,
                      title: 'About Minty',
                      subtitle: 'Version 1.0.0, tech stack & privacy',
                      textPri: textPri,
                      textSec: textSec,
                      borderCol: borderCol,
                      isLast: true,
                      onTap: () => _showAboutMintySheet(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Log Out Action
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderCol, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Log Out',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                  subtitle: Text(
                    'Securely sign out of current session',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: textSec,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.error,
                  ),
                  onTap: () => _handleLogout(context, ref),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textPri,
    required Color textSec,
    required Color borderCol,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPri,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: textSec,
            ),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: textSec),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: borderCol,
          ),
      ],
    );
  }
}
