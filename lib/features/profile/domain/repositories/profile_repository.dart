import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/app_config_links.dart';

abstract interface class ProfileRepository {
  Future<Result<User>> getUser();

  Future<Result<AppConfigLinks>> getConfigLinks();
}
