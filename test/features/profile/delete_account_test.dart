import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/core/error/failure.dart';
import 'package:younis_app/core/result/result.dart';
import 'package:younis_app/features/auth/domain/entities/user.dart';
import 'package:younis_app/features/profile/domain/entities/app_config_links.dart';
import 'package:younis_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:younis_app/features/profile/domain/use_cases/delete_account_use_case.dart';
import 'package:younis_app/features/profile/domain/use_cases/get_app_config_links_use_case.dart';
import 'package:younis_app/features/profile/domain/use_cases/get_profile_user_use_case.dart';
import 'package:younis_app/features/profile/presentation/cubit/profile_cubit.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.shouldFail = false});

  final bool shouldFail;
  bool deleteCalled = false;

  @override
  Future<Result<User>> getUser() async {
    return const Success(
      User(id: 1, name: 'Test', email: 'test@example.com', phone: '123', role: 'patient'),
    );
  }

  @override
  Future<Result<AppConfigLinks>> getConfigLinks() async {
    return const Success(AppConfigLinks());
  }

  @override
  Future<Result<void>> deleteAccount() async {
    deleteCalled = true;
    if (shouldFail) {
      return const FailureResult(ServerFailure(message: 'Deletion failed'));
    }
    return const Success(null);
  }
}

void main() {
  group('DeleteAccountUseCase & ProfileCubit', () {
    test('DeleteAccountUseCase executes repository deleteAccount', () async {
      final repo = _FakeProfileRepository();
      final useCase = DeleteAccountUseCase(repo);

      final result = await useCase.call();

      expect(repo.deleteCalled, isTrue);
      expect(result.isSuccess, isTrue);
    });

    test('ProfileCubit.deleteAccount delegates to DeleteAccountUseCase', () async {
      final repo = _FakeProfileRepository();
      final deleteUseCase = DeleteAccountUseCase(repo);
      final cubit = ProfileCubit(
        getProfileUserUseCase: GetProfileUserUseCase(repo),
        getAppConfigLinksUseCase: GetAppConfigLinksUseCase(repo),
        deleteAccountUseCase: deleteUseCase,
      );

      final result = await cubit.deleteAccount();

      expect(repo.deleteCalled, isTrue);
      expect(result.isSuccess, isTrue);
      await cubit.close();
    });

    test('ProfileCubit.deleteAccount handles failure gracefully', () async {
      final repo = _FakeProfileRepository(shouldFail: true);
      final deleteUseCase = DeleteAccountUseCase(repo);
      final cubit = ProfileCubit(
        getProfileUserUseCase: GetProfileUserUseCase(repo),
        getAppConfigLinksUseCase: GetAppConfigLinksUseCase(repo),
        deleteAccountUseCase: deleteUseCase,
      );

      final result = await cubit.deleteAccount();

      expect(repo.deleteCalled, isTrue);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.message, 'Deletion failed');
      await cubit.close();
    });
  });
}
