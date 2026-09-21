import '../../domain/entities/confirm_payment_result.dart';

class ConfirmPaymentResultDto {
  const ConfirmPaymentResultDto({
    required this.success,
    this.message,
    this.status,
  });

  factory ConfirmPaymentResultDto.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'];
    return ConfirmPaymentResultDto(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      status: (json['status'] ??
              (booking is Map<String, dynamic> ? booking['status'] : null))
          as String?,
    );
  }

  final bool success;
  final String? message;
  final String? status;

  ConfirmPaymentResult toEntity() => ConfirmPaymentResult(
        success: success,
        message: message,
        status: status,
      );
}
