import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

class GetAlertByIdUseCase {
  final AlertRepository repository;

  GetAlertByIdUseCase(this.repository);

  Future<AlertEntity> call(String id) {
    return repository.getAlertById(id);
  }
}
