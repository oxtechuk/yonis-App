import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/user.dart';

abstract interface class ProfileRepository {
  Future<Result<User>> getUser();
}
