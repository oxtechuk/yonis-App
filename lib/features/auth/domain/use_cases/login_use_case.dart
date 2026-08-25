import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession>> call({
    required String identifier,
    required String password,
  }) =>
      _repository.login(identifier: identifier, password: password);
}
