part of 'camera_cubit.dart';

abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraLoaded extends CameraState {
  final List<CameraEntity> cameras;

  const CameraLoaded({required this.cameras});

  @override
  List<Object?> get props => [cameras];
}

class CameraStreamLoading extends CameraState {}

class CameraStreamActive extends CameraState {
  final String cameraId;
  final String streamUrl;
  final String? displayName;
  final List<BoundingBox> boundingBoxes;

  const CameraStreamActive({
    required this.cameraId,
    required this.streamUrl,
    this.displayName,
    this.boundingBoxes = const [],
  });

  CameraStreamActive copyWith({
    String? cameraId,
    String? streamUrl,
    String? displayName,
    List<BoundingBox>? boundingBoxes,
  }) {
    return CameraStreamActive(
      cameraId: cameraId ?? this.cameraId,
      streamUrl: streamUrl ?? this.streamUrl,
      displayName: displayName ?? this.displayName,
      boundingBoxes: boundingBoxes ?? this.boundingBoxes,
    );
  }

  @override
  List<Object?> get props => [cameraId, streamUrl, displayName, boundingBoxes];
}

class CameraStreamStopped extends CameraState {}

class CameraError extends CameraState {
  final String message;

  const CameraError({required this.message});

  @override
  List<Object?> get props => [message];
}
