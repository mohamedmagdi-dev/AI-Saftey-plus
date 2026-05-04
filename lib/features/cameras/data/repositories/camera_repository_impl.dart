import '../../domain/entities/camera_entity.dart';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/remote_camera_data_source.dart';

class CameraRepositoryImpl implements CameraRepository {
  CameraRepositoryImpl({required RemoteCameraDataSource remote})
      : _remote = remote;

  final RemoteCameraDataSource _remote;

  @override
  Future<List<CameraEntity>> getCameras() => _remote.getCameras();

  @override
  Future<CameraEntity> getCameraById(String id) => _remote.getCameraById(id);

  @override
  Future<String> getStreamUrl(String cameraId) => _remote.getStreamUrl(cameraId);
}
