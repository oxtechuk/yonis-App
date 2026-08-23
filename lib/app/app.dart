import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'localization/locale_keys.g.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class YounisApp extends StatefulWidget {
  const YounisApp({super.key, this.appBuilder});

  final TransitionBuilder? appBuilder;

  @override
  State<YounisApp> createState() => _YounisAppState();
}

class _YounisAppState extends State<YounisApp> {
  // Created once and kept alive for the lifetime of the app.
  // Must live in State, not in the widget, so rebuilds never recreate it.
  late final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => LocaleKeys.appName.tr(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      builder: widget.appBuilder,
      routerConfig: _router,
    );
  }
}
