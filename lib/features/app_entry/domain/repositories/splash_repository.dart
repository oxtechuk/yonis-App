import '../../../../core/result/result.dart';
import '../entities/splash_config.dart';

abstract interface class SplashRepository {
  Future<Result<SplashConfig>> getSplashConfig();
}
