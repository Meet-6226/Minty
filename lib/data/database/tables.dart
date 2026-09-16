import 'package:drift/drift.dart';

// 1. Users table
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get password => text().withDefault(const Constant('password123'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 2. Accounts table
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // e.g. 'Savings', 'Salary', 'Cash', 'Wallet'
  RealColumn get balance => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 3. Categories table
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'expense' or 'income'
  TextColumn get icon => text()(); // e.g. 'restaurant', 'shopping_bag', 'payments'
}

// 4. Transactions table
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get type => text()(); // 'expense', 'income', 'transfer'
  RealColumn get amount => real()();
  TextColumn get description => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get roundOffAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 5. Budgets table
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get amount => real()();
  IntColumn get month => integer()(); // 1 - 12
  IntColumn get year => integer()();  // e.g. 2026
}

// 6. SavingsGoals table
class SavingsGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  DateTimeColumn get targetDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 7. GoalContributions table
class GoalContributions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(SavingsGoals, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
}

// 8. RecurringExpenses table
class RecurringExpenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get frequency => text()(); // 'daily', 'weekly', 'monthly', 'yearly'
  DateTimeColumn get nextDate => dateTime()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

// 9. Contacts table
class Contacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get upiId => text()();
  TextColumn get avatar => text().nullable()();
}
