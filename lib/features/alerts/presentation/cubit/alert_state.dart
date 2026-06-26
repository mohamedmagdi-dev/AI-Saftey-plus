part of 'alert_cubit.dart';

abstract class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

class AlertInitial extends AlertState {}

class AlertLoading extends AlertState {}

class AlertLoaded extends AlertState {
  final List<AlertEntity> alerts;
  final String? filter;

  const AlertLoaded({required this.alerts, this.filter});

  AlertLoaded copyWith({
    List<AlertEntity>? alerts,
    String? filter,
  }) {
    return AlertLoaded(
      alerts: alerts ?? this.alerts,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [alerts, filter];
}

class AlertHistoryLoaded extends AlertState {
  final List<AlertEntity> alerts;
  final String? filter;
  final String? highlightedAlertId;

  const AlertHistoryLoaded({
    required this.alerts, 
    this.filter,
    this.highlightedAlertId,
  });

  AlertHistoryLoaded copyWith({
    List<AlertEntity>? alerts,
    String? filter,
    String? highlightedAlertId,
  }) {
    return AlertHistoryLoaded(
      alerts: alerts ?? this.alerts,
      filter: filter ?? this.filter,
      highlightedAlertId: highlightedAlertId ?? this.highlightedAlertId,
    );
  }

  @override
  List<Object?> get props => [alerts, filter, highlightedAlertId];
}

class AlertError extends AlertState {
  final String message;

  const AlertError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AlertPollingState extends AlertState {
  final bool isPolling;
  final List<AlertEntity> newAlerts;

  const AlertPollingState({required this.isPolling, this.newAlerts = const []});

  @override
  List<Object?> get props => [isPolling, newAlerts];
}
