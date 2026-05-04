import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterParams extends Params {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
  });

  final String email;
  final String password;
  final String name;

  @override
  List<Object?> get props => [email, password, name];
}

class RegisterUseCase extends UseCase<String, RegisterParams> {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<String> call(RegisterParams params) async {
    return _repository.register(
      username: params.name,
      password: params.password,
      email: params.email,
    );
  }
}
