import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/core/error/failure.dart';
import 'package:younis_app/core/result/result.dart';
import 'package:younis_app/features/booking/domain/entities/check_user_result.dart';
import 'package:younis_app/features/booking/domain/entities/checkout_result.dart';
import 'package:younis_app/features/booking/domain/entities/checkout_user.dart';
import 'package:younis_app/features/booking/domain/repositories/checkout_repository.dart';
import 'package:younis_app/features/booking/domain/use_cases/check_user_use_case.dart';
import 'package:younis_app/features/booking/presentation/cubit/check_user_cubit.dart';

class _FakeCheckoutRepository implements CheckoutRepository {
  _FakeCheckoutRepository(this._result);

  final Result<CheckUserResult> _result;
  String? lastPhone;

  @override
  Future<Result<CheckUserResult>> checkUser({required String phone}) async {
    lastPhone = phone;
    return _result;
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
  }) {
    throw UnimplementedError('not exercised by these tests');
  }
}

void main() {
  test('check emits loading then loaded for a registered user', () async {
    final repo = _FakeCheckoutRepository(
      const Success(
        CheckUserResult(
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
        ),
      ),
    );
    final cubit = CheckUserCubit(checkUserUseCase: CheckUserUseCase(repo));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const CheckUserLoading(),
        isA<CheckUserLoaded>()
            .having((s) => s.result.isRegistered, 'isRegistered', true)
            .having((s) => s.result.user?.name, 'user.name', 'أحمد محمد عبد الله'),
      ]),
    );

    await cubit.check('+9647701234567');
    await expectation;

    expect(repo.lastPhone, '+9647701234567');
    await cubit.close();
  });

  test('check emits loaded with no user for an unregistered phone', () async {
    final repo = _FakeCheckoutRepository(
      const Success(
        CheckUserResult(
          isRegistered: false,
          requiresAccount: true,
          requiresPassword: true,
        ),
      ),
    );
    final cubit = CheckUserCubit(checkUserUseCase: CheckUserUseCase(repo));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const CheckUserLoading(),
        isA<CheckUserLoaded>()
            .having((s) => s.result.isRegistered, 'isRegistered', false)
            .having((s) => s.result.user, 'user', isNull),
      ]),
    );

    await cubit.check('+9647755667788');
    await expectation;
    await cubit.close();
  });

  test('check emits an error state on failure', () async {
    final repo = _FakeCheckoutRepository(const FailureResult(NetworkFailure()));
    final cubit = CheckUserCubit(checkUserUseCase: CheckUserUseCase(repo));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([const CheckUserLoading(), isA<CheckUserError>()]),
    );

    await cubit.check('+9647701234567');
    await expectation;
    await cubit.close();
  });

  test('reset returns to the initial (phone entry) state', () async {
    final repo = _FakeCheckoutRepository(
      const Success(
        CheckUserResult(
          isRegistered: true,
          requiresAccount: false,
          requiresPassword: false,
        ),
      ),
    );
    final cubit = CheckUserCubit(checkUserUseCase: CheckUserUseCase(repo));

    await cubit.check('+9647701234567');
    expect(cubit.state, isA<CheckUserLoaded>());

    cubit.reset();
    expect(cubit.state, const CheckUserInitial());

    await cubit.close();
  });
}
