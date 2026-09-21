import '../../domain/entities/app_config_links.dart';

/// DTO for `GET /api/config`. All URL fields are optional — a missing
/// key maps to an empty string so one absent link never breaks the rest.
class AppConfigLinksDto {
  const AppConfigLinksDto({
    this.appRatingUrl = '',
    this.privacyPolicyUrl = '',
    this.termsConditionsUrl = '',
    this.termsUrl = '',
  });

  final String appRatingUrl;
  final String privacyPolicyUrl;
  final String termsConditionsUrl;
  final String termsUrl;

  static String _stringOrEmpty(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value.trim();
    return '';
  }

  factory AppConfigLinksDto.fromJson(Map<String, dynamic> json) {
    return AppConfigLinksDto(
      appRatingUrl: _stringOrEmpty(json, 'app_rating_url'),
      privacyPolicyUrl: _stringOrEmpty(json, 'privacy_policy_url'),
      termsConditionsUrl: _stringOrEmpty(json, 'terms_conditions_url'),
      termsUrl: _stringOrEmpty(json, 'terms_url'),
    );
  }

  AppConfigLinks toEntity() => AppConfigLinks(
        appRatingUrl: appRatingUrl,
        privacyPolicyUrl: privacyPolicyUrl,
        termsConditionsUrl: termsConditionsUrl,
        termsUrl: termsUrl,
      );
}
