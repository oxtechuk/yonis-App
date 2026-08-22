import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../network/api_error_parser.dart';
import 'app_exception.dart';
import 'failure.dart';

/// Single translation point from exceptions to [Failure].
///
/// The repository boundary contract for every future repository:
///
///   ```
///   Future<Result<Entity>> operation() async {
///     try {
///       final dto = await _remoteDataSource.operation();
///       return Success(dto.toEntity());
///     } on AppException catch (exception) {
///       return FailureResult(FailureMapper.map(exception));
///     }
///   }
///   ```
///
/// (Repeated per repository on purpose — no BaseRepository abstraction.)
///
/// Raw DioException/SocketException/FormatException are also handled
/// defensively here (delegating to the same central ApiErrorParser), so a
/// repository that forgets an edge case still cannot leak transport types
/// into domain/presentation.
class FailureMapper {
  const FailureMapper._();

  static Failure map(Object error) => switch (error) {
    final ApiException api => _fromApiException(api),
    final NetworkException e => NetworkFailure(
      message: e.message,
      code: e.code,
    ),
    final RequestTimeoutException e => TimeoutFailure(
      message: e.message,
      code: e.code,
    ),
    final SerializationException e => ParsingFailure(
      message: e.message,
      code: e.code,
    ),
    final CacheStorageException e => CacheFailure(
      message: e.message,
      code: e.code,
    ),
    final UnexpectedAppException e => UnexpectedFailure(
      message: e.message,
      code: e.code,
    ),
    final DioException dioError => map(ApiErrorParser.parse(dioError)),
    final SocketException _ => const NetworkFailure(),
    final TimeoutException _ => const TimeoutFailure(),
    final FormatException _ => const ParsingFailure(),
    _ => UnexpectedFailure(message: error.toString()),
  };

  static Failure _fromApiException(ApiException exception) {
    final message = exception.message;
    return switch (exception) {
      UnauthorizedException() => UnauthorizedFailure(
        message: message,
        code: exception.code,
      ),
      ForbiddenException() => ForbiddenFailure(
        message: message,
        code: exception.code,
      ),
      NotFoundException() => NotFoundFailure(
        message: message,
        code: exception.code,
      ),
      ValidationException() => ValidationFailure(
        message: message,
        code: exception.code,
        fieldErrors: exception.fieldErrors ?? const {},
      ),
      _ => ServerFailure(
        statusCode: exception.statusCode,
        code: exception.code,
        message: message,
      ),
    };
  }
}
