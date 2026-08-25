import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

/// Lightweight country-code data — no external package required.
class CountryCode {
  const CountryCode({
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.isoCode,
  });

  final String name;
  final String flag;
  final String dialCode;
  final String isoCode;

  /// Country display name following the current app locale
  /// (falls back to the English [name] if a translation is missing).
  String localizedName(BuildContext context) {
    final key = 'countries.$isoCode';
    return trExists(key, context: context) ? context.tr(key) : name;
  }

  @override
  String toString() => dialCode;
}

const List<CountryCode> kCountryCodes = [
  CountryCode(name: 'Saudi Arabia',       flag: '🇸🇦', dialCode: '+966', isoCode: 'SA'),
  CountryCode(name: 'United Arab Emirates', flag: '🇦🇪', dialCode: '+971', isoCode: 'AE'),
  CountryCode(name: 'Kuwait',             flag: '🇰🇼', dialCode: '+965', isoCode: 'KW'),
  CountryCode(name: 'Bahrain',            flag: '🇧🇭', dialCode: '+973', isoCode: 'BH'),
  CountryCode(name: 'Qatar',              flag: '🇶🇦', dialCode: '+974', isoCode: 'QA'),
  CountryCode(name: 'Oman',               flag: '🇴🇲', dialCode: '+968', isoCode: 'OM'),
  CountryCode(name: 'Jordan',             flag: '🇯🇴', dialCode: '+962', isoCode: 'JO'),
  CountryCode(name: 'Egypt',              flag: '🇪🇬', dialCode: '+20',  isoCode: 'EG'),
  CountryCode(name: 'Iraq',               flag: '🇮🇶', dialCode: '+964', isoCode: 'IQ'),
  CountryCode(name: 'Lebanon',            flag: '🇱🇧', dialCode: '+961', isoCode: 'LB'),
  CountryCode(name: 'Syria',              flag: '🇸🇾', dialCode: '+963', isoCode: 'SY'),
  CountryCode(name: 'Yemen',              flag: '🇾🇪', dialCode: '+967', isoCode: 'YE'),
  CountryCode(name: 'Libya',              flag: '🇱🇾', dialCode: '+218', isoCode: 'LY'),
  CountryCode(name: 'Tunisia',            flag: '🇹🇳', dialCode: '+216', isoCode: 'TN'),
  CountryCode(name: 'Algeria',            flag: '🇩🇿', dialCode: '+213', isoCode: 'DZ'),
  CountryCode(name: 'Morocco',            flag: '🇲🇦', dialCode: '+212', isoCode: 'MA'),
  CountryCode(name: 'Sudan',              flag: '🇸🇩', dialCode: '+249', isoCode: 'SD'),
  CountryCode(name: 'Turkey',             flag: '🇹🇷', dialCode: '+90',  isoCode: 'TR'),
  CountryCode(name: 'Pakistan',           flag: '🇵🇰', dialCode: '+92',  isoCode: 'PK'),
  CountryCode(name: 'India',              flag: '🇮🇳', dialCode: '+91',  isoCode: 'IN'),
  CountryCode(name: 'United Kingdom',     flag: '🇬🇧', dialCode: '+44',  isoCode: 'GB'),
  CountryCode(name: 'United States',      flag: '🇺🇸', dialCode: '+1',   isoCode: 'US'),
  CountryCode(name: 'Germany',            flag: '🇩🇪', dialCode: '+49',  isoCode: 'DE'),
  CountryCode(name: 'France',             flag: '🇫🇷', dialCode: '+33',  isoCode: 'FR'),
];
