import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/services_repository.dart';
import '../sources/services_remote_data_source.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  const ServicesRepositoryImpl({
    required ServicesRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ServicesRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Service>>> getServices() async {
    try {
      final dto = await _remoteDataSource.getServices();
      return Success(
        dto.services.map((item) => item.toEntity()).toList(growable: false),
      );
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}
