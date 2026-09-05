import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/core/error/failure.dart';
import 'package:younis_app/core/result/result.dart';
import 'package:younis_app/features/booking/domain/entities/check_user_result.dart';
import 'package:younis_app/features/booking/domain/entities/checkout_result.dart';
import 'package:younis_app/features/booking/domain/repositories/checkout_repository.dart';
import 'package:younis_app/features/booking/domain/use_cases/initialize_checkout_use_case.dart';
import 'package:younis_app/features/booking/presentation/cubit/checkout_cubit.dart';

class _FakeCheckoutRepository implements CheckoutRepository {
  _FakeCheckoutRepository(this._result);

  final Result<CheckoutResult> _result;
  Map<String, dynamic>? lastArgs;

  @override
  Future<Result<CheckUserResult>> checkUser({required String phone}) {
    throw UnimplementedError('not exercised by these tests');
  }

  @override
  Future<Result<CheckoutResult>> initializeCheckout({
    required int serviceId,
    required String bookingType,
    required String consultationType,
    required String paymentMethod,
    required String date,
    required String startTime,
    required String title,
    String? notes,
    String? name,
    String? phone,
    String? email,
    String? password,
  }) async {
    lastArgs = {
      'serviceId': serviceId,
      'bookingType': bookingType,
      'consultationType': consultationType,
      'paymentMethod': paymentMethod,
      'date': date,
      'startTime': startTime,
      'title': title,
      'notes': notes,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
    };
    return _result;
  }
}

void main() {
  test('submit emits loaded with a successful booking payload', () async {
    final repo = _FakeCheckoutRepository(
      const Success(
        CheckoutResult(
          success: true,
          bookingReference: 'BK-71MPYUAQ',
          amount: 50,
          currency: 'IQD',
          currencySymbol: 'د.ع',
          paymentMethod: 'zaincash',
          qrCode: 'https://example.com/qr.jpg',
        ),
      ),
    );
    final cubit = CheckoutCubit(initializeCheckoutUseCase: InitializeCheckoutUseCase(repo));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const CheckoutSubmitting(),
        isA<CheckoutLoaded>()
            .having((s) => s.result.success, 'success', true)
            .having((s) => s.result.bookingReference, 'bookingReference', 'BK-71MPYUAQ'),
      ]),
    );

    await cubit.submit(
      serviceId: 1,
      bookingType: 'online',
      consultationType: 'video',
      paymentMethod: 'zaincash',
      date: '2026-10-15',
      startTime: '11:00 AM',
      title: 'استشارة نفسية أولى',
      notes: 'زائر جديد يقوم بالحجز لأول مرة',
      name: 'مصطفى كمال الدين',
      phone: '+9647755667788',
      email: 'mustafa@example.com',
      password: 'password123',
    );
    await expectation;

    expect(repo.lastArgs?['name'], 'مصطفى كمال الدين');
    expect(repo.lastArgs?['phone'], '+9647755667788');
    await cubit.close();
  });

  test('submit emits loaded with success:false when the slot was just '
      'taken (a business rejection, not a transport error)', () async {
    final repo = _FakeCheckoutRepository(
      const Success(
        CheckoutResult(
          success: false,
          message: 'عذراً، هذا الموعد تم حجزه للتو. يرجى اختيار موعد آخر.',
        ),
      ),
    );
    final cubit = CheckoutCubit(initializeCheckoutUseCase: InitializeCheckoutUseCase(repo));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const CheckoutSubmitting(),
        isA<CheckoutLoaded>()
            .having((s) => s.result.success, 'success', false)
            .having((s) => s.result.message, 'message', isNotNull),
      ]),
    );

    // A registered user: name/phone/email/password are all null.
    await cubit.submit(
      serviceId: 1,
      bookingType: 'online',
      consultationType: 'video',
      paymentMethod: 'zaincash',
      date: '2026-10-15',
      startTime: '10:00 AM',
      title: 'استشارة نفسية متخصصة',
    );
    await expectation;

    expect(repo.lastArgs?['name'], isNull);
    expect(repo.lastArgs?['phone'], isNull);
    await cubit.close();
  });

  test('submit emits an error state on a transport failure', () async {
    final repo = _FakeCheckoutRepository(const FailureResult(NetworkFailure()));
    final cubit = CheckoutCubit(initializeCheckoutUseCase: InitializeCheckoutUseCase(repo));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([const CheckoutSubmitting(), isA<CheckoutError>()]),
    );

    await cubit.submit(
      serviceId: 1,
      bookingType: 'online',
      consultationType: 'video',
      paymentMethod: 'zaincash',
      date: '2026-10-15',
      startTime: '10:00 AM',
      title: 'استشارة نفسية متخصصة',
    );
    await expectation;
    await cubit.close();
  });
}
