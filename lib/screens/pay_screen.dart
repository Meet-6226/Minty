import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/database/app_database.dart';
import '../providers/database_providers.dart';
import '../theme/app_colors.dart';
import '../utils/icon_helper.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'payment_success_screen.dart';
import 'round_off_wallet_screen.dart';

class PayScreen extends ConsumerStatefulWidget {
  final Contact? initialContact;

  const PayScreen({super.key, this.initialContact});

  @override
  ConsumerState<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends ConsumerState<PayScreen> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Contact? _selectedContact;
  int? _selectedAccountId;
  bool _enableRoundOff = true;
  double _calculatedRoundOff = 0.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedContact = widget.initialContact;
    _amountController.addListener(_updateRoundOff);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.removeListener(_updateRoundOff);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateRoundOff() {
    final text = _amountController.text.trim();
    if (text.isEmpty) {
      setState(() => _calculatedRoundOff = 0.0);
      return;
    }
    final amount = double.tryParse(text);
    if (amount != null && amount > 0) {
      final remainder = (amount * 100).round() % 1000;
      final roundOffCents = remainder > 0 ? (1000 - remainder) : 0;
      setState(() => _calculatedRoundOff = roundOffCents / 100.0);
    } else {
      setState(() => _calculatedRoundOff = 0.0);
    }
  }

  void _selectContact(Contact contact) {
    setState(() {
      _selectedContact = contact;
    });
  }

  void _clearSelectedContact() {
    setState(() {
      _selectedContact = null;
      _amountController.clear();
      _noteController.clear();
    });
  }

  Future<void> _handleConfirmPayment() async {
    if (_selectedContact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a contact to pay'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final accounts = await ref.read(databaseProvider).getAllAccounts();
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment account'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedAccount = accounts.firstWhere(
      (a) => a.id == _selectedAccountId,
      orElse: () => accounts.first,
    );

    final roundOff = _enableRoundOff ? _calculatedRoundOff : 0.0;
    final totalPayment = amount + roundOff;

    if (selectedAccount.balance < totalPayment) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance in ${selectedAccount.name}. Required: ₹${NumberFormat('#,##0.00').format(totalPayment)}, Available: ₹${NumberFormat('#,##0.00').format(selectedAccount.balance)}',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Show Confirmation Sheet
    _showReviewPaymentSheet(
      contact: _selectedContact!,
      account: selectedAccount,
      amount: amount,
      roundOff: roundOff,
      total: totalPayment,
      note: _noteController.text.trim(),
    );
  }

  void _showReviewPaymentSheet({
    required Contact contact,
    required Account account,
    required double amount,
    required double roundOff,
    required double total,
    required String note,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Material(
        color: AppColors.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Review Payment',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Confirm transaction details before processing.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Total Payment Highlight
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardSurfaceSecondary,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL AMOUNT PAYABLE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${NumberFormat('#,##0.00').format(total)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detailed breakdown
              _buildBreakdownRow('Paying To', contact.name, isBold: true),
              const SizedBox(height: 8),
              _buildBreakdownRow('UPI ID / Phone', contact.upiId),
              const SizedBox(height: 8),
              _buildBreakdownRow('Debited Account', account.name),
              const SizedBox(height: 8),
              _buildBreakdownRow(
                  'Actual Payment', '₹${NumberFormat('#,##0.00').format(amount)}'),
              if (roundOff > 0) ...[
                const SizedBox(height: 8),
                _buildBreakdownRow(
                  'Round-Off Spare Change',
                  '+₹${NumberFormat('#,##0.00').format(roundOff)}',
                  color: AppColors.mintDark,
                ),
                const SizedBox(height: 8),
                _buildBreakdownRow(
                  'Saved to Round-Off Wallet',
                  '₹${NumberFormat('#,##0.00').format(roundOff)}',
                  color: AppColors.mintDark,
                ),
              ],
              if (note.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildBreakdownRow('Note', note),
              ],
              const SizedBox(height: 28),

              // Confirm Button
              PrimaryButton(
                text: 'Confirm & Pay ₹${NumberFormat('#,##0.00').format(total)}',
                isLoading: _isProcessing,
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _executePayment(
                    contact: contact,
                    account: account,
                    amount: amount,
                    roundOff: roundOff,
                    note: note,
                  );
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Future<void> _executePayment({
    required Contact contact,
    required Account account,
    required double amount,
    required double roundOff,
    required String note,
  }) async {
    setState(() => _isProcessing = true);

    try {
      final db = ref.read(databaseProvider);
      final categories = await db.getAllCategories();
      final expenseCategory = categories
          .where((c) => c.type == 'expense')
          .first; // Default expense category

      final now = DateTime.now();
      final description = note.isNotEmpty
          ? 'Paid to ${contact.name} ($note)'
          : 'Paid to ${contact.name}';

      await db.processPayment(
        accountId: account.id,
        categoryId: expenseCategory.id,
        amount: amount,
        description: description,
        date: now,
        roundOffAmount: roundOff,
      );

      if (!mounted) return;
      _clearSelectedContact();
      setState(() => _isProcessing = false);

      // Navigate to Payment Success Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            contact: contact,
            account: account,
            amount: amount,
            roundOffAmount: roundOff,
            note: note.isNotEmpty ? note : null,
            date: now,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildBreakdownRow(String label, String value,
      {bool isBold = false, Color? color}) {
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
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final walletBalanceAsync = ref.watch(roundOffWalletBalanceProvider);

    final formattedWalletBalance = walletBalanceAsync.maybeWhen(
      data: (val) => NumberFormat('#,##0.00').format(val),
      orElse: () => '0.00',
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header with Round-Off Wallet Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Payments & UPI',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.mintLight,
                            borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.mintPrimary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.savings_rounded,
                                color: AppColors.mintDark,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '₹$formattedWalletBalance',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mintDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Selected Contact Card OR Contact Search & Picker
                  if (_selectedContact != null) ...[
                    // Selected Contact Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.mintPrimary, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06172033),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.mintLight,
                            child: Text(
                              _selectedContact!.avatar ??
                                  _selectedContact!.name[0].toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
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
                                  _selectedContact!.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedContact!.upiId,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.textSecondary),
                            onPressed: _clearSelectedContact,
                            tooltip: 'Change contact',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Amount Entry
                    Text(
                      'Payment Amount',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: AppColors.cardBorder, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x04172033),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '₹',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.mintDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textTertiary,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter an amount';
                                }
                                final num = double.tryParse(value);
                                if (num == null || num <= 0) {
                                  return 'Please enter a valid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Debited Account Selector
                    Text(
                      'Pay From Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    accountsAsync.when(
                      data: (accounts) {
                        if (accounts.isEmpty) return const SizedBox.shrink();
                        if (_selectedAccountId == null ||
                            !accounts.any((a) => a.id == _selectedAccountId)) {
                          _selectedAccountId = accounts.first.id;
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.cardBorder, width: 1),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedAccountId,
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary),
                              items: accounts.map((account) {
                                return DropdownMenuItem<int>(
                                  value: account.id,
                                  child: Row(
                                    children: [
                                      Icon(
                                        CategoryIconHelper.getAccountIcon(
                                            account.type),
                                        size: 18,
                                        color: AppColors.indigoSecondary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          account.name,
                                          style:
                                              GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '₹${NumberFormat('#,##0.00').format(account.balance)}',
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (accountId) {
                                if (accountId != null) {
                                  setState(
                                      () => _selectedAccountId = accountId);
                                }
                              },
                            ),
                          ),
                        );
                      },
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (_, _) =>
                          const Text('Failed to load accounts'),
                    ),
                    const SizedBox(height: 20),

                    // Note field
                    Text(
                      'Optional Note',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _noteController,
                      hintText: 'e.g. Dinner split, Rent share',
                      prefixIcon: const Icon(Icons.notes_rounded,
                          color: AppColors.textSecondary, size: 20),
                    ),
                    const SizedBox(height: 20),

                    // Round-Off Toggle Card & Calculation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: AppColors.cardBorder, width: 1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.mintLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.savings_outlined,
                                  color: AppColors.mintDark,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Round-Off Spare Change',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Round payment up to nearest ₹10',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _enableRoundOff,
                                activeTrackColor: AppColors.mintPrimary,
                                onChanged: (val) =>
                                    setState(() => _enableRoundOff = val),
                              ),
                            ],
                          ),
                          if (_enableRoundOff &&
                              _amountController.text.isNotEmpty &&
                              double.tryParse(_amountController.text.trim()) !=
                                  null &&
                              double.parse(_amountController.text.trim()) >
                                  0) ...[
                            const SizedBox(height: 12),
                            const Divider(
                                height: 1, color: AppColors.cardBorder),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurfaceSecondary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Actual Payment',
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '₹${NumberFormat('#,##0.00').format(double.parse(_amountController.text.trim()))}',
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Round-Off',
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.mintDark,
                                        ),
                                      ),
                                      Text(
                                        '+₹${NumberFormat('#,##0.00').format(_calculatedRoundOff)}',
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.mintDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Paid',
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '₹${NumberFormat('#,##0.00').format(double.parse(_amountController.text.trim()) + _calculatedRoundOff)}',
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Review & Pay Button
                    PrimaryButton(
                      text: 'Review & Pay',
                      isLoading: _isProcessing,
                      onPressed: _handleConfirmPayment,
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    // Search Contacts Bar
                    AppTextField(
                      controller: _searchController,
                      hintText: 'Search contacts by name, UPI or phone...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(contactSearchQueryProvider.notifier)
                                    .setQuery('');
                              },
                            )
                          : null,
                      onChanged: (val) {
                        ref
                            .read(contactSearchQueryProvider.notifier)
                            .setQuery(val);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Saved Contacts List
                    Text(
                      'Saved Contacts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    contactsAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                              color: AppColors.mintPrimary),
                        ),
                      ),
                      error: (err, _) => Center(
                        child: Text('Error loading contacts: $err'),
                      ),
                      data: (contacts) {
                        if (contacts.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.cardBorder, width: 1),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.person_search_rounded,
                                    size: 36, color: AppColors.textTertiary),
                                const SizedBox(height: 10),
                                Text(
                                  'No contacts found',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try searching for another name, UPI ID or phone number.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.cardBorder, width: 1),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06172033),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            clipBehavior: Clip.antiAlias,
                            child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: contacts.length,
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              indent: 68,
                              endIndent: 16,
                              color: AppColors.cardBorder,
                            ),
                            itemBuilder: (context, index) {
                              final contact = contacts[index];
                              final initial = contact.avatar ??
                                  contact.name[0].toUpperCase();

                              return ListTile(
                                onTap: () => _selectContact(contact),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.mintLight,
                                  child: Text(
                                    initial,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.mintDark,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  contact.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${contact.upiId} • ${contact.phone}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardSurfaceSecondary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
