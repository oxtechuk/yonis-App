import 'package:equatable/equatable.dart';

class DoctorProfile extends Equatable {
  const DoctorProfile({
    required this.title,
    required this.bio,
    required this.specialties,
    required this.socialLinks,
    this.heroImage,
  });

  final String title;
  final String bio;
  final List<String> specialties;
  final DoctorSocialLinks socialLinks;

  /// Nullable on purpose: the backend omits it when no photo was uploaded
  /// and presentation falls back to a bundled placeholder.
  final String? heroImage;

  @override
  List<Object?> get props => [title, bio, specialties, socialLinks, heroImage];
}

class DoctorSocialLinks extends Equatable {
  const DoctorSocialLinks({
    this.facebook,
    this.twitter,
    this.instagram,
    this.linkedin,
  });

  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? linkedin;

  @override
  List<Object?> get props => [facebook, twitter, instagram, linkedin];
}
