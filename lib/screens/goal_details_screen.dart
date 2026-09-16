import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/database/app_database.dart';
import '../providers/database_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class GoalDetailsScreen extends ConsumerWidget {
  final int goalId;

  const GoalDetailsScreen({super.key, required this.goalId});

  void _showAddContributionModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContributionFormSheet(goalId: goalId),
    );
  }

  void _showEditGoalModal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalWithDetails goalDetails,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GoalFormSheet(editingGoal: goalDetails.goal),
    );
  }

  void _confirmDeleteGoal(BuildContext context, WidgetRef ref, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Goal',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete the goal "$name" and all of its recorded contributions?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final db = ref.read(databaseProvider);
              await db.deleteSavingsGoal(goalId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Goal deleted successfully',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    ),
                    backgroundColor: AppColors.textPrimary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteContribution(
    BuildContext context,
    WidgetRef ref,
    GoalContribution contrib,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Contribution',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Remove contribution of ₹${NumberFormat('#,##0').format(contrib.amount)}?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final db = ref.read(databaseProvider);
              await db.deleteGoalContribution(contrib.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalDetailsAsync = ref.watch(singleGoalDetailsProvider(goalId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Goal Details',
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
          goalDetailsAsync.maybeWhen(
            data: (goalDetails) {
              if (goalDetails == null) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: AppColors.textPrimary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showEditGoalModal(context, ref, goalDetails);
                  } else if (val == 'delete') {
                    _confirmDeleteGoal(context, ref, goalDetails.goal.name);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.textPrimary),
                        const SizedBox(width: 10),
                        Text(
                          'Edit Goal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.error),
                        const SizedBox(width: 10),
                        Text(
                          'Delete Goal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: goalDetailsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.mintPrimary),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err'),
        ),
        data: (goalDetails) {
          if (goalDetails == null) {
            return Center(
              child: Text(
                'Goal not found',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          final goal = goalDetails.goal;
          final percent = (goalDetails.progress * 100).toInt();
          final formattedTarget =
              NumberFormat('#,##0').format(goal.targetAmount);
          final formattedSaved =
              NumberFormat('#,##0').format(goalDetails.savedAmount);
          final formattedRemaining =
              NumberFormat('#,##0').format(goalDetails.remaining);
          final targetDateStr =
              DateFormat('d MMMM yyyy').format(goal.targetDate);

          String estimatedText;
          if (goalDetails.isCompleted) {
            estimatedText = 'Target Achieved! 🎉';
          } else if (goalDetails.daysRemaining <= 0) {
            estimatedText = 'Target date passed';
          } else if (goalDetails.monthsRemaining > 0) {
            estimatedText =
                '${goalDetails.monthsRemaining} month${goalDetails.monthsRemaining > 1 ? 's' : ''} left • Target: $targetDateStr';
          } else {
            estimatedText =
                '${goalDetails.daysRemaining} day${goalDetails.daysRemaining > 1 ? 's' : ''} left • Target: $targetDateStr';
          }

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Progress Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0F766E),
                            AppColors.mintPrimary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mintPrimary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    estimatedText,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                                  '$percent%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.mintDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Text(
                            goal.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Flexible(
                                child: Text(
                                  '₹$formattedSaved',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -1.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'of ₹$formattedTarget',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: goalDetails.progress,
                              minHeight: 10,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.25),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Target: ₹$formattedTarget',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                goalDetails.isCompleted
                                    ? 'Completed 🎉'
                                    : '₹$formattedRemaining to go',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add Contribution Quick Action
                    PrimaryButton(
                      text: '+ Add Contribution',
                      onPressed: () =>
                          _showAddContributionModal(context, ref),
                    ),
                    const SizedBox(height: 24),

                    // Contributions History
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Contribution History',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${goalDetails.contributions.length} deposits',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (goalDetails.contributions.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: AppColors.cardBorder, width: 1),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.savings_outlined,
                                  size: 36, color: AppColors.textTertiary),
                              const SizedBox(height: 10),
                              Text(
                                'No contributions yet',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add your first savings contribution to track your progress.',
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
                    ] else ...[
                      Container(
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
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: goalDetails.contributions.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            indent: 64,
                            endIndent: 16,
                            color: AppColors.cardBorder,
                          ),
                          itemBuilder: (context, index) {
                            final contrib = goalDetails.contributions[index];
                            final formattedAmount =
                                NumberFormat('#,##0').format(contrib.amount);
                            final formattedDate =
                                DateFormat('d MMM yyyy').format(contrib.date);

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.mintLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_downward_rounded,
                                  color: AppColors.mintDark,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                contrib.note != null &&
                                        contrib.note!.isNotEmpty
                                    ? contrib.note!
                                    : 'Savings Contribution',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                formattedDate,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '+₹$formattedAmount',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.mintDark,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: AppColors.textTertiary,
                                    ),
                                    onPressed: () =>
                                        _confirmDeleteContribution(
                                            context, ref, contrib),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
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

class _ContributionFormSheet extends ConsumerStatefulWidget {
  final int goalId;

  const _ContributionFormSheet({required this.goalId});

  @override
  ConsumerState<_ContributionFormSheet> createState() =>
      _ContributionFormSheetState();
}

class _ContributionFormSheetState
    extends ConsumerState<_ContributionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
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
        goalId: widget.goalId,
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
              'Contribution of ₹${NumberFormat('#,##0').format(amount)} recorded!',
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
                    Text(
                      'Add Goal Contribution',
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

                // Date Picker
                Text(
                  'Date',
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
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
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
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.indigoSecondary, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    hintText: 'e.g. Monthly salary savings',
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
                  text: 'Save Contribution',
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

class _GoalFormSheet extends ConsumerStatefulWidget {
  final SavingsGoal? editingGoal;

  const _GoalFormSheet({this.editingGoal});

  @override
  ConsumerState<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<_GoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 180));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingGoal != null) {
      _nameController.text = widget.editingGoal!.name;
      _targetAmountController.text =
          widget.editingGoal!.targetAmount.toStringAsFixed(0);
      _targetDate = widget.editingGoal!.targetDate;
    }
  }

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
      if (widget.editingGoal != null) {
        await db.updateSavingsGoal(
          id: widget.editingGoal!.id,
          name: name,
          targetAmount: targetAmount,
          targetDate: _targetDate,
        );
      } else {
        await db.createSavingsGoal(
          name: name,
          targetAmount: targetAmount,
          targetDate: _targetDate,
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editingGoal != null
                  ? 'Goal updated successfully'
                  : 'Savings goal created!',
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
            content: Text('Failed to save goal: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingGoal != null;

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
                      isEditing ? 'Edit Savings Goal' : 'Create Savings Goal',
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
                  text: isEditing ? 'Save Changes' : 'Create Goal',
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
