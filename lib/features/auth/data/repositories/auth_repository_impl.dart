import '../../../../core/storage/token_storage.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required RemoteAuthDataSource remote,
    required TokenStorage tokenStorage,
  })  : _remote = remote,
        _tokenStorage = tokenStorage;

  final RemoteAuthDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<String> login({
    required String username,
    required String password,
  }) async {
    final token = await _remote.login(username: username, password: password);
    await _tokenStorage.setAccessToken(token);
    return token;
  }

  @override
  Future<String> register({
    required String username,
    required String password,
    String? email,
  }) async {
    final token = await _remote.register(
      username: username,
      password: password,
      email: email,
    );
    await _tokenStorage.setAccessToken(token);
    return token;
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.setAccessToken(null);
  }

  @override
  Future<bool> hasStoredSession() async {
    final t = _tokenStorage.accessToken;
    return t != null && t.isNotEmpty;
  }

  @override
  Future<String?> getStoredAccessToken() async => _tokenStorage.accessToken;

  @override
  Future<UserProfileModel> getCurrentUser() => _remote.getCurrentUser();
}
