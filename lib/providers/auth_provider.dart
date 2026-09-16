import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';
import 'database_providers.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState(user: null, isLoading: false);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true, clearUser: true);
    final db = ref.read(databaseProvider);

    final existingUser = await db.getUserByEmail(email);
    if (existingUser == null) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        errorMessage: 'No account found with this email. Please register.',
      );
      return false;
    }

    final authenticatedUser = await db.authenticateUser(email, password);
    if (authenticatedUser == null) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        errorMessage: 'Incorrect password. Please try again.',
      );
      return false;
    }

    state = AuthState(user: authenticatedUser, isLoading: false);
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearUser: true);
    final db = ref.read(databaseProvider);

    final existingUser = await db.getUserByEmail(email);
    if (existingUser != null) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        errorMessage: 'An account already exists with this email.',
      );
      return false;
    }

    final newUser = await db.registerUser(
      name: name,
      email: email,
      password: password,
    );

    state = AuthState(user: newUser, isLoading: false);
    return true;
  }

  void logout() {
    state = const AuthState(user: null, isLoading: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
