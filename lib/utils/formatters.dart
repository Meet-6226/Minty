import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _inrFormatterWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inrFormatterCompact = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Formats amount in INR with 2 decimal digits: e.g. ₹42,850.00
  static String formatINR(double amount, {bool showDecimals = true}) {
    if (showDecimals) {
      return _inrFormatterWithDecimals.format(amount);
    } else {
      return _inrFormatterCompact.format(amount);
    }
  }

  /// Formats date for display: e.g. "Today at 10:45 AM" or "14 Sep, 02:30 PM"
  static String formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    final timeStr = DateFormat('h:mm a').format(date);

    if (itemDate == today) {
      return 'Today at $timeStr';
    } else if (itemDate == yesterday) {
      return 'Yesterday at $timeStr';
    } else {
      final daysDiff = today.difference(itemDate).inDays;
      if (daysDiff < 7) {
        return '$daysDiff days ago';
      }
      return DateFormat('d MMM, h:mm a').format(date);
    }
  }
}
