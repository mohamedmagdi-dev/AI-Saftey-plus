import '../../../../core/usecase/usecase.dart';
import '../entities/camera_entity.dart';
import '../repositories/camera_repository.dart';

class GetCameraByIdParams extends Params {
  const GetCameraByIdParams({required this.cameraId});

  final String cameraId;

  @override
  List<Object?> get props => [cameraId];
}

class GetCameraByIdUseCase extends UseCase<CameraEntity, GetCameraByIdParams> {
  GetCameraByIdUseCase(this._repository);

  final CameraRepository _repository;

  @override
  Future<CameraEntity> call(GetCameraByIdParams params) async {
    return _repository.getCameraById(params.cameraId);
  }
}
