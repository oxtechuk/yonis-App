import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/repositories/doctors_repository.dart';
import '../sources/doctors_remote_data_source.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  const DoctorsRepositoryImpl({
    required DoctorsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final DoctorsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<DoctorsResult>> getDoctors() async {
    try {
      final dto = await _remoteDataSource.getDoctors();
      return Success(dto.toEntity());
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}
