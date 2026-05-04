import '../../../../core/usecase/usecase.dart';
import '../repositories/camera_repository.dart';

class GetStreamUrlParams extends Params {
  const GetStreamUrlParams({required this.cameraId});

  final String cameraId;

  @override
  List<Object?> get props => [cameraId];
}

class GetStreamUrlUseCase extends UseCase<String, GetStreamUrlParams> {
  GetStreamUrlUseCase(this._repository);

  final CameraRepository _repository;

  @override
  Future<String> call(GetStreamUrlParams params) async {
    return _repository.getStreamUrl(params.cameraId);
  }
}
