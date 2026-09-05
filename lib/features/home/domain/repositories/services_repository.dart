import '../../../../core/result/result.dart';
import '../entities/service.dart';

abstract interface class ServicesRepository {
  Future<Result<List<Service>>> getClinicServices();

  Future<Result<List<Service>>> getOnlineServices();
}
