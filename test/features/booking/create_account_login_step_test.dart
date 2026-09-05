import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/app/localization/app_localization.dart';
import 'package:younis_app/core/error/failure.dart';
import 'package:younis_app/features/auth/domain/entities/user.dart';
import 'package:younis_app/features/auth/presentation/cubit/login_cubit.dart';
import 'package:younis_app/features/booking/domain/entities/check_user_result.dart';
import 'package:younis_app/features/booking/domain/entities/checkout_user.dart';
import 'package:younis_app/features/booking/presentation/cubit/check_user_cubit.dart';
import 'package:younis_app/features/booking/presentation/widgets/booking_create_account_section.dart';

Widget _sectionFor({required CheckUserState checkState, required LoginState loginState}) {
  return EasyLocalization(
    supportedLocales: AppLocalization.supportedLocales,
    path: AppLocalization.translationsPath,
    fallbackLocale: AppLocalization.fallbackLocale,
    startLocale: AppLocalization.defaultLocale,
    assetLoader: const _TestFileAssetLoader(),
    child: Builder(
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: Scaffold(
            body: CreateAccountSection(
              nameController: TextEditingController(),
              phoneController: TextEditingController(),
              emailController: TextEditingController(),
              passwordController: TextEditingController(),
              obscurePassword: true,
              onTogglePassword: () {},
              checkState: checkState,
              onCheckPhone: (_) {},
              onChangePhone: () {},
              loginPasswordController: TextEditingController(),
              obscureLoginPassword: true,
              onToggleLoginPassword: () {},
              loginState: loginState,
              onLogin: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
}

class _TestFileAssetLoader extends AssetLoader {
  const _TestFileAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final file = File('assets/locales/${locale.languageCode}.json');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}

const _registeredResult = CheckUserResult(
  isRegistered: true,
  requiresAccount: false,
  requiresPassword: false,
  message: 'العميل مسجل مسبقاً في النظام.',
  user: CheckoutUser(
    id: 7,
    name: 'أحمد محمد عبد الله',
    phone: '+9647701234567',
    email: 'ahmed@example.com',
  ),
);

void main() {
  testWidgets(
    'a recognized account shows a password field and login button, not '
    'the confirmed-login state',
    (tester) async {
      await tester.pumpWidget(
        _sectionFor(
          checkState: const CheckUserLoaded(_registeredResult),
          loginState: const LoginInitial(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سجل الدخول لإكمال الحجز'), findsOneWidget);
      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.text('تم تسجيل الدخول بنجاح'), findsNothing);
    },
  );

  testWidgets(
    'once logged in, the password field and login button are replaced by '
    'a success confirmation',
    (tester) async {
      await tester.pumpWidget(
        _sectionFor(
          checkState: const CheckUserLoaded(_registeredResult),
          loginState: const LoginSuccess(
            User(
              id: 7,
              name: 'أحمد محمد عبد الله',
              email: 'ahmed@example.com',
              phone: '+9647701234567',
              role: 'patient',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تم تسجيل الدخول بنجاح'), findsOneWidget);
      expect(find.text('سجل الدخول لإكمال الحجز'), findsNothing);
      expect(find.text('تسجيل الدخول'), findsNothing);
    },
  );

  testWidgets('a failed login shows the error message inline', (tester) async {
    await tester.pumpWidget(
      _sectionFor(
        checkState: const CheckUserLoaded(_registeredResult),
        loginState: const LoginError(NetworkFailure()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(const NetworkFailure().message),
      findsOneWidget,
    );
  });
}
