import 'package:equatable/equatable.dart';

/// Remote app links served by `GET /api/config`.
///
/// ```json
/// {
///   "success": true,
///   "app_rating_url": "https://play.google.com/...",
///   "privacy_policy_url": "https://younis-almurshid.com/privacytt",
///   "terms_conditions_url": "https://younis-almurshid.com/terms",
///   "terms_url": "https://younis-almurshid.com/terms"
/// }
/// ```
class AppConfigLinks extends Equatable {
  const AppConfigLinks({
    this.appRatingUrl = '',
    this.privacyPolicyUrl = '',
    this.termsConditionsUrl = '',
    this.termsUrl = '',
  });

  final String appRatingUrl;
  final String privacyPolicyUrl;
  final String termsConditionsUrl;
  final String termsUrl;

  /// Last-known good values (from `GET /api/config`) used when the
  /// config fetch fails so the menu never ends up with dead entries.
  static const AppConfigLinks fallback = AppConfigLinks(
    appRatingUrl:
        'https://play.google.com/store/apps/details?id=com.yonis.clinic',
    privacyPolicyUrl: 'https://younis-almurshid.com/privacytt',
    termsConditionsUrl: 'https://younis-almurshid.com/terms',
    termsUrl: 'https://younis-almurshid.com/terms',
  );

  /// Backfills every empty field from [other] (normally
  /// [AppConfigLinks.fallback]). `GET /api/config` can succeed while
  /// omitting individual links; without this a partial response would
  /// leave menu entries pointing at an empty URL, which surfaces a
  /// generic error toast when tapped.
  AppConfigLinks withFallback(AppConfigLinks other) => AppConfigLinks(
        appRatingUrl: appRatingUrl.isNotEmpty ? appRatingUrl : other.appRatingUrl,
        privacyPolicyUrl:
            privacyPolicyUrl.isNotEmpty ? privacyPolicyUrl : other.privacyPolicyUrl,
        termsConditionsUrl: termsConditionsUrl.isNotEmpty
            ? termsConditionsUrl
            : other.termsConditionsUrl,
        termsUrl: termsUrl.isNotEmpty ? termsUrl : other.termsUrl,
      );

  /// `dataPrivacy` menu entry: prefers `terms_conditions_url`,
  /// falls back to the legacy `terms_url`.
  String get termsDisplayUrl =>
      termsConditionsUrl.isNotEmpty ? termsConditionsUrl : termsUrl;

  @override
  List<Object?> get props => [
        appRatingUrl,
        privacyPolicyUrl,
        termsConditionsUrl,
        termsUrl,
      ];

  @override
  String toString() =>
      'AppConfigLinks(appRatingUrl: $appRatingUrl, '
      'privacyPolicyUrl: $privacyPolicyUrl, '
      'termsConditionsUrl: $termsConditionsUrl, termsUrl: $termsUrl)';
}
