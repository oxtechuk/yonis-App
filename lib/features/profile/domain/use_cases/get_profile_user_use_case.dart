import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class GetProfileUserUseCase {
  const GetProfileUserUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<User>> call() => _repository.getUser();
}
