// ignore: unnecessary_import
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/widgets.dart';

/// Reading direction derived from the active locale.
///
/// Screens are authored Arabic-first, but the layout direction must follow
/// the chosen language: forcing [TextDirection.rtl] leaves English text
/// right-aligned with punctuation stranded on the wrong edge.
extension LocaleDirection on BuildContext {
  /// `true` when the active locale is right-to-left (currently Arabic).
  bool get isRtl => locale.languageCode == 'ar';

  /// [TextDirection] matching the active locale.
  TextDirection get localeTextDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;
}
