import 'package:equatable/equatable.dart';

/// A single payment method served by `/api/payment-methods`.
class PaymentMethodOption extends Equatable {
  const PaymentMethodOption({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.logo,
    this.image,
    this.qrImage,
    this.instructions,
    this.badge,
    this.iconClass,
    this.color,
    this.isEnabled = true,
  });

  /// Machine id sent back to checkout (e.g. `zaincash`, `superki`).
  final String id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String? logo;
  final String? image;
  final String? qrImage;
  final String? instructions;
  final String? badge;

  /// Bootstrap-icon class from the backend, e.g. `bi-wallet2`.
  final String? iconClass;

  /// Brand colour as a hex string, e.g. `#7c3aed`.
  final String? color;
  final bool isEnabled;

  String nameFor(bool isArabic) {
    final localized = isArabic ? nameAr : nameEn;
    if (localized != null && localized.trim().isNotEmpty) return localized;
    return name;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        nameEn,
        logo,
        image,
        qrImage,
        instructions,
        badge,
        iconClass,
        color,
        isEnabled,
      ];
}

/// Full payload of `/api/payment-methods` — the method list plus the
/// account-level defaults that come with it.
class PaymentMethodsConfig extends Equatable {
  const PaymentMethodsConfig({
    required this.methods,
    this.defaultMethod,
    this.whatsappNumber,
  });

  final List<PaymentMethodOption> methods;
  final String? defaultMethod;
  final String? whatsappNumber;

  @override
  List<Object?> get props => [methods, defaultMethod, whatsappNumber];
}
