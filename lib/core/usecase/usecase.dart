import 'package:equatable/equatable.dart';

abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

abstract class Params extends Equatable {
  const Params();
}

class NoParams extends Params {
  const NoParams();

  @override
  List<Object?> get props => [];
}
