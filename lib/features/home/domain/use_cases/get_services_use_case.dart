import '../../../../core/result/result.dart';
import '../entities/service.dart';
import '../repositories/services_repository.dart';

class GetServicesUseCase {
  const GetServicesUseCase(this._repository);

  final ServicesRepository _repository;

  Future<Result<List<Service>>> call() => _repository.getServices();
}
