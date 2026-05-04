import '../../../../core/usecase/usecase.dart';
import '../entities/camera_entity.dart';
import '../repositories/camera_repository.dart';

class GetCamerasUseCase extends UseCase<List<CameraEntity>, NoParams> {
  GetCamerasUseCase(this._repository);

  final CameraRepository _repository;

  @override
  Future<List<CameraEntity>> call(NoParams params) async {
    return _repository.getCameras();
  }
}
