import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/models/camera_model.dart';

abstract class RemoteCameraDataSource {
  Future<List<CameraModel>> getCameras();
  Future<CameraModel> getCameraById(String id);
  Future<String> getStreamUrl(String cameraId);
  Future<String> getCameraSnapshot(String cameraId);
}

class RemoteCameraDataSourceImpl implements RemoteCameraDataSource {
  RemoteCameraDataSourceImpl({required this.dio});

  final Dio dio;

  List<dynamic> _asList(dynamic data) {
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
      return data['data'] as List<dynamic>;
    }
    return <dynamic>[];
  }

  @override
  Future<List<CameraModel>> getCameras() async {
    try {
      final response = await dio.get<dynamic>('/cameras/');
      final list = _asList(response.data);
      return list
          .map((e) => CameraModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<CameraModel> getCameraById(String id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/cameras/$id');
      final data = response.data;
      if (data == null) {
        throw const ApiException('Empty camera response');
      }
      return CameraModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
    }
  }

  /// Live MJPEG/API stream served by the backend (see OpenAPI `/stream/{camera_id}`).
  @override
  Future<String> getStreamUrl(String cameraId) async {
    final base = AppConstants.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    return '$base/stream/$cameraId';
  }

  /// Get camera snapshot from API (see OpenAPI `/cameras/{camera_id}/snapshot`)
  @override
  Future<String> getCameraSnapshot(String cameraId) async {
    try {
      final response = await dio.get<dynamic>('/cameras/$cameraId/snapshot');
      
      // If the response contains the snapshot URL in JSON
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final snapshotUrl = data['snapshot_url'] as String?;
        if (snapshotUrl != null && snapshotUrl.isNotEmpty) {
          return snapshotUrl;
        }
      }
      
      // If the response is the image data directly, return a data URL
      if (response.data is List<int>) {
        final bytes = response.data as List<int>;
        return 'data:image/jpeg;base64,${bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join()}';
      }
      
      // Fallback: construct snapshot URL from base URL
      final base = AppConstants.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
      return '$base/cameras/$cameraId/snapshot';
    } on DioException catch (e) {
      throw ApiException(messageFromDioException(e), statusCode: e.response?.statusCode);
    }
  }
}
