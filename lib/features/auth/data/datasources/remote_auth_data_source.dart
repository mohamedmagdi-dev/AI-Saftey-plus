import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/user_profile_model.dart';

abstract class RemoteAuthDataSource {
  Future<String> login({required String username, required String password});

  Future<String> register({
    required String username,
    required String password,
    String? email,
  });

  Future<UserProfileModel> getCurrentUser();
}

class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  RemoteAuthDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: <String, dynamic>{
          'username': username,
          'password': password,
        },
      );
      final data = response.data;
      if (data == null || data['access_token'] == null) {
        throw const ApiException('Invalid login response');
      }
      return data['access_token'] as String;
    } on DioException catch (e) {
      throw ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<String> register({
    required String username,
    required String password,
    String? email,
  }) async {
    try {
      await dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: <String, dynamic>{
          'username': username,
          'password': password,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      );
      return login(username: username, password: password);
    } on DioException catch (e) {
      throw ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<UserProfileModel> getCurrentUser() async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/auth/me');
      final data = response.data;
      if (data == null) {
        throw const ApiException('Empty profile response');
      }
      return UserProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
    }
  }
}
