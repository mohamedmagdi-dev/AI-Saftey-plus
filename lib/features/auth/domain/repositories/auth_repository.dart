import '../models/user_profile_model.dart';

abstract class AuthRepository {
  Future<String> login({required String username, required String password});

  Future<String> register({
    required String username,
    required String password,
    String? email,
  });

  Future<UserProfileModel> getCurrentUser();

  Future<void> logout();

  Future<bool> hasStoredSession();

  /// Non-null when the user previously logged in and the token was persisted.
  Future<String?> getStoredAccessToken();
}
