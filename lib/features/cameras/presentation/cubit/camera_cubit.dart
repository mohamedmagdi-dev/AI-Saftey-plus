import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/camera_entity.dart';
import '../../domain/entities/bounding_box.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../../../core/network/api_exception.dart';

part 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  CameraCubit({required CameraRepository cameraRepository})
      : _cameraRepository = cameraRepository,
        super(CameraInitial());

  final CameraRepository _cameraRepository;

  Future<void> fetchCameras() async {
    emit(CameraLoading());
    try {
      final cameras = await _cameraRepository.getCameras();
      emit(CameraLoaded(cameras: cameras));
    } catch (e) {
      emit(CameraError(message: errorMessage(mapToException(e))));
    }
  }

  Future<void> startStream(String cameraId) async {
    emit(CameraStreamLoading());
    try {
      final streamUrl = await _cameraRepository.getStreamUrl(cameraId);
      String? displayName;
      try {
        final cam = await _cameraRepository.getCameraById(cameraId);
        displayName = cam.name;
      } catch (_) {}
      emit(
        CameraStreamActive(
          cameraId: cameraId,
          streamUrl: streamUrl,
          displayName: displayName,
        ),
      );
    } catch (e) {
      emit(CameraError(message: errorMessage(mapToException(e))));
    }
  }

  void stopStream() {
    emit(CameraStreamStopped());
  }

  void updateBoundingBoxes(List<BoundingBox> boxes) {
    if (state is CameraStreamActive) {
      final currentState = state as CameraStreamActive;
      emit(currentState.copyWith(boundingBoxes: boxes));
    }
  }
}
