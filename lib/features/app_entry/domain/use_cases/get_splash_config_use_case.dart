import '../../../../core/result/result.dart';
import '../entities/splash_config.dart';
import '../repositories/splash_repository.dart';

class GetSplashConfigUseCase {
  const GetSplashConfigUseCase(this._repository);

  final SplashRepository _repository;

  Future<Result<SplashConfig>> call() => _repository.getSplashConfig();
}
