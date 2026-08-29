import 'package:equatable/equatable.dart';

class Service extends Equatable {
  const Service({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    this.duration,
    this.clinicPrice,
    this.chatPrice,
    this.voicePrice,
    this.videoPrice,
    this.isActive = true,
  });

  final int id;
  final String title;
  final String description;

  /// Where the service can be delivered: `clinic`, `online` or `both`.
  final String type;

  /// Base price used for the "starting from" label in the booking sheet.
  final double price;

  /// Session length in minutes.
  final int? duration;

  /// Per-delivery-channel pricing. Null means the channel is not offered
  /// for this service.
  final double? clinicPrice;
  final double? chatPrice;
  final double? voicePrice;
  final double? videoPrice;

  final bool isActive;

  /// Trims trailing zeros from the API price ("50.00" -> "50").
  String get displayPrice {
    if (price == price.truncateToDouble()) {
      return price.truncate().toString();
    }
    final fixed = price.toStringAsFixed(2);
    return fixed
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        price,
        duration,
        clinicPrice,
        chatPrice,
        voicePrice,
        videoPrice,
        isActive,
      ];
}
