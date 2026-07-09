import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

// AuthState to handle UI loading, success, and error states
class AuthState {
  final bool isLoading;
  final String? error;
  final LoginResponse? response;

  AuthState({this.isLoading = false, this.error, this.response});

  AuthState copyWith({
    bool? isLoading,
    String? error,
    LoginResponse? response,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      response: response ?? this.response,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repository = ref.read(authRepositoryProvider);

    try {
      final response = await repository.login(email, password);

      if (response.code == 200 && response.result == "Success") {
        state = state.copyWith(isLoading: false, response: response);

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        if (response.token != null) {
          await prefs.setString('token', response.token!);
        }
        if (response.user != null) {
          await prefs.setString('userName', response.user!.name);
          await prefs.setString('userEmail', response.user!.email);
        }
        return true; // Success
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false; // Failed
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to connect. Please check your internet and try again.',
      );
      return false;
    }
  }
}

// Provider for AuthNotifier
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
