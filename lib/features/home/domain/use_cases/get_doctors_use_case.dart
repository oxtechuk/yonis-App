import '../../../../core/result/result.dart';
import '../entities/doctor.dart';
import '../repositories/doctors_repository.dart';

class GetDoctorsUseCase {
  const GetDoctorsUseCase(this._repository);

  final DoctorsRepository _repository;

  Future<Result<DoctorsResult>> call() => _repository.getDoctors();
}
