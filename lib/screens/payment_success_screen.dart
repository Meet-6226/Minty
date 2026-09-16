import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';
import 'round_off_wallet_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Contact contact;
  final Account account;
  final double amount;
  final double roundOffAmount;
  final String? note;
  final DateTime date;

  const PaymentSuccessScreen({
    super.key,
    required this.contact,
    required this.account,
    required this.amount,
    required this.roundOffAmount,
    this.note,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final totalPaid = amount + roundOffAmount;
    final formattedTotal = NumberFormat('#,##0.00').format(totalPaid);
    final formattedActual = NumberFormat('#,##0.00').format(amount);
    final formattedRoundOff = NumberFormat('#,##0.00').format(roundOffAmount);
    final formattedDate =
        DateFormat('d MMMM yyyy, hh:mm a').format(date);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Animated Success Icon
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.mintAccent,
                          AppColors.mintPrimary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mintPrimary.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Payment Successful',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Total Amount
                  Text(
                    '₹$formattedTotal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Recipient Text
                  Text(
                    'Paid to ${contact.name}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Round-Off Spare Change Badge (if applicable)
                  if (roundOffAmount > 0) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RoundOffWalletScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFECFDF5),
                              Color(0xFFD1FAE5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.mintPrimary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06172033),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.mintPrimary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.savings_rounded,
                                color: AppColors.mintDark,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '₹${roundOffAmount.toStringAsFixed(0)} added to Round-Off Wallet',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.mintDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Spare change automatically saved',
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
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AppColors.mintDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Payment Details Summary Card
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
                          'Payment Details',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        const SizedBox(height: 12),
                        _buildRow('Recipient UPI / Phone', contact.upiId),
                        const SizedBox(height: 10),
                        _buildRow('Paid From', account.name),
                        const SizedBox(height: 10),
                        _buildRow('Actual Payment', '₹$formattedActual'),
                        if (roundOffAmount > 0) ...[
                          const SizedBox(height: 10),
                          _buildRow('Round-Off Saved', '+₹$formattedRoundOff',
                              isHighlight: true),
                        ],
                        const SizedBox(height: 10),
                        _buildRow('Date & Time', formattedDate),
                        if (note != null && note!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildRow('Note', note!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  PrimaryButton(
                    text: 'Done',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (roundOffAmount > 0)
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RoundOffWalletScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'View Round-Off Wallet',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mintDark,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
              color: isHighlight ? AppColors.mintDark : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
