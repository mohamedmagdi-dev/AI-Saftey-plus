import '../entities/alert_entity.dart';

class AlertModel extends AlertEntity {
  const AlertModel({
    required super.id,
    required super.title,
    required super.description,
    required super.timestamp,
    required super.severity,
    super.cameraId,
    super.location,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    final type = json['alert_type'] as String? ?? 'alert';
    final title = _formatAlertType(type);
    final message = json['message'] as String? ?? '';
    return AlertModel(
      id: _idToString(json['id'] ?? json['_id']),
      title: title,
      description: message,
      timestamp: _parseTimestamp(json['timestamp']),
      severity: _severityFromString((json['severity'] as String?) ?? 'medium'),
      cameraId: json['camera_id'] as String? ?? json['cameraId'] as String?,
      location: json['location'] as String?,
    );
  }

  static String _idToString(Object? value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static String _formatAlertType(String type) {
    if (type.isEmpty) return 'Alert';
    return type
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static DateTime _parseTimestamp(Object? value) {
    if (value is String) {
      return DateTime.parse(value);
    }
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static AlertSeverity _severityFromString(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return AlertSeverity.low;
      case 'medium':
        return AlertSeverity.medium;
      case 'high':
        return AlertSeverity.high;
      case 'critical':
        return AlertSeverity.critical;
      default:
        return AlertSeverity.medium;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
      'cameraId': cameraId,
      'location': location,
    };
  }
}
