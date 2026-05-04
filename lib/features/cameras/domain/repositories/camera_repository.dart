import '../entities/camera_entity.dart';

abstract class CameraRepository {
  Future<List<CameraEntity>> getCameras();
  Future<CameraEntity> getCameraById(String id);
  Future<String> getStreamUrl(String cameraId);
}
