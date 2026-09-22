import '../../../../core/result/result.dart';
import '../repositories/profile_repository.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<void>> call() => _repository.deleteAccount();
}
