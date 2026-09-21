import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/check_user_dto.dart';
import '../models/checkout_result_dto.dart';
import '../models/confirm_payment_result_dto.dart';

abstract interface class CheckoutRemoteDataSource {
  Future<CheckUserResultDto> checkUser({required String phone});

  Future<CheckoutResultDto> initialize(Map<String, dynamic> body);

  Future<ConfirmPaymentResultDto> confirmPayment({
    required String bookingRef,
    required String paymentMethod,
    required String transferNumber,
    String? transactionReference,
    required String receiptImagePath,
  });

  Future<ConfirmPaymentResultDto> confirmLocalPayment({
    required String bookingReference,
    required String paymentMethod,
    required String transferNumber,
    String? transactionReference,
    String? notes,
  });
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

  @override
  Future<ConfirmPaymentResultDto> confirmPayment({
    required String bookingRef,
    required String paymentMethod,
    required String transferNumber,
    String? transactionReference,
    required String receiptImagePath,
  }) async {
    final fileName = receiptImagePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap(<String, dynamic>{
      'booking_ref': bookingRef,
      'payment_method': paymentMethod,
      'transfer_number': transferNumber,
      if (transactionReference != null && transactionReference.isNotEmpty)
        'transaction_reference': transactionReference,
      'receipt_image': await MultipartFile.fromFile(
        receiptImagePath,
        filename: fileName,
      ),
    });

    final json = await _apiClient.post<Map<String, dynamic>>(
      '/api/booking/$bookingRef/confirm-payment',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return ConfirmPaymentResultDto.fromJson(json);
  }

  @override
  Future<ConfirmPaymentResultDto> confirmLocalPayment({
    required String bookingReference,
    required String paymentMethod,
    required String transferNumber,
    String? transactionReference,
    String? notes,
  }) async {
    final json = await _apiClient.post<Map<String, dynamic>>(
      '/api/payment/confirm-local',
      data: <String, dynamic>{
        'booking_reference': bookingReference,
        'payment_method': paymentMethod,
        'transfer_number': transferNumber,
        if (transactionReference != null && transactionReference.isNotEmpty)
          'transaction_reference': transactionReference,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return ConfirmPaymentResultDto.fromJson(json);
  }
}
