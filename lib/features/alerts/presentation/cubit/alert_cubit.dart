import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/usecases/get_alert_history_usecase.dart';
import '../../domain/usecases/listen_to_alerts_usecase.dart';
import '../../domain/usecases/get_alert_by_id_usecase.dart';
import '../../domain/usecases/send_notification_usecase.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/services/notification_service.dart';

part 'alert_state.dart';

class AlertCubit extends Cubit<AlertState> {
  AlertCubit({
    required AlertRepository alertRepository,
    required GetAlertHistoryUseCase getAlertHistoryUseCase,
    required ListenToAlertsUseCase listenToAlertsUseCase,
    required GetAlertByIdUseCase getAlertByIdUseCase,
    required SendNotificationUseCase sendNotificationUseCase,
  })  : _alertRepository = alertRepository,
        _getAlertHistoryUseCase = getAlertHistoryUseCase,
        _listenToAlertsUseCase = listenToAlertsUseCase,
        _getAlertByIdUseCase = getAlertByIdUseCase,
        _sendNotificationUseCase = sendNotificationUseCase,
        super(AlertInitial());

  final AlertRepository _alertRepository;
  final GetAlertHistoryUseCase _getAlertHistoryUseCase;
  final ListenToAlertsUseCase _listenToAlertsUseCase;
  final GetAlertByIdUseCase _getAlertByIdUseCase;
  final SendNotificationUseCase _sendNotificationUseCase;
  
  StreamSubscription<List<AlertEntity>>? _alertsSubscription;
  final Set<String> _notifiedAlertIds = {};

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

  Future<void> fetchAlertHistory({String? filter, String? highlightedId}) async {
    emit(AlertLoading());
    try {
      final alerts = await _getAlertHistoryUseCase(const NoParams());
      emit(AlertHistoryLoaded(
        alerts: alerts, 
        filter: filter,
        highlightedAlertId: highlightedId,
      ));
      
      // Check for high priority alerts and send notifications
      await _handleHighPriorityAlerts(alerts);
    } catch (e) {
      emit(AlertError(message: errorMessage(mapToException(e))));
    }
  }

  void listenToAlerts({int intervalSeconds = 30}) {
    _alertsSubscription?.cancel();
    _alertsSubscription = _listenToAlertsUseCase(intervalSeconds: intervalSeconds)
        .listen((newAlerts) {
      if (newAlerts.isNotEmpty) {
        _handleNewAlerts(newAlerts);
      }
    });
  }

  void _handleNewAlerts(List<AlertEntity> newAlerts) {
    // 1. Notify for high/critical alerts
    for (final alert in newAlerts) {
      if ((alert.severity == AlertSeverity.high || alert.severity == AlertSeverity.critical) &&
          !_notifiedAlertIds.contains(alert.id)) {
        NotificationService().handleHighPriorityAlert(
          alertId: alert.id,
          title: alert.title,
          description: alert.description,
          priority: alert.severity.name,
          cameraId: alert.cameraId,
        );
        _notifiedAlertIds.add(alert.id);
      }
    }

    // 2. Update state if on Loaded or HistoryLoaded state
    if (state is AlertLoaded) {
      final currentState = state as AlertLoaded;
      final updatedList = [...newAlerts, ...currentState.alerts];
      emit(currentState.copyWith(alerts: updatedList));
    } else if (state is AlertHistoryLoaded) {
      final currentState = state as AlertHistoryLoaded;
      final updatedList = [...newAlerts, ...currentState.alerts];
      emit(currentState.copyWith(alerts: updatedList));
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
        (alert.severity == AlertSeverity.high || alert.severity == AlertSeverity.critical) &&
        !_notifiedAlertIds.contains(alert.id)
      ).toList();

      for (final alert in highPriorityAlerts) {
        await NotificationService().handleHighPriorityAlert(
          alertId: alert.id,
          title: alert.title,
          description: alert.description,
          priority: alert.severity.name,
          cameraId: alert.cameraId,
        );
        _notifiedAlertIds.add(alert.id);
      }
    } catch (e) {
      print('Failed to handle high priority alerts: $e');
    }
  }

  @override
  Future<void> close() {
    _alertsSubscription?.cancel();
    return super.close();
  }
}
