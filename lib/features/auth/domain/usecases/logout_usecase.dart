import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends UseCase<void, NoParams> {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) async {
    return _repository.logout();
  }
}
