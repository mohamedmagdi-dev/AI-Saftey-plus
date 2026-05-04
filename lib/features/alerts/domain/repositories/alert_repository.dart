import '../entities/alert_entity.dart';

abstract class AlertRepository {
  Future<List<AlertEntity>> getAlerts({String? filter});
  Future<List<AlertEntity>> getAlertHistory({String? filter});
  Future<AlertEntity> getAlertById(String id);
}
