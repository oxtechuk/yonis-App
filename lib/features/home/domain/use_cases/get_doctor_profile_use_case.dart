import '../../../../core/result/result.dart';
import '../entities/doctor_profile.dart';
import '../repositories/doctor_profile_repository.dart';

class GetDoctorProfileUseCase {
  const GetDoctorProfileUseCase(this._repository);

  final DoctorProfileRepository _repository;

  Future<Result<DoctorProfile>> call() => _repository.getDoctorProfile();
}
