import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/check_user_result.dart';
import '../../domain/entities/checkout_result.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../sources/checkout_remote_data_source.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  const CheckoutRepositoryImpl({
    required CheckoutRemoteDataSource remoteDataSource,
    required SecureStorage secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage;

  final CheckoutRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  @override
  Future<Result<CheckUserResult>> checkUser({required String phone}) async {
    try {
      final dto = await _remoteDataSource.checkUser(phone: phone);
      return Success(dto.toEntity());
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }

  @override
  Future<Result<CheckoutResult>> initializeCheckout({
    required int serviceId,
    required String bookingType,
    required String consultationType,
    required String paymentMethod,
    required String date,
    required String startTime,
    required String title,
    String? notes,
    String? name,
    String? phone,
    String? email,
    String? password,
  }) async {
    try {
      final dto = await _remoteDataSource.initialize(<String, dynamic>{
        'service_id': serviceId,
        'booking_type': bookingType,
        'consultation_type': consultationType,
        'payment_method': paymentMethod,
        'date': date,
        'start_time': startTime,
        'title': title,
        'notes': notes,
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      });
      // The backend returns an access token for the (possibly newly
      // created) patient — persist it like login so the user stays
      // logged in across restarts (bootstrap restores from this key).
      final token = dto.token;
      if (dto.success && token != null && token.trim().isNotEmpty) {
        await _secureStorage.write(
          SecureStorageKeys.accessToken,
          token.trim(),
        );
      }
      return Success(dto.toEntity());
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}
