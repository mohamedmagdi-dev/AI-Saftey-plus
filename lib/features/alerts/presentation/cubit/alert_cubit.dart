import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../../../core/network/api_exception.dart';

part 'alert_state.dart';

class AlertCubit extends Cubit<AlertState> {
  AlertCubit({required AlertRepository alertRepository})
      : _alertRepository = alertRepository,
        super(AlertInitial());

  final AlertRepository _alertRepository;

  Future<void> fetchAlerts({String? filter}) async {
    emit(AlertLoading());
    try {
      final alerts = await _alertRepository.getAlerts(filter: filter);
      emit(AlertLoaded(alerts: alerts, filter: filter));
    } catch (e) {
      emit(AlertError(message: errorMessage(mapToException(e))));
    }
  }

  Future<void> fetchAlertHistory({String? filter}) async {
    emit(AlertLoading());
    try {
      final alerts = await _alertRepository.getAlertHistory(filter: filter);
      emit(AlertHistoryLoaded(alerts: alerts, filter: filter));
    } catch (e) {
      emit(AlertError(message: errorMessage(mapToException(e))));
    }
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
}
