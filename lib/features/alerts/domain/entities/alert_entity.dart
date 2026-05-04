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

  const AlertEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    this.cameraId,
    this.location,
  });

  @override
  List<Object?> get props => [id, title, description, timestamp, severity, cameraId, location];
}
