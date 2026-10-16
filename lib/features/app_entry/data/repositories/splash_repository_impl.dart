import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/splash_config.dart';
import '../../domain/repositories/splash_repository.dart';
import '../sources/splash_remote_data_source.dart';

class SplashRepositoryImpl implements SplashRepository {
  const SplashRepositoryImpl({
    required SplashRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final SplashRemoteDataSource _remoteDataSource;

  @override
  Future<Result<SplashConfig>> getSplashConfig() async {
    try {
      final dto = await _remoteDataSource.getSplashConfig();
      return Success(dto.toEntity());
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}
