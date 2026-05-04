import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/report_summary_model.dart';
import '../../domain/models/report_timeline_model.dart';

abstract class RemoteReportsDataSource {
  Future<ReportSummaryModel> getSummary({required String period});

  /// period: `today` | `week` | `month` — interval: `hour` | `day`
  Future<ReportTimelineModel> getTimeline({
    required String period,
    required String interval,
  });
}

class RemoteReportsDataSourceImpl implements RemoteReportsDataSource {
  RemoteReportsDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<ReportSummaryModel> getSummary({required String period}) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/reports/summary',
        queryParameters: <String, dynamic>{'period': period},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException('Empty report summary');
      }
      return ReportSummaryModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<ReportTimelineModel> getTimeline({
    required String period,
    required String interval,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/reports/timeline',
        queryParameters: <String, dynamic>{
          'period': period,
          'interval': interval,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException('Empty timeline response');
      }
      return ReportTimelineModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
    }
  }
}
