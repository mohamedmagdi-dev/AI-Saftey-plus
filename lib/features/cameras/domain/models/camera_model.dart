import '../entities/camera_entity.dart';

class CameraModel extends CameraEntity {
  const CameraModel({
    required super.id,
    required super.name,
    required super.location,
    super.isOnline,
    super.thumbnailUrl,
    super.streamUrl,
  });

  factory CameraModel.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] as String?)?.toLowerCase() ?? 'inactive';
    final rawUrl = json['url'] as String?;
    final cameraType = json['camera_type'] as String? ?? '';
    return CameraModel(
      id: _idToString(json['id'] ?? json['_id']),
      name: json['name'] as String? ?? 'Camera',
      location: _locationFromApi(cameraType),
      isOnline: status == 'active',
      thumbnailUrl: null,
      streamUrl: _streamSourceFromUrl(rawUrl),
    );
  }

  static String _idToString(Object? value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static String _locationFromApi(String cameraType) {
    switch (cameraType.toLowerCase()) {
      case 'rtsp':
        return 'RTSP';
      case 'online':
        return 'Online';
      case 'browser':
        return 'Browser / local';
      default:
        return cameraType.isEmpty ? 'Camera' : cameraType;
    }
  }

  /// For `browser` sources the app uses the server-side `/stream/{id}` feed.
  static String? _streamSourceFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url == 'browser') return null;
    return url;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'isOnline': isOnline,
      'thumbnailUrl': thumbnailUrl,
      'streamUrl': streamUrl,
    };
  }
}
