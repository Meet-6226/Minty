import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/database/app_database.dart';
import '../providers/database_providers.dart';
import '../theme/app_colors.dart';
import '../utils/icon_helper.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen> {


  void _showAddCategorySheet({String initialType = 'expense'}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    String selectedType = initialType;
    String selectedIcon = initialType == 'income'
        ? 'payments_rounded'
        : 'local_cafe_outlined';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final isDark = Theme.of(modalContext).brightness == Brightness.dark;
        final cardBg = isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
        final textPri =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final textSec =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        final borderCol =
            isDark ? AppColors.darkCardBorder : AppColors.cardBorder;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  side: BorderSide(color: borderCol),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add New Category',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textPri,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close_rounded, color: textSec),
                              onPressed: () => Navigator.pop(modalContext),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Type Selector
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCardSurfaceSecondary
                                : AppColors.cardSurfaceSecondary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      selectedType = 'expense';
                                      if (selectedIcon == 'payments_rounded') {
                                        selectedIcon = 'local_cafe_outlined';
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: selectedType == 'expense'
                                          ? (isDark
                                              ? AppColors.darkCardSurface
                                              : Colors.white)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: selectedType == 'expense'
                                          ? [
                                              const BoxShadow(
                                                color: Color(0x0A000000),
                                                blurRadius: 4,
                                              )
                                            ]
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Expense Category',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: selectedType == 'expense'
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selectedType == 'expense'
                                            ? AppColors.error
                                            : textSec,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      selectedType = 'income';
                                      if (selectedIcon ==
                                          'local_cafe_outlined') {
                                        selectedIcon = 'payments_rounded';
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: selectedType == 'income'
                                          ? (isDark
                                              ? AppColors.darkCardSurface
                                              : Colors.white)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: selectedType == 'income'
                                          ? [
                                              const BoxShadow(
                                                color: Color(0x0A000000),
                                                blurRadius: 4,
                                              )
                                            ]
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Income Category',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: selectedType == 'income'
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selectedType == 'income'
                                            ? AppColors.mintDark
                                            : textSec,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Name input
                        Text(
                          'Category Name',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPri,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          style: GoogleFonts.plusJakartaSans(color: textPri),
                          decoration: InputDecoration(
                            hintText: selectedType == 'expense'
                                ? 'e.g. Gaming, Tuition, Pets'
                                : 'e.g. Consulting, Royalties, Dividends',
                            prefixIcon: const Icon(Icons.label_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a category name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Icon Selector
                        Text(
                          'Choose Icon',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPri,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 120,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount:
                                CategoryIconHelper.availableCategoryIcons.length,
                            itemBuilder: (context, index) {
                              final iconKey = CategoryIconHelper
                                  .availableCategoryIcons[index];
                              final isSelected = selectedIcon == iconKey;
                              final style = CategoryIconHelper.getStyle(
                                iconKey,
                                isIncome: selectedType == 'income',
                              );

                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedIcon = iconKey;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.mintLight
                                        : (isDark
                                            ? AppColors.darkCardSurfaceSecondary
                                            : AppColors.cardSurfaceSecondary),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.mintPrimary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    style.icon,
                                    color: isSelected
                                        ? AppColors.mintDark
                                        : style.foregroundColor,
                                    size: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Save Button
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState?.validate() ?? false) {
                              final db = ref.read(databaseProvider);
                              final categoryName = nameController.text.trim();
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(modalContext);

                              await db.insertCategory(
                                CategoriesCompanion.insert(
                                  name: categoryName,
                                  type: selectedType,
                                  icon: selectedIcon,
                                ),
                              );

                              navigator.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Created $categoryName category!',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: AppColors.mintDark,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: const Text('Save Category'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  },
);
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? AppColors.darkBackground : AppColors.background;
    final textPri =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardBg =
        isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
    final borderCol =
        isDark ? AppColors.darkCardBorder : AppColors.cardBorder;

    final expenseCategoriesAsync = ref.watch(expenseCategoriesProvider);
    final incomeCategoriesAsync = ref.watch(incomeCategoriesProvider);

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (tabContext) {
          return Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              title: Text(
                'Categories',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPri,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: textPri, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: TabBar(
                indicatorColor: AppColors.mintPrimary,
                indicatorWeight: 3,
                labelColor: AppColors.mintDark,
                unselectedLabelColor: textSec,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Expenses'),
                  Tab(text: 'Income'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildCategoryList(
                  categoriesAsync: expenseCategoriesAsync,
                  isIncome: false,
                  cardBg: cardBg,
                  borderCol: borderCol,
                  textPri: textPri,
                  textSec: textSec,
                ),
                _buildCategoryList(
                  categoriesAsync: incomeCategoriesAsync,
                  isIncome: true,
                  cardBg: cardBg,
                  borderCol: borderCol,
                  textPri: textPri,
                  textSec: textSec,
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: AppColors.mintPrimary,
              foregroundColor: Colors.white,
              elevation: 3,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Add Category',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                final tabIndex = DefaultTabController.of(tabContext).index;
                final currentType = tabIndex == 0 ? 'expense' : 'income';
                _showAddCategorySheet(initialType: currentType);
              },
            ),
          );
        },
      ),
    );
  }


  Widget _buildCategoryList({
    required AsyncValue<List<Category>> categoriesAsync,
    required bool isIncome,
    required Color cardBg,
    required Color borderCol,
    required Color textPri,
    required Color textSec,
  }) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 48,
                  color: textSec.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No categories found',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textSec,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: categories.length + 1, // extra padding for FAB
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == categories.length) {
              return const SizedBox(height: 72); // FAB buffer
            }

            final category = categories[index];
            final style = CategoryIconHelper.getStyle(
              category.icon,
              isIncome: isIncome,
            );

            return Material(
              color: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderCol, width: 1),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: style.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    style.icon,
                    color: style.foregroundColor,
                    size: 22,
                  ),
                ),
                title: Text(
                  category.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                subtitle: Text(
                  isIncome ? 'Income Source' : 'Expense Category',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: textSec,
                  ),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isIncome
                        ? AppColors.mintLight
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isIncome ? 'Income' : 'Expense',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isIncome ? AppColors.mintDark : AppColors.error,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.mintPrimary),
      ),
      error: (err, stack) => Center(
        child: Text(
          'Failed to load categories',
          style: GoogleFonts.plusJakartaSans(color: AppColors.error),
        ),
      ),
    );
  }
}
