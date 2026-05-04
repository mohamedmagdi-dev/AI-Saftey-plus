import 'package:equatable/equatable.dart';

enum AlertSeverity { low, medium, high, critical }

class AlertEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final AlertSeverity severity;
  final String? cameraId;
  final String? location;
  final String? imageUrl;
  final bool isRead;
  final String? alertType;

  const AlertEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    this.cameraId,
    this.location,
    this.imageUrl,
    this.isRead = false,
    this.alertType,
  });

  AlertEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    AlertSeverity? severity,
    String? cameraId,
    String? location,
    String? imageUrl,
    bool? isRead,
    String? alertType,
  }) {
    return AlertEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      cameraId: cameraId ?? this.cameraId,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      alertType: alertType ?? this.alertType,
    );
  }

  @override
  List<Object?> get props => [
        id, 
        title, 
        description, 
        timestamp, 
        severity, 
        cameraId, 
        location, 
        imageUrl, 
        isRead, 
        alertType
      ];
}
