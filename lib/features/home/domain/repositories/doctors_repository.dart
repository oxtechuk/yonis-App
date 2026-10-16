import '../../../../core/result/result.dart';
import '../entities/doctor.dart';

abstract interface class DoctorsRepository {
  Future<Result<DoctorsResult>> getDoctors();
}
