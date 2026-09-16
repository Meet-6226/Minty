import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/database/app_database.dart';
import '../providers/database_providers.dart';
import '../theme/app_colors.dart';
import '../utils/icon_helper.dart';
import '../widgets/primary_button.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  void _showAddEditBudgetModal(
    BuildContext context,
    WidgetRef ref, {
    BudgetWithCategoryAndSpending? item,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BudgetFormSheet(editingItem: item),
    );
  }

  void _confirmDeleteBudget(
    BuildContext context,
    WidgetRef ref,
    BudgetWithCategoryAndSpending item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Budget',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete the monthly budget for "${item.category.name}"?',
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
              await db.deleteBudget(item.budget.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Budget deleted successfully',
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedBudgetMonthProvider);
    final monthNotifier = ref.read(selectedBudgetMonthProvider.notifier);
    final budgetsAsync = ref.watch(monthlyBudgetsWithSpendingProvider);

    final formattedMonth = DateFormat('MMMM yyyy').format(selectedMonth);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Monthly Budgets',
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
            onPressed: () => _showAddEditBudgetModal(context, ref),
            tooltip: 'Add Budget',
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
                // Month Selector Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 24),
                        color: AppColors.textPrimary,
                        onPressed: monthNotifier.previousMonth,
                      ),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month_outlined,
                                size: 18, color: AppColors.indigoSecondary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                formattedMonth,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 24),
                        color: AppColors.textPrimary,
                        onPressed: monthNotifier.nextMonth,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Budgets List and Overview Card
                budgetsAsync.when(
                  loading: () => Container(
                    padding: const EdgeInsets.all(32),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.mintPrimary),
                    ),
                  ),
                  error: (err, _) => Center(
                    child: Text('Error loading budgets: $err'),
                  ),
                  data: (budgetsList) {
                    final totalBudget = budgetsList.fold<double>(
                        0.0, (sum, b) => sum + b.budget.amount);
                    final totalSpent = budgetsList.fold<double>(
                        0.0, (sum, b) => sum + b.spent);
                    final totalRemaining = totalBudget - totalSpent;
                    final totalProgress = totalBudget > 0
                        ? (totalSpent / totalBudget).clamp(0.0, 1.0)
                        : 0.0;
                    final totalPercent = (totalProgress * 100).toInt();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1E1B4B),
                                AppColors.indigoSecondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.indigoSecondary
                                    .withValues(alpha: 0.25),
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
                                  Expanded(
                                    child: Text(
                                      'MONTHLY BUDGET',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                        color: Colors.white
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$totalPercent% spent',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '₹${NumberFormat('#,##0').format(totalBudget)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 32,
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
                                      .withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    totalProgress >= 1.0
                                        ? const Color(0xFFEF4444)
                                        : totalProgress >= 0.80
                                            ? const Color(0xFFFBBF24)
                                            : AppColors.mintAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Spent',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${NumberFormat('#,##0').format(totalSpent)}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Remaining',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        totalRemaining >= 0
                                            ? '₹${NumberFormat('#,##0').format(totalRemaining)}'
                                            : '-₹${NumberFormat('#,##0').format(totalRemaining.abs())}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: totalRemaining >= 0
                                              ? AppColors.mintAccent
                                              : const Color(0xFFF87171),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section Title
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Category Budgets',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '${budgetsList.length} Categories',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (budgetsList.isEmpty) ...[
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
                                const Icon(Icons.donut_large_rounded,
                                    size: 40,
                                    color: AppColors.textTertiary),
                                const SizedBox(height: 12),
                                Text(
                                  'No budgets set for $formattedMonth',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Create a category budget to track and control your monthly expenses.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _showAddEditBudgetModal(context, ref),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Add Category Budget'),
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
                            itemCount: budgetsList.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = budgetsList[index];
                              final cat = item.category;
                              final style =
                                  CategoryIconHelper.getStyle(cat.icon);
                              final percent =
                                  (item.progress * 100).clamp(0, 999).toInt();

                              Color barColor;
                              Color badgeColor;
                              Color badgeTextColor;
                              String statusText;

                              if (item.isExceeded) {
                                barColor = AppColors.error;
                                badgeColor = AppColors.errorLight;
                                badgeTextColor = AppColors.error;
                                statusText =
                                    'Exceeded by ₹${NumberFormat('#,##0').format((item.spent - item.budget.amount))}';
                              } else if (item.isApproaching) {
                                barColor = const Color(0xFFF59E0B);
                                badgeColor = const Color(0xFFFEF3C7);
                                badgeTextColor = const Color(0xFFB45309);
                                statusText =
                                    'Approaching limit ($percent%)';
                              } else {
                                barColor = AppColors.mintPrimary;
                                badgeColor = AppColors.mintLight;
                                badgeTextColor = AppColors.mintDark;
                                statusText =
                                    '₹${NumberFormat('#,##0').format(item.remaining)} left';
                              }

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: item.isExceeded
                                        ? AppColors.error.withValues(alpha: 0.4)
                                        : item.isApproaching
                                            ? const Color(0xFFF59E0B)
                                                .withValues(alpha: 0.4)
                                            : AppColors.cardBorder,
                                    width: 1,
                                  ),
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
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: style.backgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            style.icon,
                                            color: style.foregroundColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cat.name,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '₹${NumberFormat('#,##0').format(item.spent)} of ₹${NumberFormat('#,##0').format(item.budget.amount)}',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_vert_rounded,
                                            color: AppColors.textSecondary,
                                            size: 20,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          onSelected: (val) {
                                            if (val == 'edit') {
                                              _showAddEditBudgetModal(
                                                  context, ref,
                                                  item: item);
                                            } else if (val == 'delete') {
                                              _confirmDeleteBudget(
                                                  context, ref, item);
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.edit_outlined,
                                                      size: 18,
                                                      color: AppColors
                                                          .textPrimary),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Edit Budget',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      size: 18,
                                                      color: AppColors.error),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Delete',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors.error,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // Progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value:
                                            item.progress.clamp(0.0, 1.0),
                                        minHeight: 8,
                                        backgroundColor:
                                            AppColors.cardSurfaceSecondary,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                barColor),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Status footer
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: badgeColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              statusText,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: badgeTextColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$percent%',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: item.isExceeded
                                                ? AppColors.error
                                                : item.isApproaching
                                                    ? const Color(0xFFF59E0B)
                                                    : AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
        onPressed: () => _showAddEditBudgetModal(context, ref),
        backgroundColor: AppColors.mintPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Set Budget',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BudgetFormSheet extends ConsumerStatefulWidget {
  final BudgetWithCategoryAndSpending? editingItem;

  const _BudgetFormSheet({this.editingItem});

  @override
  ConsumerState<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<_BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  Category? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingItem != null) {
      _amountController.text =
          widget.editingItem!.budget.amount.toStringAsFixed(0);
      _selectedCategory = widget.editingItem!.category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final currentMonth = ref.read(selectedBudgetMonthProvider);

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      if (widget.editingItem != null) {
        await db.updateBudget(
          id: widget.editingItem!.budget.id,
          amount: amount,
          categoryId: _selectedCategory!.id,
        );
      } else {
        await db.createBudget(
          categoryId: _selectedCategory!.id,
          amount: amount,
          month: currentMonth.month,
          year: currentMonth.year,
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editingItem != null
                  ? 'Budget updated successfully'
                  : 'Budget created successfully',
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
            content: Text('Failed to save budget: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final isEditing = widget.editingItem != null;

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
                      isEditing ? 'Edit Category Budget' : 'Set Category Budget',
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

                // Amount Field
                Text(
                  'Monthly Budget Amount',
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
                    hintText: 'e.g. 8000',
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
                      return 'Please enter a budget amount';
                    }
                    final num = double.tryParse(val.trim());
                    if (num == null || num <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category Selector
                Text(
                  'Select Expense Category',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                categoriesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.mintPrimary),
                  ),
                  error: (e, _) => Text('Error: $e'),
                  data: (categories) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSelected = _selectedCategory?.id == cat.id;
                        final style =
                            CategoryIconHelper.getStyle(cat.icon);

                        return ChoiceChip(
                          showCheckmark: false,
                          avatar: Icon(
                            style.icon,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : style.foregroundColor,
                          ),
                          label: Text(
                            cat.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.mintPrimary,
                          backgroundColor: AppColors.cardSurfaceSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.mintPrimary
                                  : AppColors.cardBorder,
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? cat : null;
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  text: isEditing ? 'Save Changes' : 'Create Budget',
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
