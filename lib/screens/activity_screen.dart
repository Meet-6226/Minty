import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/database/app_database.dart';
import '../providers/database_providers.dart';
import '../theme/app_colors.dart';
import '../utils/icon_helper.dart';
import '../widgets/app_text_field.dart';
import '../widgets/transaction_tile.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import 'transaction_details_screen.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = ref.read(activeTransactionFilterProvider);
    _searchController.text = filter.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(activeTransactionFilterProvider.notifier).setSearchQuery(query);
  }

  void _setTypeFilter(String typeFilter, {bool roundOffOnly = false}) {
    ref
        .read(activeTransactionFilterProvider.notifier)
        .setTypeFilter(typeFilter, roundOffOnly: roundOffOnly);
  }

  void _setCategoryFilter(int? categoryId) {
    ref
        .read(activeTransactionFilterProvider.notifier)
        .setCategoryId(categoryId);
  }

  String _getDateGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today';
    } else if (txDate == yesterday) {
      return 'Yesterday';
    } else if (now.year == date.year) {
      return DateFormat('d MMMM').format(date);
    } else {
      return DateFormat('d MMMM yyyy').format(date);
    }
  }

  Map<String, List<TransactionWithDetails>> _groupTransactions(
      List<TransactionWithDetails> list) {
    final Map<String, List<TransactionWithDetails>> grouped = {};
    for (final item in list) {
      final header = _getDateGroupHeader(item.transaction.date);
      grouped.putIfAbsent(header, () => []).add(item);
    }
    return grouped;
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mintPrimary : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.mintPrimary : AppColors.cardBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.mintPrimary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilterModal(
      BuildContext context, List<Category> categories, int? selectedCatId) {
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Category',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (selectedCatId != null)
                    TextButton(
                      onPressed: () {
                        _setCategoryFilter(null);
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Clear',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GestureDetector(
                    onTap: () {
                      _setCategoryFilter(null);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedCatId == null
                            ? AppColors.mintPrimary
                            : AppColors.cardSurfaceSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedCatId == null
                              ? AppColors.mintPrimary
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        'All Categories',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: selectedCatId == null
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selectedCatId == null
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  ...categories.map((cat) {
                    final isSelected = selectedCatId == cat.id;
                    final isIncome = cat.type == 'income';
                    final style = CategoryIconHelper.getStyle(cat.icon,
                        isIncome: isIncome);

                    return GestureDetector(
                      onTap: () {
                        _setCategoryFilter(cat.id);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.mintPrimary
                              : AppColors.cardSurfaceSecondary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.mintPrimary
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              style.icon,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : style.foregroundColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
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
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(activeTransactionFilterProvider);
    final transactionsAsync = ref.watch(filteredTransactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final isAll = filter.typeFilter == 'all' && !filter.roundOffOnly;
    final isExpense = filter.typeFilter == 'expense' && !filter.roundOffOnly;
    final isIncome = filter.typeFilter == 'income' && !filter.roundOffOnly;
    final isRoundOff = filter.roundOffOnly;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header & Search Area
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Activity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.mintLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.add_rounded,
                                    color: AppColors.mintDark, size: 20),
                              ),
                              tooltip: 'Add Transaction',
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => Material(
                                    color: AppColors.cardSurface,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(28)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                          Container(
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: AppColors.cardBorder,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            'Create Transaction',
                                            style:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ListTile(
                                            leading: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF1F2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.add_circle_outline_rounded,
                                                color: Color(0xFFE11D48),
                                              ),
                                            ),
                                            title: Text(
                                              'Add Expense',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              'Record a spend or purchase',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color:
                                                    AppColors.textSecondary,
                                              ),
                                            ),
                                            trailing: const Icon(
                                                Icons.chevron_right_rounded),
                                            onTap: () {
                                              Navigator.pop(ctx);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const AddExpenseScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                          const Divider(
                                              height: 1,
                                              indent: 56,
                                              color: AppColors.cardBorder),
                                          ListTile(
                                            leading: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: AppColors.mintLight,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.arrow_downward_rounded,
                                                color: AppColors.mintDark,
                                              ),
                                            ),
                                            title: Text(
                                              'Add Income',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              'Record incoming salary or cash',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color:
                                                    AppColors.textSecondary,
                                              ),
                                            ),
                                            trailing: const Icon(
                                                Icons.chevron_right_rounded),
                                            onTap: () {
                                              Navigator.pop(ctx);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const AddIncomeScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Search Bar
                    AppTextField(
                      controller: _searchController,
                      hintText: 'Search transactions, merchants...',
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
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 14),

                    // Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'All',
                            isSelected: isAll,
                            onTap: () => _setTypeFilter('all'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Expenses',
                            icon: Icons.arrow_upward_rounded,
                            isSelected: isExpense,
                            onTap: () => _setTypeFilter('expense'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Income',
                            icon: Icons.arrow_downward_rounded,
                            isSelected: isIncome,
                            onTap: () => _setTypeFilter('income'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Spare Change',
                            icon: Icons.savings_outlined,
                            isSelected: isRoundOff,
                            onTap: () =>
                                _setTypeFilter('all', roundOffOnly: true),
                          ),
                          const SizedBox(width: 8),
                          categoriesAsync.maybeWhen(
                            data: (categories) {
                              final selectedCategory = categories
                                  .where((c) => c.id == filter.categoryId)
                                  .firstOrNull;
                              final hasCat = selectedCategory != null;

                              return _buildFilterChip(
                                label: hasCat
                                    ? selectedCategory.name
                                    : 'Category',
                                icon: hasCat
                                    ? Icons.check_circle_rounded
                                    : Icons.filter_list_rounded,
                                isSelected: hasCat,
                                onTap: () => _showCategoryFilterModal(
                                  context,
                                  categories,
                                  filter.categoryId,
                                ),
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Transactions List
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.mintPrimary),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error loading transactions: $err',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.mintLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                size: 32,
                                color: AppColors.mintDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              filter.searchQuery.isNotEmpty ||
                                      filter.categoryId != null ||
                                      filter.typeFilter != 'all' ||
                                      filter.roundOffOnly
                                  ? 'Try changing or clearing your search and filters.'
                                  : 'Start recording your expenses and income to see them here.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final grouped = _groupTransactions(transactions);
                  final timeFormat = DateFormat('hh:mm a');

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, groupIndex) {
                      final header = grouped.keys.elementAt(groupIndex);
                      final items = grouped[header]!;

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 4),
                                child: Text(
                                  header,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.cardBorder, width: 1),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x04172033),
                                      blurRadius: 12,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: items.length,
                                  separatorBuilder: (_, _) => const Divider(
                                    height: 1,
                                    indent: 68,
                                    endIndent: 16,
                                    color: AppColors.cardBorder,
                                  ),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    final tx = item.transaction;
                                    final cat = item.category;
                                    final acc = item.account;
                                    final isIncome = tx.type == 'income';
                                    final style = CategoryIconHelper.getStyle(
                                        cat.icon,
                                        isIncome: isIncome);

                                    final formattedAmount =
                                        NumberFormat('#,##0.00')
                                            .format(tx.amount);
                                    final timeStr =
                                        timeFormat.format(tx.date);

                                    // Subtitle: e.g. "Food & Drink • HDFC Bank • 10:45 AM"
                                    final subtitle =
                                        '${cat.name} • ${acc.name} • $timeStr';

                                    return TransactionTile(
                                      title: tx.description.isNotEmpty
                                          ? tx.description
                                          : cat.name,
                                      subtitle: subtitle,
                                      amount: formattedAmount,
                                      isIncome: isIncome,
                                      icon: style.icon,
                                      iconBgColor: style.backgroundColor,
                                      iconColor: style.foregroundColor,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TransactionDetailsScreen(
                                              transactionId: tx.id,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
