import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/alert_model.dart';

abstract class RemoteAlertDataSource {
  Future<List<AlertModel>> getAlerts({String? filter});
  Future<List<AlertModel>> getAlertHistory({String? filter});
  Future<AlertModel> getAlertById(String id);
}

class RemoteAlertDataSourceImpl implements RemoteAlertDataSource {
  RemoteAlertDataSourceImpl({required this.dio});

  final Dio dio;

  Map<String, dynamic> _historyQuery({String? filter}) {
    final q = <String, dynamic>{'limit': 500, 'skip': 0};
    if (filter != null &&
        filter.isNotEmpty &&
        filter.toLowerCase() != 'all') {
      q['alert_type'] = filter;
    }
    return q;
  }

  List<dynamic> _asAlertList(dynamic data) {
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
      return data['data'] as List<dynamic>;
    }
    return <dynamic>[];
  }

  @override
  Future<List<AlertModel>> getAlerts({String? filter}) async {
    try {
      final useFilter = filter != null &&
          filter.isNotEmpty &&
          filter.toLowerCase() != 'all';
      final response = await dio.get<dynamic>(
        useFilter ? '/alerts/' : '/alerts/recent',
        queryParameters: useFilter
            ? <String, dynamic>{'limit': 100, 'skip': 0, 'alert_type': filter}
            : <String, dynamic>{'minutes': 1440},
      );
      final list = _asAlertList(response.data);
      return list
          .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<AlertModel>> getAlertHistory({String? filter}) async {
    try {
      final response = await dio.get<dynamic>(
        '/alerts/',
        queryParameters: _historyQuery(filter: filter),
      );
      final list = _asAlertList(response.data);
      return list
          .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<AlertModel> getAlertById(String id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/alerts/$id');
      final data = response.data;
      if (data == null) {
        throw const ApiException('Empty alert response');
      }
      return AlertModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
    }
  }
}
