import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

String messageFromDioException(DioException e) {
  final data = e.response?.data;
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String) return detail;
    if (detail is List) {
      return detail
          .map((x) {
            if (x is Map && x['msg'] != null) return x['msg'].toString();
            return x.toString();
          })
          .join(', ');
    }
  }
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'Connection timed out. Check your network and try again.';
  }
  if (e.type == DioExceptionType.connectionError) {
    return 'Could not reach the server. Check your connection.';
  }
  return e.message ?? 'Request failed';
}

Object mapToException(Object e) {
  if (e is DioException) {
    return ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
  }
  return e;
}

String errorMessage(Object e) {
  if (e is ApiException) return e.message;
  return e.toString();
}
