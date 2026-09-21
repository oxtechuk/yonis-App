import '../../../../core/network/api_client.dart';
import '../models/payment_methods_config_dto.dart';

abstract interface class PaymentMethodsRemoteDataSource {
  Future<PaymentMethodsConfigDto> getPaymentMethods({bool activeOnly = true});
}

class ApiPaymentMethodsRemoteDataSource
    implements PaymentMethodsRemoteDataSource {
  const ApiPaymentMethodsRemoteDataSource(this._apiClient);

  static const String _path = '/api/payment-methods';

  final ApiClient _apiClient;

  @override
  Future<PaymentMethodsConfigDto> getPaymentMethods({
    bool activeOnly = true,
  }) async {
    final json = await _apiClient.get<Map<String, dynamic>>(
      _path,
      queryParameters: <String, dynamic>{
        if (activeOnly) 'active_only': true,
      },
    );
    return PaymentMethodsConfigDto.fromJson(json);
  }
}
