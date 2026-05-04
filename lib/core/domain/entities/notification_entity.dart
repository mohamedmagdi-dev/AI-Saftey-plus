import 'package:equatable/equatable.dart';

enum NotificationPriority { low, medium, high, critical }

enum NotificationType { alert, system, info, warning }

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationPriority priority;
  final NotificationType type;
  final DateTime timestamp;
  final String? imageUrl;
  final String? alertId;
  final String? recipientId;
  final bool isRead;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    required this.type,
    required this.timestamp,
    this.imageUrl,
    this.alertId,
    this.recipientId,
    this.isRead = false,
    this.readAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    NotificationPriority? priority,
    NotificationType? type,
    DateTime? timestamp,
    String? imageUrl,
    String? alertId,
    String? recipientId,
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      alertId: alertId ?? this.alertId,
      recipientId: recipientId ?? this.recipientId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  NotificationEntity markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  bool get isHighPriority => 
      priority == NotificationPriority.high || priority == NotificationPriority.critical;

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        priority,
        type,
        timestamp,
        imageUrl,
        alertId,
        recipientId,
        isRead,
        readAt,
      ];
}
