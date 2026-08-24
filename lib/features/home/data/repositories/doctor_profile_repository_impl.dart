import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/repositories/doctor_profile_repository.dart';
import '../sources/doctor_profile_remote_data_source.dart';

class DoctorProfileRepositoryImpl implements DoctorProfileRepository {
  const DoctorProfileRepositoryImpl({
    required DoctorProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final DoctorProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Result<DoctorProfile>> getDoctorProfile() async {
    try {
      final dto = await _remoteDataSource.getDoctorProfile();
      return Success(dto.toEntity());
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}
