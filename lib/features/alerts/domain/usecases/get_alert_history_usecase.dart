import '../../../../core/usecase/usecase.dart';
import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

class GetAlertHistoryUseCase extends UseCase<List<AlertEntity>, NoParams> {
  GetAlertHistoryUseCase(this._repository);

  final AlertRepository _repository;

  @override
  Future<List<AlertEntity>> call(NoParams params) async {
    return _repository.getAlertHistory();
  }
}
