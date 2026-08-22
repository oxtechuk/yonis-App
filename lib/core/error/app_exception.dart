/// Infrastructure-level exception hierarchy.
///
/// Exceptions are allowed in data/infrastructure layers only. They are
/// translated to [Failure] values at repository boundaries via
/// [FailureMapper], so domain and presentation never see raw
/// DioException / SocketException / FormatException types.
///
/// [cause] carries the original lower-level error for debug logging only —
/// it must never be rendered to users.
sealed class AppException implements Exception {
  const AppException({
    this.message = 'An application error occurred.',
    this.code,
    this.cause,
  });

  final String message;
  final String? code;

  /// Original low-level error (DioException, SocketException, ...), for
  /// logging/diagnostics. Never exposed to the UI.
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType(code: $code, message: $message, cause: $cause)';
}

/// Connection could not be established or dropped mid-request.
///
/// Note: this covers transport problems while a request was already
/// attempted; it does not by itself prove the device is offline. Offline
/// state comes from NetworkInfo (hasNetworkInterface / hasInternetAccess).
final class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network connection failed.',
    super.code,
    super.cause,
  });
}

/// A request exceeded its configured timeout.
final class RequestTimeoutException extends AppException {
  const RequestTimeoutException({
    super.message = 'The request timed out.',
    super.code,
    super.cause,
  });
}

/// Base type for exceptions derived from an HTTP response with a non-2xx
/// status code. Carries the status code, the raw payload (for diagnostics
/// and future contract-driven refinement) and structured field errors when
/// the backend provides them.
sealed class ApiException extends AppException {
  const ApiException({
    required this.statusCode,
    this.data,
    this.fieldErrors,
    super.message = 'The request failed.',
    super.code,
    super.cause,
  });

  final int? statusCode;

  /// Raw response payload of the failed request. Feature-level parsers may
  /// refine interpretation once the real backend error contract is known.
  final Object? data;

  /// Per-field validation errors when the payload contains a recognizable
  /// structured errors map; otherwise null.
  final Map<String, List<String>>? fieldErrors;

  @override
  String toString() =>
      '$runtimeType(statusCode: $statusCode, code: $code, '
      'message: $message, fieldErrors: $fieldErrors)';
}

/// Session missing, expired or invalid (HTTP 401).
final class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    required super.statusCode,
    super.data,
    super.fieldErrors,
    super.message = 'Authentication is required.',
    super.code,
    super.cause,
  });
}

/// Authenticated but not allowed (HTTP 403).
final class ForbiddenException extends ApiException {
  const ForbiddenException({
    required super.statusCode,
    super.data,
    super.fieldErrors,
    super.message = 'You do not have permission to perform this action.',
    super.code,
    super.cause,
  });
}

/// Resource does not exist (HTTP 404).
final class NotFoundException extends ApiException {
  const NotFoundException({
    required super.statusCode,
    super.data,
    super.fieldErrors,
    super.message = 'The requested content could not be found.',
    super.code,
    super.cause,
  });
}

/// Input rejected with STRUCTURED per-field errors recognized in the
/// payload (typically HTTP 400/422). A bare 400 without recognizable field
/// structure is intentionally NOT a validation problem — see ApiErrorParser.
///
/// [fieldErrors] is guaranteed non-empty for this subtype.
final class ValidationException extends ApiException {
  const ValidationException({
    required Map<String, List<String>> fieldErrors,
    required super.statusCode,
    super.data,
    super.message = 'Please review the highlighted fields.',
    super.code,
    super.cause,
  }) : super(fieldErrors: fieldErrors);
}

/// Backend rejected the request or failed (unclassified client errors such
/// as 409/400-without-field-structure, and HTTP 5xx).
final class ServerException extends ApiException {
  const ServerException({
    required super.statusCode,
    super.data,
    super.fieldErrors,
    super.message = 'The request failed.',
    super.code,
    super.cause,
  });
}

/// A response payload could not be decoded into the expected shape
/// (including a legitimately empty body where JSON was expected).
final class SerializationException extends AppException {
  const SerializationException({
    super.message = 'Malformed response data.',
    super.code,
    super.cause,
  });
}

/// Local secure storage or preferences operation failed.
final class CacheStorageException extends AppException {
  const CacheStorageException({
    super.message = 'Local storage failed.',
    super.code,
    super.cause,
  });
}

/// Catch-all for errors that do not fit any known category.
final class UnexpectedAppException extends AppException {
  const UnexpectedAppException({
    super.message = 'An unexpected error occurred.',
    super.code,
    super.cause,
  });
}
