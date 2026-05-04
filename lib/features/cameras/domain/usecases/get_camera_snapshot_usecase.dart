import '../../../../core/usecase/usecase.dart';
import '../entities/camera_entity.dart';
import '../repositories/camera_repository.dart';

class GetCameraSnapshotParams extends Params {
  const GetCameraSnapshotParams({required this.cameraId});

  final String cameraId;

  @override
  List<Object?> get props => [cameraId];
}

class GetCameraSnapshotUseCase extends UseCase<String, GetCameraSnapshotParams> {
  GetCameraSnapshotUseCase(this._repository);

  final CameraRepository _repository;

  @override
  Future<String> call(GetCameraSnapshotParams params) async {
    return _repository.getCameraSnapshot(params.cameraId);
  }
}
