import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/database/app_database.dart';
import '../providers/database_providers.dart';
import '../theme/app_colors.dart';
import '../utils/icon_helper.dart';

class TransactionDetailsScreen extends ConsumerStatefulWidget {
  final int transactionId;

  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
  });

  @override
  ConsumerState<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState
    extends ConsumerState<TransactionDetailsScreen> {
  bool _isDeleting = false;

  void _confirmDelete(BuildContext context, TransactionWithDetails item) {
    final isExpense = item.transaction.type == 'expense';
    final reversalAmount = isExpense
        ? item.transaction.amount + item.transaction.roundOffAmount
        : item.transaction.amount;

    final reversalMessage = isExpense
        ? 'Deleting this expense will restore ₹${NumberFormat('#,##0.00').format(reversalAmount)} to ${item.account.name}.'
        : 'Deleting this income will deduct ₹${NumberFormat('#,##0.00').format(reversalAmount)} from ${item.account.name}.';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete Transaction',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${item.transaction.description.isEmpty ? item.category.name : item.transaction.description}"?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardSurfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                reversalMessage,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isDeleting = true);

              try {
                final db = ref.read(databaseProvider);
                await db.deleteTransaction(widget.transactionId);

                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Transaction deleted and account balance updated.',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    ),
                    backgroundColor: AppColors.mintPrimary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                Navigator.pop(this.context);
              } catch (e) {
                if (!mounted) return;
                setState(() => _isDeleting = false);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete transaction: $e'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
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
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync =
        ref.watch(transactionDetailsProvider(widget.transactionId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Transaction Details',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (detailsAsync.value != null && !_isDeleting)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              tooltip: 'Delete Transaction',
              onPressed: () =>
                  _confirmDelete(context, detailsAsync.value!),
            ),
        ],
      ),
      body: detailsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.mintPrimary),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load transaction',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (details) {
          if (details == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'Transaction not found',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final tx = details.transaction;
          final cat = details.category;
          final acc = details.account;
          final isIncome = tx.type == 'income';
          final style =
              CategoryIconHelper.getStyle(cat.icon, isIncome: isIncome);

          final dateFormat = DateFormat('EEEE, d MMMM yyyy • hh:mm a');
          final formattedDate = dateFormat.format(tx.date);
          final formattedAmount = NumberFormat('#,##0.00').format(tx.amount);

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    // Header Amount Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 28),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: AppColors.cardBorder, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08172033),
                            blurRadius: 20,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: style.backgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              style.icon,
                              color: style.foregroundColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tx.description.isNotEmpty
                                ? tx.description
                                : cat.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isIncome
                                ? '+$formattedAmount'
                                : '-$formattedAmount',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              color: isIncome
                                  ? AppColors.mintPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isIncome
                                  ? AppColors.mintLight
                                  : AppColors.cardSurfaceSecondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isIncome ? 'Income' : 'Expense',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isIncome
                                    ? AppColors.mintDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Round-Off Callout Card (if applicable)
                    if (tx.roundOffAmount > 0) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF0FDF4),
                              Color(0xFFDCFCE7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.mintPrimary.withValues(alpha: 0.3),
                            width: 1,
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
                                    'Spare Change Saved',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.mintDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${tx.roundOffAmount.toStringAsFixed(0)} automatically invested in your Round-Off Wallet.',
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
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Transaction Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: AppColors.cardBorder, width: 1),
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
                          Text(
                            'Transaction Information',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                              height: 1, color: AppColors.cardBorder),
                          _buildDetailRow(
                            icon: style.icon,
                            iconColor: style.foregroundColor,
                            iconBgColor: style.backgroundColor,
                            label: 'Category',
                            value: cat.name,
                          ),
                          const Divider(
                              height: 1,
                              indent: 54,
                              color: AppColors.cardBorder),
                          _buildDetailRow(
                            icon: CategoryIconHelper.getAccountIcon(acc.type),
                            iconColor: AppColors.indigoSecondary,
                            iconBgColor: AppColors.indigoLight,
                            label: 'Account',
                            value: acc.name,
                            subtitle:
                                'Current balance: ₹${NumberFormat('#,##0.00').format(acc.balance)}',
                          ),
                          const Divider(
                              height: 1,
                              indent: 54,
                              color: AppColors.cardBorder),
                          _buildDetailRow(
                            icon: Icons.calendar_today_rounded,
                            iconColor: const Color(0xFF0891B2),
                            iconBgColor: const Color(0xFFECFEFF),
                            label: 'Date & Time',
                            value: formattedDate,
                          ),
                          if (tx.description.isNotEmpty) ...[
                            const Divider(
                                height: 1,
                                indent: 54,
                                color: AppColors.cardBorder),
                            _buildDetailRow(
                              icon: Icons.notes_rounded,
                              iconColor: const Color(0xFF8B5CF6),
                              iconBgColor: const Color(0xFFF5F3FF),
                              label: 'Note / Description',
                              value: tx.description,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Delete Transaction Button
                    OutlinedButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => _confirmDelete(context, details),
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppColors.error),
                      label: Text(
                        'Delete Transaction',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.error,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFFECDD3), width: 1.5),
                        backgroundColor: AppColors.errorLight.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
