import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/payment_method_option.dart';
import '../../domain/repositories/payment_methods_repository.dart';
import '../sources/payment_methods_remote_data_source.dart';

class PaymentMethodsRepositoryImpl implements PaymentMethodsRepository {
  const PaymentMethodsRepositoryImpl({
    required PaymentMethodsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PaymentMethodsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<PaymentMethodsConfig>> getPaymentMethods({
    bool activeOnly = true,
  }) async {
    try {
      final dto = await _remoteDataSource.getPaymentMethods(
        activeOnly: activeOnly,
      );
      return Success(dto.toEntity());
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}
