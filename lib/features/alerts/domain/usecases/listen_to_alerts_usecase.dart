import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

class ListenToAlertsUseCase {
  final AlertRepository repository;

  ListenToAlertsUseCase(this.repository);

  Stream<List<AlertEntity>> call({int intervalSeconds = 30}) {
    return repository.listenToAlerts(intervalSeconds: intervalSeconds);
  }
}
