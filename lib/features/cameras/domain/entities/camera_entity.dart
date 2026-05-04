import 'package:equatable/equatable.dart';

class CameraEntity extends Equatable {
  final String id;
  final String name;
  final String location;
  final bool isOnline;
  final String? thumbnailUrl;
  final String? streamUrl;

  const CameraEntity({
    required this.id,
    required this.name,
    required this.location,
    this.isOnline = true,
    this.thumbnailUrl,
    this.streamUrl,
  });

  @override
  List<Object?> get props => [id, name, location, isOnline, thumbnailUrl, streamUrl];
}
