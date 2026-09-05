import '../../../../core/result/result.dart';
import '../entities/check_user_result.dart';
import '../repositories/checkout_repository.dart';

class CheckUserUseCase {
  const CheckUserUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<Result<CheckUserResult>> call({required String phone}) =>
      _repository.checkUser(phone: phone);
}
