import '../../domain/entities/doctor.dart';

class DoctorsResponseDto {
  const DoctorsResponseDto({
    required this.isSingleDoctor,
    required this.doctors,
    this.autoSelectedDoctor,
  });

  final bool isSingleDoctor;
  final DoctorDto? autoSelectedDoctor;
  final List<DoctorDto> doctors;

  factory DoctorsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawList = json['doctors'] ?? json['data'];
    final doctors = _parseDoctorsList(rawList);
    final isSingleDoctor = _readBool(
      json,
      'is_single_doctor',
      defaultValue: doctors.length <= 1,
    );

    final rawAutoSelected = json['auto_selected_doctor'];
    DoctorDto? autoSelectedDoctor;
    if (rawAutoSelected is Map<String, dynamic>) {
      autoSelectedDoctor = DoctorDto.fromJson(rawAutoSelected);
    } else if (rawAutoSelected is num) {
      final id = rawAutoSelected.toInt();
      for (final d in doctors) {
        if (d.id == id) {
          autoSelectedDoctor = d;
          break;
        }
      }
    } else if (rawAutoSelected is String && rawAutoSelected.trim().isNotEmpty) {
      final id = int.tryParse(rawAutoSelected.trim());
      if (id != null) {
        for (final d in doctors) {
          if (d.id == id) {
            autoSelectedDoctor = d;
            break;
          }
        }
      }
    }

    return DoctorsResponseDto(
      isSingleDoctor: isSingleDoctor,
      autoSelectedDoctor: autoSelectedDoctor,
      doctors: doctors,
    );
  }

  static List<DoctorDto> _parseDoctorsList(dynamic jsonList) {
    if (jsonList is! List<dynamic>) return const [];
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(DoctorDto.fromJson)
        .toList(growable: false);
  }

  static bool _readBool(
    Map<String, dynamic> json,
    String key, {
    required bool defaultValue,
  }) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return defaultValue;
  }

  DoctorsResult toEntity() => DoctorsResult(
        isSingleDoctor: isSingleDoctor,
        autoSelectedDoctor: autoSelectedDoctor?.toEntity(),
        doctors: doctors.map((d) => d.toEntity()).toList(growable: false),
      );
}

class DoctorDto {
  const DoctorDto({
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

  factory DoctorDto.fromJson(Map<String, dynamic> json) {
    return DoctorDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _readString(json, 'name') ?? '',
      nameEn: _readString(json, 'name_en'),
      title: _readString(json, 'title'),
      titleEn: _readString(json, 'title_en'),
      specialty: _readString(json, 'specialty'),
      specialtyEn: _readString(json, 'specialty_en'),
      avatarUrl: _readString(json, 'avatar_url'),
      bio: _readString(json, 'bio'),
      bioEn: _readString(json, 'bio_en'),
      phone: _readString(json, 'phone'),
      email: _readString(json, 'email'),
      experienceYears: _readInt(json, 'experience_years'),
      consultationFee: _readNum(json, 'consultation_fee'),
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static num? _readNum(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value;
    if (value is String) return num.tryParse(value.trim());
    return null;
  }

  Doctor toEntity() => Doctor(
        id: id,
        name: name,
        nameEn: nameEn,
        title: title,
        titleEn: titleEn,
        specialty: specialty,
        specialtyEn: specialtyEn,
        avatarUrl: avatarUrl,
        bio: bio,
        bioEn: bioEn,
        phone: phone,
        email: email,
        experienceYears: experienceYears,
        consultationFee: consultationFee,
      );
}
