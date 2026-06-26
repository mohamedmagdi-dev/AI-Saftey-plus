import 'dart:async';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/remote_alert_data_source.dart';
import '../../../../core/services/alert_polling_service.dart';

class AlertRepositoryImpl implements AlertRepository {
  AlertRepositoryImpl({required RemoteAlertDataSource remote})
      : _remote = remote;

  final RemoteAlertDataSource _remote;
  AlertPollingService? _pollingService;

  @override
  Future<List<AlertEntity>> getAlerts({String? filter}) =>
      _remote.getAlerts(filter: filter);

  @override
  Future<List<AlertEntity>> getAlertHistory({String? filter}) =>
      _remote.getAlertHistory(filter: filter);

  @override
  Future<AlertEntity> getAlertById(String id) => _remote.getAlertById(id);

  @override
  Stream<List<AlertEntity>> listenToAlerts({int intervalSeconds = 30}) {
    _pollingService ??= AlertPollingService(this);
    _pollingService!.startPolling(intervalSeconds: intervalSeconds);
    return _pollingService!.alertStream;
  }
}
