import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/database/app_database.dart';
import '../providers/database_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';
import 'goal_details_screen.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  void _showAddGoalModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _GoalCreateFormSheet(),
    );
  }

  void _showQuickContributionModal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalWithDetails item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickContributionFormSheet(goal: item.goal),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsWithDetailsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Savings Goals',
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
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            onPressed: () => _showAddGoalModal(context, ref),
            tooltip: 'Add Goal',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                goalsAsync.when(
                  loading: () => Container(
                    padding: const EdgeInsets.all(28),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.mintPrimary),
                    ),
                  ),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (goalsList) {
                    final totalSaved = goalsList.fold<double>(
                        0.0, (sum, g) => sum + g.savedAmount);
                    final totalTarget = goalsList.fold<double>(
                        0.0, (sum, g) => sum + g.goal.targetAmount);
                    final totalProgress = totalTarget > 0
                        ? (totalSaved / totalTarget).clamp(0.0, 1.0)
                        : 0.0;
                    final totalPercent = (totalProgress * 100).toInt();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Total Savings Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0F766E),
                                AppColors.mintPrimary,
                                Color(0xFF34D399),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.mintPrimary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.savings_rounded,
                                              color: Colors.white, size: 16),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              '${goalsList.length} Active Goals',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$totalPercent% reached',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.mintDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Text(
                                'TOTAL SAVED',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${NumberFormat('#,##0').format(totalSaved)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.0,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 14),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: totalProgress,
                                  minHeight: 8,
                                  backgroundColor: Colors.white
                                      .withValues(alpha: 0.25),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              Text(
                                'Target: ₹${NumberFormat('#,##0').format(totalTarget)} total across goals',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Goals List Header
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Goals',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (goalsList.isEmpty) ...[
                          Container(
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
                                const Icon(Icons.flag_outlined,
                                    size: 40,
                                    color: AppColors.textTertiary),
                                const SizedBox(height: 12),
                                Text(
                                  'No savings goals set yet',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Start tracking savings for a new gadget, vehicle, emergency fund, or trip.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _showAddGoalModal(context, ref),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Create a Goal'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: AppColors.mintPrimary),
                                    foregroundColor: AppColors.mintDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: goalsList.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final item = goalsList[index];
                              final goal = item.goal;
                              final percent = (item.progress * 100).toInt();
                              final formattedTarget =
                                  NumberFormat('#,##0').format(goal.targetAmount);
                              final formattedSaved =
                                  NumberFormat('#,##0').format(item.savedAmount);
                              final formattedRemaining =
                                  NumberFormat('#,##0').format(item.remaining);
                              final targetDateStr =
                                  DateFormat('d MMM yyyy').format(goal.targetDate);

                              String badgeText;
                              if (item.isCompleted) {
                                badgeText = 'Goal Completed! 🎉';
                              } else if (item.monthsRemaining > 0) {
                                badgeText =
                                    '${item.monthsRemaining} mo left • $targetDateStr';
                              } else if (item.daysRemaining > 0) {
                                badgeText =
                                    '${item.daysRemaining} days left • $targetDateStr';
                              } else {
                                badgeText = 'Target: $targetDateStr';
                              }

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          GoalDetailsScreen(goalId: goal.id),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(18),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: item.isCompleted
                                                  ? AppColors.mintLight
                                                  : AppColors.indigoLight,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              item.isCompleted
                                                  ? Icons.check_circle_outline_rounded
                                                  : Icons.savings_outlined,
                                              color: item.isCompleted
                                                  ? AppColors.mintDark
                                                  : AppColors.indigoSecondary,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  goal.name,
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '₹$formattedSaved of ₹$formattedTarget',
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors
                                                        .textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: item.isCompleted
                                                  ? AppColors.mintLight
                                                  : AppColors.indigoLight,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '$percent%',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: item.isCompleted
                                                    ? AppColors.mintDark
                                                    : AppColors.indigoSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Progress bar
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: item.progress,
                                          minHeight: 8,
                                          backgroundColor:
                                              AppColors.cardSurfaceSecondary,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            item.isCompleted
                                                ? AppColors.mintPrimary
                                                : AppColors.indigoSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Bottom row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              badgeText,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    AppColors.textSecondary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            item.isCompleted
                                                ? 'Target reached'
                                                : '₹$formattedRemaining left',
                                            style:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: item.isCompleted
                                                  ? AppColors.mintDark
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Quick Add Contribution
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _showQuickContributionModal(
                                                  context, ref, item),
                                          icon: const Icon(Icons.add_rounded,
                                              size: 16),
                                          label: const Text(
                                              'Add Contribution'),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                color: AppColors.cardBorder),
                                            foregroundColor:
                                                AppColors.textPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalModal(context, ref),
        backgroundColor: AppColors.mintPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Goal',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _GoalCreateFormSheet extends ConsumerStatefulWidget {
  const _GoalCreateFormSheet();

  @override
  ConsumerState<_GoalCreateFormSheet> createState() =>
      _GoalCreateFormSheetState();
}

class _GoalCreateFormSheetState extends ConsumerState<_GoalCreateFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 180));
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final targetAmount = double.parse(_targetAmountController.text.trim());

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      await db.createSavingsGoal(
        name: name,
        targetAmount: targetAmount,
        targetDate: _targetDate,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Savings goal created!',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
            backgroundColor: AppColors.mintPrimary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create goal: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Savings Goal',
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

                // Goal Name
                Text(
                  'Goal Name',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. MacBook Air M3',
                    filled: true,
                    fillColor: AppColors.cardSurfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: AppColors.mintPrimary, width: 2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a goal name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Target Amount
                Text(
                  'Target Amount',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.currency_rupee_rounded,
                        color: AppColors.mintDark, size: 20),
                    hintText: 'e.g. 85000',
                    filled: true,
                    fillColor: AppColors.cardSurfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: AppColors.mintPrimary, width: 2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a target amount';
                    }
                    final num = double.tryParse(val.trim());
                    if (num == null || num <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Target Date
                Text(
                  'Target Date',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2040),
                    );
                    if (picked != null) {
                      setState(() => _targetDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurfaceSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded,
                            color: AppColors.indigoSecondary, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('d MMMM yyyy').format(_targetDate),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.edit_calendar_rounded,
                            color: AppColors.textSecondary, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  text: 'Create Goal',
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

class _QuickContributionFormSheet extends ConsumerStatefulWidget {
  final SavingsGoal goal;

  const _QuickContributionFormSheet({required this.goal});

  @override
  ConsumerState<_QuickContributionFormSheet> createState() =>
      _QuickContributionFormSheetState();
}

class _QuickContributionFormSheetState
    extends ConsumerState<_QuickContributionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      await db.addGoalContribution(
        goalId: widget.goal.id,
        amount: amount,
        date: _selectedDate,
        note: _noteController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Contribution of ₹${NumberFormat('#,##0').format(amount)} recorded for ${widget.goal.name}!',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
            backgroundColor: AppColors.mintPrimary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add contribution: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Add to ${widget.goal.name}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount
                Text(
                  'Contribution Amount',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.currency_rupee_rounded,
                        color: AppColors.mintDark, size: 20),
                    hintText: 'e.g. 5000',
                    filled: true,
                    fillColor: AppColors.cardSurfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: AppColors.mintPrimary, width: 2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a contribution amount';
                    }
                    final num = double.tryParse(val.trim());
                    if (num == null || num <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Note
                Text(
                  'Note (Optional)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Weekly savings deposit',
                    filled: true,
                    fillColor: AppColors.cardSurfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: AppColors.mintPrimary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  text: 'Deposit to Goal',
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
