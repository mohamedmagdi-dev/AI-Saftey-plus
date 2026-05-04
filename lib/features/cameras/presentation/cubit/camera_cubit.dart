import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/camera_entity.dart';
import '../../domain/entities/bounding_box.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../domain/usecases/get_cameras_usecase.dart';
import '../../domain/usecases/get_camera_by_id_usecase.dart';
import '../../domain/usecases/get_stream_url_usecase.dart';
import '../../domain/usecases/get_camera_snapshot_usecase.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/constants/app_constants.dart';

part 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  CameraCubit({
    required CameraRepository cameraRepository,
    required GetCamerasUseCase getCamerasUseCase,
    required GetCameraByIdUseCase getCameraByIdUseCase,
    required GetStreamUrlUseCase getStreamUrlUseCase,
    required GetCameraSnapshotUseCase getCameraSnapshotUseCase,
  })  : _cameraRepository = cameraRepository,
        _getCamerasUseCase = getCamerasUseCase,
        _getCameraByIdUseCase = getCameraByIdUseCase,
        _getStreamUrlUseCase = getStreamUrlUseCase,
        _getCameraSnapshotUseCase = getCameraSnapshotUseCase,
        super(CameraInitial());

  final CameraRepository _cameraRepository;
  final GetCamerasUseCase _getCamerasUseCase;
  final GetCameraByIdUseCase _getCameraByIdUseCase;
  final GetStreamUrlUseCase _getStreamUrlUseCase;
  final GetCameraSnapshotUseCase _getCameraSnapshotUseCase;

  Future<void> fetchCameras() async {
    emit(CameraLoading());
    try {
      final cameras = await _getCamerasUseCase(const NoParams());
      
      // Construct snapshot URLs for each camera
      final camerasWithSnapshots = cameras.map((camera) {
        final snapshotUrl = '${AppConstants.apiBaseUrl}/stream/${camera.id}/snapshot';
        return camera.copyWith(snapshotUrl: snapshotUrl);
      }).toList();
      
      emit(CameraLoaded(cameras: camerasWithSnapshots));
    } catch (e) {
      emit(CameraError(message: errorMessage(mapToException(e))));
    }
  }

  Future<void> refreshCameras() async {
    emit(CameraInitial());
    await fetchCameras();
  }

  Future<void> startStream(String cameraId) async {
    emit(CameraStreamLoading());
    try {
      final streamUrl = await _getStreamUrlUseCase(GetStreamUrlParams(cameraId: cameraId));
      String? displayName;
      try {
        final cam = await _getCameraByIdUseCase(GetCameraByIdParams(cameraId: cameraId));
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

  Future<String> getCameraSnapshot(String cameraId) async {
    try {
      return await _getCameraSnapshotUseCase(GetCameraSnapshotParams(cameraId: cameraId));
    } catch (e) {
      emit(CameraError(message: errorMessage(mapToException(e))));
      rethrow;
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

  void clearError() {
    if (state is CameraError) {
      emit(CameraInitial());
    }
  }
}
