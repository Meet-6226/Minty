import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryStyle {
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const CategoryStyle({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

class CategoryIconHelper {
  static CategoryStyle getStyle(String iconName, {bool isIncome = false}) {
    switch (iconName.toLowerCase()) {
      // Income
      case 'payments_rounded':
      case 'payments':
      case 'salary':
        return const CategoryStyle(
          icon: Icons.payments_rounded,
          backgroundColor: Color(0xFFECFDF5),
          foregroundColor: AppColors.mintPrimary,
        );
      case 'work_outline_rounded':
      case 'work':
      case 'freelance':
        return const CategoryStyle(
          icon: Icons.work_outline_rounded,
          backgroundColor: Color(0xFFECFDF5),
          foregroundColor: AppColors.mintDark,
        );
      case 'trending_up_rounded':
      case 'investments':
      case 'investment':
        return const CategoryStyle(
          icon: Icons.trending_up_rounded,
          backgroundColor: Color(0xFFF3E8FF),
          foregroundColor: Color(0xFF9333EA),
        );
      case 'card_giftcard_rounded':
      case 'gift':
      case 'gifts':
        return const CategoryStyle(
          icon: Icons.card_giftcard_rounded,
          backgroundColor: Color(0xFFFEF3C7),
          foregroundColor: Color(0xFFD97706),
        );

      // Expenses
      case 'local_cafe_outlined':
      case 'food':
      case 'cafe':
      case 'dining':
      case 'restaurant':
        return const CategoryStyle(
          icon: Icons.local_cafe_outlined,
          backgroundColor: Color(0xFFFFF7ED),
          foregroundColor: Color(0xFFEA580C),
        );
      case 'shopping_bag_outlined':
      case 'groceries':
      case 'grocery':
      case 'blinkit':
        return const CategoryStyle(
          icon: Icons.shopping_bag_outlined,
          backgroundColor: Color(0xFFEFF6FF),
          foregroundColor: Color(0xFF2563EB),
        );
      case 'home_outlined':
      case 'rent':
      case 'housing':
        return const CategoryStyle(
          icon: Icons.home_outlined,
          backgroundColor: Color(0xFFEEF2FF),
          foregroundColor: Color(0xFF4F46E5),
        );
      case 'receipt_long_outlined':
      case 'bills':
      case 'utilities':
        return const CategoryStyle(
          icon: Icons.receipt_long_outlined,
          backgroundColor: Color(0xFFFEF9C3),
          foregroundColor: Color(0xFFCA8A04),
        );
      case 'movie_outlined':
      case 'entertainment':
      case 'subscriptions':
        return const CategoryStyle(
          icon: Icons.movie_outlined,
          backgroundColor: Color(0xFFF5F3FF),
          foregroundColor: Color(0xFF7C3AED),
        );
      case 'shopping_cart_outlined':
      case 'shopping':
        return const CategoryStyle(
          icon: Icons.shopping_cart_outlined,
          backgroundColor: Color(0xFFFCE7F3),
          foregroundColor: Color(0xFFDB2777),
        );
      case 'directions_car_outlined':
      case 'travel':
      case 'commute':
      case 'transport':
        return const CategoryStyle(
          icon: Icons.directions_car_outlined,
          backgroundColor: Color(0xFFECFEFF),
          foregroundColor: Color(0xFF0891B2),
        );
      case 'fitness_center_outlined':
      case 'fitness':
      case 'health':
      case 'gym':
        return const CategoryStyle(
          icon: Icons.fitness_center_outlined,
          backgroundColor: Color(0xFFFEE2E2),
          foregroundColor: Color(0xFFDC2626),
        );
      case 'school_outlined':
      case 'education':
      case 'learning':
        return const CategoryStyle(
          icon: Icons.school_outlined,
          backgroundColor: Color(0xFFE0E7FF),
          foregroundColor: Color(0xFF4338CA),
        );
      case 'pets_outlined':
      case 'pets':
        return const CategoryStyle(
          icon: Icons.pets_outlined,
          backgroundColor: Color(0xFFFEF3C7),
          foregroundColor: Color(0xFFB45309),
        );
      case 'flight_takeoff_rounded':
      case 'vacation':
      case 'flight':
        return const CategoryStyle(
          icon: Icons.flight_takeoff_rounded,
          backgroundColor: Color(0xFFE0F2FE),
          foregroundColor: Color(0xFF0284C7),
        );
      case 'sports_esports_outlined':
      case 'gaming':
      case 'games':
        return const CategoryStyle(
          icon: Icons.sports_esports_outlined,
          backgroundColor: Color(0xFFF3E8FF),
          foregroundColor: Color(0xFF7E22CE),
        );
      case 'medical_services_outlined':
      case 'medical':
      case 'doctor':
        return const CategoryStyle(
          icon: Icons.medical_services_outlined,
          backgroundColor: Color(0xFFFEE2E2),
          foregroundColor: Color(0xFFE11D48),
        );
      case 'savings_outlined':
      case 'savings':
        return const CategoryStyle(
          icon: Icons.savings_outlined,
          backgroundColor: Color(0xFFECFDF5),
          foregroundColor: AppColors.mintDark,
        );
      case 'celebration_outlined':
      case 'party':
      case 'event':
        return const CategoryStyle(
          icon: Icons.celebration_outlined,
          backgroundColor: Color(0xFFFFF1F2),
          foregroundColor: Color(0xFFBE123C),
        );
      default:
        return CategoryStyle(
          icon: isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          backgroundColor: isIncome ? const Color(0xFFECFDF5) : const Color(0xFFF4F3FA),
          foregroundColor: isIncome ? AppColors.mintPrimary : AppColors.textPrimary,
        );
    }
  }

  static const List<String> availableCategoryIcons = [
    'local_cafe_outlined',
    'shopping_bag_outlined',
    'home_outlined',
    'receipt_long_outlined',
    'movie_outlined',
    'shopping_cart_outlined',
    'directions_car_outlined',
    'fitness_center_outlined',
    'school_outlined',
    'pets_outlined',
    'flight_takeoff_rounded',
    'sports_esports_outlined',
    'medical_services_outlined',
    'payments_rounded',
    'work_outline_rounded',
    'trending_up_rounded',
    'card_giftcard_rounded',
    'savings_outlined',
    'celebration_outlined',
  ];


  static IconData getIconData(String iconName, {bool isIncome = false}) =>
      getStyle(iconName, isIncome: isIncome).icon;

  static IconData getAccountIcon(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'savings':
      case 'salary':
      case 'bank':
        return Icons.account_balance_rounded;
      case 'cash':
        return Icons.account_balance_wallet_rounded;
      case 'wallet':
      case 'upi':
        return Icons.phone_android_rounded;
      case 'credit card':
      case 'card':
        return Icons.credit_card_rounded;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}
