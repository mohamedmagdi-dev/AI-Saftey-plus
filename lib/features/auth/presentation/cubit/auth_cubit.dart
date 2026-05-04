import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_exception.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial());

  final AuthRepository _authRepository;

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final token = await _authRepository.login(
        username: email.trim(),
        password: password,
      );
      emit(AuthAuthenticated(token: token));
      await refreshProfile();
    } catch (e) {
      emit(AuthError(message: errorMessage(mapToException(e))));
    }
  }

  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    try {
      final token = await _authRepository.register(
        username: name.trim().isNotEmpty ? name.trim() : email.trim(),
        password: password,
        email: email.trim().isNotEmpty ? email.trim() : null,
      );
      emit(AuthAuthenticated(token: token));
      await refreshProfile();
    } catch (e) {
      emit(AuthError(message: errorMessage(mapToException(e))));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: errorMessage(mapToException(e))));
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await _authRepository.getStoredAccessToken();
    if (token != null && token.isNotEmpty) {
      emit(AuthAuthenticated(token: token));
      await refreshProfile();
    } else {
      emit(AuthUnauthenticated());
    }
  }

  /// Loads `/auth/me` when a token is present. Safe to call from UI after login or on profile/home.
  Future<void> refreshProfile() async {
    final token = await _authRepository.getStoredAccessToken();
    if (token == null || token.isEmpty) return;
    try {
      final profile = await _authRepository.getCurrentUser();
      emit(AuthAuthenticated(token: token, profile: profile));
    } catch (_) {
      emit(AuthAuthenticated(token: token));
    }
  }
}
