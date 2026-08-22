import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../error/app_exception.dart';

/// THE one place that interprets backend/transport errors.
///
/// Responsibilities:
/// - translate Dio transport failures into typed [AppException]s
/// - inspect HTTP status + response payload to classify HTTP errors
/// - extract structured field validation errors when the payload contains
///   a recognizable errors map (never flattening them into strings)
///
/// Feature repositories must NOT re-parse error payloads themselves; they
/// catch AppException and delegate the translation to FailureMapper.
///
/// CONTRACT ASSUMPTIONS (no backend API contract was available — see
/// Phase 2 report). The payload recognition below accepts common
/// conventions and degrades safely; it MUST be revisited once the real
/// backend contract exists:
/// - structured field errors are recognized under keys: errors / fieldErrors
///   / field_errors / validation_errors, shaped as `Map<String, dynamic>`
///   where each value is a String or a List of Strings;
/// - 400/422 become ValidationException ONLY when such structure is found;
///   otherwise they fall back to ServerException (400 is not blindly
///   treated as validation);
/// - human-readable messages are recognized under keys: message / detail /
///   error / errorMessage.
class ApiErrorParser {
  const ApiErrorParser._();

  static const List<String> _messageKeys = <String>[
    'message',
    'detail',
    'error',
    'errorMessage',
  ];

  static const List<String> _fieldErrorsKeys = <String>[
    'errors',
    'fieldErrors',
    'field_errors',
    'validation_errors',
  ];

  static AppException parse(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => RequestTimeoutException(
        cause: error,
      ),
      DioExceptionType.badResponse => _fromResponse(error),
      DioExceptionType.cancel => const NetworkException(
        message: 'Request was cancelled.',
        cause: 'DioExceptionType.cancel',
      ),
      DioExceptionType.badCertificate => const NetworkException(
        message: 'Insecure connection rejected.',
      ),
      DioExceptionType.connectionError => NetworkException(
        message: error.message ?? 'Network connection failed.',
        cause: error.error ?? error,
      ),
      DioExceptionType.unknown => _fromUnknown(error),
    };
  }

  static AppException _fromResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final fallbackMessage =
        error.response?.statusMessage ?? 'The request failed.';

    return switch (statusCode) {
      401 => UnauthorizedException(
        statusCode: statusCode,
        data: data,
        message: _extractMessage(data) ?? fallbackMessage,
        cause: error,
      ),
      403 => ForbiddenException(
        statusCode: statusCode,
        data: data,
        message: _extractMessage(data) ?? fallbackMessage,
        cause: error,
      ),
      404 => NotFoundException(
        statusCode: statusCode,
        data: data,
        message: _extractMessage(data) ?? fallbackMessage,
        cause: error,
      ),
      400 || 422 => _clientError(statusCode, data, fallbackMessage, error),
      _ => ServerException(
        statusCode: statusCode,
        data: data,
        message: _extractMessage(data) ?? fallbackMessage,
        cause: error,
      ),
    };
  }

  /// Client-error statuses (400/422): ValidationException only when the
  /// payload carries recognizable per-field structure, otherwise a plain
  /// [ServerException]. The status code alone does NOT decide this.
  static AppException _clientError(
    int? statusCode,
    Object? data,
    String fallbackMessage,
    DioException cause,
  ) {
    final fieldErrors = _extractFieldErrors(data);
    if (fieldErrors == null || fieldErrors.isEmpty) {
      return ServerException(
        statusCode: statusCode,
        data: data,
        message: _extractMessage(data) ?? fallbackMessage,
        cause: cause,
      );
    }
    return ValidationException(
      statusCode: statusCode,
      data: data,
      fieldErrors: fieldErrors,
      message: _extractMessage(data) ?? fallbackMessage,
      cause: cause,
    );
  }

  static AppException _fromUnknown(DioException error) {
    final cause = error.error;

    // Dio performs its own internal `data as T` cast, so a 2xx payload
    // whose decoded shape does not match the requested type surfaces here
    // as a wrapped TypeError. The same applies to undecodable JSON bodies
    // (FormatException thrown by the response transformer). Both are
    // parsing problems at the data boundary, NOT transport/server errors.
    if (cause is TypeError || cause is FormatException) {
      return SerializationException(
        message:
            'Unexpected or malformed response shape '
            '(HTTP ${error.response?.statusCode}).',
        cause: cause,
      );
    }

    if (cause is SocketException || cause is TimeoutException) {
      return NetworkException(
        message: error.message ?? 'Network connection failed.',
        cause: cause,
      );
    }
    return UnexpectedAppException(
      message: error.message ?? 'An unexpected error occurred.',
      cause: cause ?? error,
    );
  }

  /// Returns the first string found under any known message key.
  static String? _extractMessage(Object? data) {
    if (data is! Map) return null;
    for (final key in _messageKeys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  /// Extracts a `Map<String, List<String>>` from any known errors key.
  /// Entries whose values cannot be interpreted as strings are skipped
  /// rather than guessed at.
  static Map<String, List<String>>? _extractFieldErrors(Object? data) {
    if (data is! Map) return null;
    for (final key in _fieldErrorsKeys) {
      final value = data[key];
      if (value is! Map) continue;

      final result = <String, List<String>>{};
      for (final entry in value.entries) {
        final field = entry.key.toString();
        final messages = entry.value;
        if (messages is String) {
          if (messages.trim().isNotEmpty) result[field] = [messages];
        } else if (messages is List) {
          final list = [
            for (final item in messages)
              if (item is String && item.trim().isNotEmpty) item,
          ];
          if (list.isNotEmpty) result[field] = list;
        }
      }
      if (result.isNotEmpty) return result;
    }
    return null;
  }
}
