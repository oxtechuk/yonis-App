import '../../../../core/network/api_client.dart';
import '../models/check_user_dto.dart';
import '../models/checkout_result_dto.dart';

abstract interface class CheckoutRemoteDataSource {
  Future<CheckUserResultDto> checkUser({required String phone});

  Future<CheckoutResultDto> initialize(Map<String, dynamic> body);
}

class ApiCheckoutRemoteDataSource implements CheckoutRemoteDataSource {
  const ApiCheckoutRemoteDataSource(this._apiClient);

  static const String _checkUserPath = '/api/checkout/check-user';
  static const String _initializePath = '/api/checkout/initialize';

  final ApiClient _apiClient;

  @override
  Future<CheckUserResultDto> checkUser({required String phone}) async {
    final json = await _apiClient.post<Map<String, dynamic>>(
      _checkUserPath,
      data: <String, dynamic>{'phone': phone},
    );
    return CheckUserResultDto.fromJson(json);
  }

  @override
  Future<CheckoutResultDto> initialize(Map<String, dynamic> body) async {
    final json = await _apiClient.post<Map<String, dynamic>>(
      _initializePath,
      data: body,
    );
    return CheckoutResultDto.fromJson(json);
  }
}
