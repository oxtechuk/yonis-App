import '../../../../core/result/result.dart';
import '../entities/app_config_links.dart';
import '../repositories/profile_repository.dart';

class GetAppConfigLinksUseCase {
  const GetAppConfigLinksUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<AppConfigLinks>> call() => _repository.getConfigLinks();
}
