import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  const Doctor({
    required this.id,
    required this.name,
    this.nameEn,
    this.title,
    this.titleEn,
    this.specialty,
    this.specialtyEn,
    this.avatarUrl,
    this.bio,
    this.bioEn,
    this.phone,
    this.email,
    this.experienceYears,
    this.consultationFee,
  });

  final int id;
  final String name;
  final String? nameEn;
  final String? title;
  final String? titleEn;
  final String? specialty;
  final String? specialtyEn;
  final String? avatarUrl;
  final String? bio;
  final String? bioEn;
  final String? phone;
  final String? email;
  final int? experienceYears;
  final num? consultationFee;

  String nameFor(bool isArabic) {
    if (!isArabic && nameEn != null && nameEn!.trim().isNotEmpty) {
      return nameEn!.trim();
    }
    return name;
  }

  String? titleFor(bool isArabic) {
    if (!isArabic && titleEn != null && titleEn!.trim().isNotEmpty) {
      return titleEn!.trim();
    }
    return (title != null && title!.trim().isNotEmpty) ? title!.trim() : null;
  }

  String? specialtyFor(bool isArabic) {
    if (!isArabic && specialtyEn != null && specialtyEn!.trim().isNotEmpty) {
      return specialtyEn!.trim();
    }
    return (specialty != null && specialty!.trim().isNotEmpty)
        ? specialty!.trim()
        : null;
  }

  String? bioFor(bool isArabic) {
    if (!isArabic && bioEn != null && bioEn!.trim().isNotEmpty) {
      return bioEn!.trim();
    }
    return (bio != null && bio!.trim().isNotEmpty) ? bio!.trim() : null;
  }

  String? get displayConsultationFee {
    final fee = consultationFee;
    if (fee == null) return null;
    if (fee == fee.truncateToDouble()) {
      return fee.truncate().toString();
    }
    return fee.toStringAsFixed(2);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameEn,
        title,
        titleEn,
        specialty,
        specialtyEn,
        avatarUrl,
        bio,
        bioEn,
        phone,
        email,
        experienceYears,
        consultationFee,
      ];
}

class DoctorsResult extends Equatable {
  const DoctorsResult({
    required this.isSingleDoctor,
    required this.doctors,
    this.autoSelectedDoctor,
  });

  final bool isSingleDoctor;
  final Doctor? autoSelectedDoctor;
  final List<Doctor> doctors;

  /// Skip manual selection when the backend signals a single doctor,
  /// provides `auto_selected_doctor`, or returns at most 1 doctor.
  bool get shouldSkipSelection =>
      isSingleDoctor || autoSelectedDoctor != null || doctors.length <= 1;

  Doctor? get effectiveAutoSelectedDoctor =>
      autoSelectedDoctor ?? (doctors.isNotEmpty ? doctors.first : null);

  @override
  List<Object?> get props => [isSingleDoctor, autoSelectedDoctor, doctors];
}
