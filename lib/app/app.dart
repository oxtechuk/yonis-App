import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'localization/locale_keys.g.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class YounisApp extends StatelessWidget {
  YounisApp({super.key, this.appBuilder});

  /// Optional wrapper applied around the whole app (e.g. DevicePreview's
  /// appBuilder). Kept out of the default constructor so widget tests pump a
  /// clean tree; bootstrap injects it only in non-release modes.
  final TransitionBuilder? appBuilder;

  final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    // Reading the locale registers a dependency on easy_localization's
    // provider; keying by it forces a full rebuild of the navigation tree so
    // widgets that render via `.tr()` pick up the new translations.
    final locale = context.locale;
    return MaterialApp.router(
      key: ValueKey<Locale>(locale),
      onGenerateTitle: (context) => LocaleKeys.appName.tr(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      builder: appBuilder,
      routerConfig: _router,
    );
  }
}
