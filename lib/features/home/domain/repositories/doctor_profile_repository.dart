import '../../../../core/result/result.dart';
import '../entities/doctor_profile.dart';

abstract interface class DoctorProfileRepository {
  Future<Result<DoctorProfile>> getDoctorProfile();
}
