import '../../../../core/usecase/usecase.dart';
import '../../../../core/services/notification_service.dart';

class SendNotificationParams extends Params {
  const SendNotificationParams({
    required this.alertId,
    required this.title,
    required this.description,
    required this.priority,
    this.imageUrl,
    this.recipientId,
  });

  final String alertId;
  final String title;
  final String description;
  final String priority;
  final String? imageUrl;
  final String? recipientId;

  @override
  List<Object?> get props => [
        alertId,
        title,
        description,
        priority,
        imageUrl,
        recipientId,
      ];
}

class SendNotificationUseCase extends UseCase<void, SendNotificationParams> {
  SendNotificationUseCase(this._notificationService);

  final NotificationService _notificationService;

  @override
  Future<void> call(SendNotificationParams params) async {
    await _notificationService.handleHighPriorityAlert(
      alertId: params.alertId,
      title: params.title,
      description: params.description,
      priority: params.priority,
      imageUrl: params.imageUrl,
      recipientId: params.recipientId,
    );
  }
}
