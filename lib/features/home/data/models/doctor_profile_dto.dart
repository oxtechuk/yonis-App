import '../../../../core/error/app_exception.dart';
import '../../domain/entities/doctor_profile.dart';

class DoctorProfileDto {
  const DoctorProfileDto({
    required this.title,
    required this.bio,
    required this.specialties,
    required this.socialLinks,
    this.heroImage,
  });

  factory DoctorProfileDto.fromResponseJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    if (profile is! Map<String, dynamic>) {
      throw const SerializationException(
        message: 'Doctor profile response is missing the "profile" object.',
      );
    }
    return DoctorProfileDto.fromJson(profile);
  }

  factory DoctorProfileDto.fromJson(Map<String, dynamic> json) {
    final links = json['social_links'];
    final linksMap =
        links is Map<String, dynamic> ? links : const <String, dynamic>{};

    return DoctorProfileDto(
      title: _readString(json, 'title') ?? '',
      bio: _readString(json, 'bio') ?? '',
      specialties: (json['specialties'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      socialLinks: DoctorSocialLinksDto(
        facebook: _readString(linksMap, 'facebook'),
        twitter: _readString(linksMap, 'twitter'),
        instagram: _readString(linksMap, 'instagram'),
        linkedin: _readString(linksMap, 'linkedin'),
      ),
      heroImage: _readString(json, 'hero_image'),
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  final String title;
  final String bio;
  final List<String> specialties;
  final DoctorSocialLinksDto socialLinks;
  final String? heroImage;

  DoctorProfile toEntity() => DoctorProfile(
        title: title,
        bio: bio,
        specialties: specialties,
        socialLinks: DoctorSocialLinks(
          facebook: socialLinks.facebook,
          twitter: socialLinks.twitter,
          instagram: socialLinks.instagram,
          linkedin: socialLinks.linkedin,
        ),
        heroImage: heroImage,
      );
}

class DoctorSocialLinksDto {
  const DoctorSocialLinksDto({
    this.facebook,
    this.twitter,
    this.instagram,
    this.linkedin,
  });

  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? linkedin;
}
