import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LoginParams extends Params {
  const LoginParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class LoginUseCase extends UseCase<String, LoginParams> {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<String> call(LoginParams params) async {
    return _repository.login(username: params.email, password: params.password);
  }
}
