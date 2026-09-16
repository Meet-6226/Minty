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

class RecurringExpensesScreen extends ConsumerWidget {
  const RecurringExpensesScreen({super.key});

  void _showAddEditModal(
    BuildContext context,
    WidgetRef ref, {
    RecurringExpenseWithCategory? item,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecurringFormSheet(editingItem: item),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RecurringExpenseWithCategory item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Recurring Expense',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item.recurringExpense.name}"?',
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
              await db.deleteRecurringExpense(item.recurringExpense.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Recurring expense deleted',
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

  void _showPayNowModal(
    BuildContext context,
    WidgetRef ref,
    RecurringExpenseWithCategory item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PayRecurringSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(recurringExpensesWithCategoryProvider);
    final totalMonthlyAsync = ref.watch(totalMonthlyRecurringProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Recurring Expenses',
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
            onPressed: () => _showAddEditModal(context, ref),
            tooltip: 'Add Recurring',
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
                // Total Monthly Recurring Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF312E81),
                        AppColors.indigoSecondary,
                        Color(0xFF6366F1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.indigoSecondary.withValues(alpha: 0.3),
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
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.autorenew_rounded,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Monthly Commitment',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'TOTAL RECURRING / MONTH',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          totalMonthlyAsync.maybeWhen(
                            data: (val) =>
                                '₹${NumberFormat('#,##0').format(val)}',
                            orElse: () => '₹0',
                          ),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        'Calculated across all active subscriptions, bills & rent.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Subscriptions & Recurring List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Subscriptions & Bills',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subscriptions List
                recurringAsync.when(
                  loading: () => Container(
                    padding: const EdgeInsets.all(28),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.mintPrimary),
                    ),
                  ),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (items) {
                    if (items.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: AppColors.cardBorder, width: 1),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.autorenew_rounded,
                                size: 40, color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              'No recurring expenses added',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add recurring bills, gym memberships, Netflix, Spotify, or Rent to stay on top of regular expenses.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => _showAddEditModal(context, ref),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Recurring Expense'),
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
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final rec = item.recurringExpense;
                        final cat = item.category;
                        final style =
                            CategoryIconHelper.getStyle(cat.icon);

                        final formattedAmount =
                            NumberFormat('#,##0').format(rec.amount);
                        final nextDateStr =
                            DateFormat('d MMM yyyy').format(rec.nextDate);
                        final now = DateTime.now();
                        final daysUntil =
                            rec.nextDate.difference(now).inDays;

                        String dueBadgeText;
                        Color dueBadgeColor;
                        Color dueTextColor;

                        if (!rec.active) {
                          dueBadgeText = 'Paused';
                          dueBadgeColor = AppColors.cardSurfaceSecondary;
                          dueTextColor = AppColors.textTertiary;
                        } else if (daysUntil < 0) {
                          dueBadgeText = 'Past Due • $nextDateStr';
                          dueBadgeColor = AppColors.errorLight;
                          dueTextColor = AppColors.error;
                        } else if (daysUntil == 0) {
                          dueBadgeText = 'Due Today';
                          dueBadgeColor = const Color(0xFFFEF3C7);
                          dueTextColor = const Color(0xFFB45309);
                        } else if (daysUntil <= 7) {
                          dueBadgeText = 'Due in $daysUntil days';
                          dueBadgeColor = const Color(0xFFFEF3C7);
                          dueTextColor = const Color(0xFFB45309);
                        } else {
                          dueBadgeText = 'Next: $nextDateStr';
                          dueBadgeColor = AppColors.mintLight;
                          dueTextColor = AppColors.mintDark;
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.cardBorder,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: style.backgroundColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      style.icon,
                                      color: style.foregroundColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rec.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: rec.active
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${cat.name} • ${rec.frequency[0].toUpperCase()}${rec.frequency.substring(1)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹$formattedAmount',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: rec.active
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '/${rec.frequency.toLowerCase() == 'monthly' ? 'mo' : rec.frequency.toLowerCase() == 'yearly' ? 'yr' : rec.frequency.toLowerCase() == 'weekly' ? 'wk' : 'day'}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Bottom action row with Due date badge, switch, and pay now
                              Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: dueBadgeColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          dueBadgeText,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: dueTextColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Active Switch
                                  SizedBox(
                                    height: 28,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Switch(
                                        value: rec.active,
                                        activeThumbColor: AppColors.mintPrimary,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        onChanged: (val) async {
                                          final db = ref.read(databaseProvider);
                                          await db.toggleRecurringExpenseActive(
                                              rec.id, val);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),

                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.more_vert_rounded,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      onSelected: (val) {
                                        if (val == 'pay_now') {
                                          _showPayNowModal(context, ref, item);
                                        } else if (val == 'edit') {
                                          _showAddEditModal(context, ref,
                                              item: item);
                                        } else if (val == 'delete') {
                                          _confirmDelete(context, ref, item);
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        PopupMenuItem(
                                          value: 'pay_now',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.payment_rounded,
                                                  size: 18,
                                                  color: AppColors.mintDark),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Pay / Record Now',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.mintDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.edit_outlined,
                                                  size: 18,
                                                  color: AppColors.textPrimary),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Edit Details',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
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
                                              const Icon(
                                                  Icons.delete_outline_rounded,
                                                  size: 18,
                                                  color: AppColors.error),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Delete',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.error,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
        onPressed: () => _showAddEditModal(context, ref),
        backgroundColor: AppColors.mintPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Recurring',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RecurringFormSheet extends ConsumerStatefulWidget {
  final RecurringExpenseWithCategory? editingItem;

  const _RecurringFormSheet({this.editingItem});

  @override
  ConsumerState<_RecurringFormSheet> createState() =>
      _RecurringFormSheetState();
}

class _RecurringFormSheetState extends ConsumerState<_RecurringFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  Category? _selectedCategory;
  String _selectedFrequency = 'monthly';
  DateTime _nextDate = DateTime.now().add(const Duration(days: 30));
  bool _active = true;
  bool _isLoading = false;

  final List<String> _frequencies = ['monthly', 'weekly', 'yearly', 'daily'];

  @override
  void initState() {
    super.initState();
    if (widget.editingItem != null) {
      final rec = widget.editingItem!.recurringExpense;
      _nameController.text = rec.name;
      _amountController.text = rec.amount.toStringAsFixed(0);
      _selectedCategory = widget.editingItem!.category;
      _selectedFrequency = rec.frequency;
      _nextDate = rec.nextDate;
      _active = rec.active;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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

    final name = _nameController.text.trim();
    final amount = double.parse(_amountController.text.trim());

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      if (widget.editingItem != null) {
        await db.updateRecurringExpense(
          id: widget.editingItem!.recurringExpense.id,
          name: name,
          amount: amount,
          categoryId: _selectedCategory!.id,
          frequency: _selectedFrequency,
          nextDate: _nextDate,
          active: _active,
        );
      } else {
        await db.createRecurringExpense(
          name: name,
          amount: amount,
          categoryId: _selectedCategory!.id,
          frequency: _selectedFrequency,
          nextDate: _nextDate,
          active: _active,
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editingItem != null
                  ? 'Recurring expense updated'
                  : 'Recurring expense added!',
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
            content: Text('Failed to save: $e'),
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
                      isEditing
                          ? 'Edit Recurring Expense'
                          : 'Add Recurring Expense',
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

                // Name
                Text(
                  'Expense Name',
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
                    hintText: 'e.g. Netflix, Spotify, Rent',
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
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                Text(
                  'Amount',
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
                    hintText: 'e.g. 649',
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
                      return 'Please enter an amount';
                    }
                    final num = double.tryParse(val.trim());
                    if (num == null || num <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Frequency Selector
                Text(
                  'Frequency',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _frequencies.map((freq) {
                    final isSelected = _selectedFrequency == freq;
                    return ChoiceChip(
                      showCheckmark: false,
                      label: Text(
                        freq[0].toUpperCase() + freq.substring(1),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.indigoSecondary,
                      backgroundColor: AppColors.cardSurfaceSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.indigoSecondary
                              : AppColors.cardBorder,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFrequency = freq);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Category
                Text(
                  'Category',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
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
                const SizedBox(height: 16),

                // Next Due Date
                Text(
                  'Next Payment Date',
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
                      initialDate: _nextDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setState(() => _nextDate = picked);
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
                        const Icon(Icons.event_repeat_rounded,
                            color: AppColors.indigoSecondary, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('d MMMM yyyy').format(_nextDate),
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
                  text: isEditing ? 'Save Changes' : 'Add Subscription',
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

class _PayRecurringSheet extends ConsumerStatefulWidget {
  final RecurringExpenseWithCategory item;

  const _PayRecurringSheet({required this.item});

  @override
  ConsumerState<_PayRecurringSheet> createState() => _PayRecurringSheetState();
}

class _PayRecurringSheetState extends ConsumerState<_PayRecurringSheet> {
  Account? _selectedAccount;
  bool _isLoading = false;

  Future<void> _handlePayment() async {
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an account to pay from'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedAccount!.balance < widget.item.recurringExpense.amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance in ${_selectedAccount!.name}. Available: ₹${_selectedAccount!.balance.toStringAsFixed(2)}',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      await db.payRecurringExpenseNow(
        recurring: widget.item.recurringExpense,
        accountId: _selectedAccount!.id,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment of ₹${NumberFormat('#,##0').format(widget.item.recurringExpense.amount)} recorded! Next due date updated.',
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
            content: Text('Failed to record payment: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final rec = widget.item.recurringExpense;
    final formattedAmount = NumberFormat('#,##0').format(rec.amount);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Record Payment',
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

              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurfaceSecondary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.item.category.name} • ${rec.frequency}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹$formattedAmount',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mintDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Account Selector
              Text(
                'Pay From Account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              accountsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.mintPrimary),
                ),
                error: (e, _) => Text('Error: $e'),
                data: (accounts) {
                  return Column(
                    children: accounts.map((acc) {
                      final isSelected = _selectedAccount?.id == acc.id;
                      final formattedBalance =
                          NumberFormat('#,##0.00').format(acc.balance);

                      return InkWell(
                        onTap: () {
                          setState(() => _selectedAccount = acc);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.mintLight
                                : AppColors.cardSurfaceSecondary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.mintPrimary
                                  : AppColors.cardBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected
                                    ? AppColors.mintDark
                                    : AppColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  acc.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '₹$formattedBalance',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Confirm & Record Payment',
                isLoading: _isLoading,
                onPressed: _handlePayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
