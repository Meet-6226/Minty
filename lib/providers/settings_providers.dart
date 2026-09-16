import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ==========================================
// CURRENCY ARCHITECTURE
// ==========================================

class CurrencyConfig {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  final String locale;

  const CurrencyConfig({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    this.locale = 'en_IN',
  });

  String format(double amount, {bool showDecimals = true}) {
    final pattern = showDecimals ? '#,##0.00' : '#,##0';
    final formatter = NumberFormat(pattern, locale);
    return '$symbol${formatter.format(amount)}';
  }

  static const inr = CurrencyConfig(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
    flag: '🇮🇳',
    locale: 'en_IN',
  );

  static const usd = CurrencyConfig(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    flag: '🇺🇸',
    locale: 'en_US',
  );

  static const eur = CurrencyConfig(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    flag: '🇪🇺',
    locale: 'de_DE',
  );

  static const gbp = CurrencyConfig(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    flag: '🇬🇧',
    locale: 'en_GB',
  );

  static const jpy = CurrencyConfig(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    flag: '🇯🇵',
    locale: 'ja_JP',
  );

  static const List<CurrencyConfig> supportedCurrencies = [
    inr,
    usd,
    eur,
    gbp,
    jpy,
  ];
}

class CurrencyNotifier extends Notifier<CurrencyConfig> {
  @override
  CurrencyConfig build() {
    return CurrencyConfig.inr;
  }

  void setCurrency(CurrencyConfig config) {
    state = config;
  }
}

final currencyProvider =
    NotifierProvider<CurrencyNotifier, CurrencyConfig>(CurrencyNotifier.new);

// ==========================================
// NOTIFICATIONS SETTINGS
// ==========================================

class NotificationSettings {
  final bool transactionAlerts;
  final bool budgetWarnings;
  final bool weeklyInsights;
  final bool roundOffMilestones;

  const NotificationSettings({
    this.transactionAlerts = true,
    this.budgetWarnings = true,
    this.weeklyInsights = true,
    this.roundOffMilestones = true,
  });

  NotificationSettings copyWith({
    bool? transactionAlerts,
    bool? budgetWarnings,
    bool? weeklyInsights,
    bool? roundOffMilestones,
  }) {
    return NotificationSettings(
      transactionAlerts: transactionAlerts ?? this.transactionAlerts,
      budgetWarnings: budgetWarnings ?? this.budgetWarnings,
      weeklyInsights: weeklyInsights ?? this.weeklyInsights,
      roundOffMilestones: roundOffMilestones ?? this.roundOffMilestones,
    );
  }
}

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    return const NotificationSettings();
  }

  void toggleTransactionAlerts(bool value) {
    state = state.copyWith(transactionAlerts: value);
  }

  void toggleBudgetWarnings(bool value) {
    state = state.copyWith(budgetWarnings: value);
  }

  void toggleWeeklyInsights(bool value) {
    state = state.copyWith(weeklyInsights: value);
  }

  void toggleRoundOffMilestones(bool value) {
    state = state.copyWith(roundOffMilestones: value);
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);

// ==========================================
// SECURITY SETTINGS
// ==========================================

class SecuritySettings {
  final bool biometricAuthEnabled;
  final bool appPinLockEnabled;
  final bool hideBalancesOnResume;

  const SecuritySettings({
    this.biometricAuthEnabled = false,
    this.appPinLockEnabled = false,
    this.hideBalancesOnResume = false,
  });

  SecuritySettings copyWith({
    bool? biometricAuthEnabled,
    bool? appPinLockEnabled,
    bool? hideBalancesOnResume,
  }) {
    return SecuritySettings(
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      appPinLockEnabled: appPinLockEnabled ?? this.appPinLockEnabled,
      hideBalancesOnResume: hideBalancesOnResume ?? this.hideBalancesOnResume,
    );
  }
}

class SecuritySettingsNotifier extends Notifier<SecuritySettings> {
  @override
  SecuritySettings build() {
    return const SecuritySettings();
  }

  void toggleBiometrics(bool value) {
    state = state.copyWith(biometricAuthEnabled: value);
  }

  void togglePinLock(bool value) {
    state = state.copyWith(appPinLockEnabled: value);
  }

  void toggleHideBalances(bool value) {
    state = state.copyWith(hideBalancesOnResume: value);
  }
}

final securitySettingsProvider =
    NotifierProvider<SecuritySettingsNotifier, SecuritySettings>(
  SecuritySettingsNotifier.new,
);
