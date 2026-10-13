import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../domain/models/classmaster_user.dart';

class AuthState {
  final bool isLoading;
  final ClassMasterUser? user;
  final bool isConnected;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.isConnected = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    ClassMasterUser? user,
    bool? isConnected,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      isConnected: isConnected ?? this.isConnected,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(() => _init());
    return const AuthState(isLoading: true);
  }

  Future<void> _init() async {
    try {
      final repo = ref.read(classMasterRepositoryProvider);
      final user = await repo.getCurrentUser();
      state = AuthState(
        isLoading: false,
        user: user,
        isConnected: user != null,
      );
    } catch (e) {
      state = const AuthState(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(classMasterRepositoryProvider);
      final user = await repo.login(email, password);
      state = AuthState(
        isLoading: false,
        user: user,
        isConnected: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed: $e',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(classMasterRepositoryProvider);
    await repo.logout();
    state = const AuthState(
      isLoading: false,
      user: null,
      isConnected: false,
    );
  }
}

final authControllerProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
