import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorage secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  @override
  Future<Result<AuthSession>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final session =
          (await _remoteDataSource.login(
        identifier: identifier,
        password: password,
      ))
              .toEntity();
      await _secureStorage.write(
        SecureStorageKeys.accessToken,
        session.token,
      );
      return Success(session);
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}
