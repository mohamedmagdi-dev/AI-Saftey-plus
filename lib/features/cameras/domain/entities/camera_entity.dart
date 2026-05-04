import 'package:equatable/equatable.dart';

class CameraEntity extends Equatable {
  final String id;
  final String name;
  final String location;
  final bool isOnline;
  final String? thumbnailUrl;
  final String? streamUrl;
  final String? snapshotUrl;
  final DateTime? lastSnapshotTime;
  final String? cameraType;
  final bool hasAI;

  const CameraEntity({
    required this.id,
    required this.name,
    required this.location,
    this.isOnline = true,
    this.thumbnailUrl,
    this.streamUrl,
    this.snapshotUrl,
    this.lastSnapshotTime,
    this.cameraType,
    this.hasAI = false,
  });

  CameraEntity copyWith({
    String? id,
    String? name,
    String? location,
    bool? isOnline,
    String? thumbnailUrl,
    String? streamUrl,
    String? snapshotUrl,
    DateTime? lastSnapshotTime,
    String? cameraType,
    bool? hasAI,
  }) {
    return CameraEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      snapshotUrl: snapshotUrl ?? this.snapshotUrl,
      lastSnapshotTime: lastSnapshotTime ?? this.lastSnapshotTime,
      cameraType: cameraType ?? this.cameraType,
      hasAI: hasAI ?? this.hasAI,
    );
  }

  @override
  List<Object?> get props => [
        id, 
        name, 
        location, 
        isOnline, 
        thumbnailUrl, 
        streamUrl, 
        snapshotUrl, 
        lastSnapshotTime, 
        cameraType, 
        hasAI
      ];
}
