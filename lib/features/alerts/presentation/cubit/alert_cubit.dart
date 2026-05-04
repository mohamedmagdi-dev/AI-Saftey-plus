import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/usecases/get_alert_history_usecase.dart';
import '../../domain/usecases/send_notification_usecase.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/usecase/usecase.dart';

part 'alert_state.dart';

class AlertCubit extends Cubit<AlertState> {
  AlertCubit({
    required AlertRepository alertRepository,
    required GetAlertHistoryUseCase getAlertHistoryUseCase,
    required SendNotificationUseCase sendNotificationUseCase,
  })  : _alertRepository = alertRepository,
        _getAlertHistoryUseCase = getAlertHistoryUseCase,
        _sendNotificationUseCase = sendNotificationUseCase,
        super(AlertInitial());

  final AlertRepository _alertRepository;
  final GetAlertHistoryUseCase _getAlertHistoryUseCase;
  final SendNotificationUseCase _sendNotificationUseCase;

  Future<void> fetchAlerts({String? filter}) async {
    emit(AlertLoading());
    try {
      final alerts = await _alertRepository.getAlerts(filter: filter);
      emit(AlertLoaded(alerts: alerts, filter: filter));
      
      // Check for high priority alerts and send notifications
      await _handleHighPriorityAlerts(alerts);
    } catch (e) {
      emit(AlertError(message: errorMessage(mapToException(e))));
    }
  }

  Future<void> fetchAlertHistory({String? filter}) async {
    emit(AlertLoading());
    try {
      final alerts = await _getAlertHistoryUseCase(const NoParams());
      emit(AlertHistoryLoaded(alerts: alerts, filter: filter));
      
      // Check for high priority alerts and send notifications
      await _handleHighPriorityAlerts(alerts);
    } catch (e) {
      emit(AlertError(message: errorMessage(mapToException(e))));
    }
  }

  Future<void> refreshAlerts({String? filter}) async {
    // Clear current state and fetch fresh data
    emit(AlertInitial());
    await fetchAlertHistory(filter: filter);
  }

  void filterAlerts(String? filter) {
    if (state is AlertLoaded) {
      final currentState = state as AlertLoaded;
      emit(currentState.copyWith(filter: filter));
    } else if (state is AlertHistoryLoaded) {
      final currentState = state as AlertHistoryLoaded;
      emit(currentState.copyWith(filter: filter));
    }
  }

  Future<void> handleAlertTap(AlertEntity alert) async {
    try {
      // Send notification for high priority alerts
      if (alert.severity == AlertSeverity.high || alert.severity == AlertSeverity.critical) {
        await _sendNotificationUseCase(SendNotificationParams(
          alertId: alert.id,
          title: alert.title,
          description: alert.description,
          priority: alert.severity.name,
          imageUrl: alert.imageUrl,
        ));
      }
    } catch (e) {
      // Don't emit error state for notification failures, just log
      print('Failed to send notification: $e');
    }
  }

  void clearError() {
    if (state is AlertError) {
      emit(AlertInitial());
    }
  }

  Future<void> _handleHighPriorityAlerts(List<AlertEntity> alerts) async {
    try {
      final highPriorityAlerts = alerts.where((alert) => 
        alert.severity == AlertSeverity.high || alert.severity == AlertSeverity.critical
      ).toList();

      for (final alert in highPriorityAlerts) {
        await _sendNotificationUseCase(SendNotificationParams(
          alertId: alert.id,
          title: alert.title,
          description: alert.description,
          priority: alert.severity.name,
          imageUrl: alert.imageUrl,
        ));
      }
    } catch (e) {
      // Don't fail the main operation for notification issues
      print('Failed to handle high priority alerts: $e');
    }
  }
}
