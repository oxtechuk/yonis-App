import 'package:equatable/equatable.dart';

/// Application-level, machine-readable error description.
///
/// This is the ONLY error channel allowed to cross into domain and
/// presentation layers. Never throw strings; never collapse failures to
/// plain strings at repository boundaries — presentation needs to
/// distinguish offline, unauthorized, timeout, validation, server problems,
/// and read validation field errors.
sealed class Failure extends Equatable {
  const Failure({this.message = 'An error occurred.', this.code});

  /// Human-presentable default description. Presentation may replace it
  /// with localized copy based on the concrete failure type.
  final String message;

  /// Optional machine-readable code (e.g. a backend error code).
  final String? code;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';

  @override
  List<Object?> get props => [message, code];
}

/// A request failed over the network while the device considered itself
/// connected (connection reset, DNS failure, TLS problem, ...).
final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message =
        'A network error occurred. Please check your connection and try again.',
    super.code,
  });
}

/// The device has no usable internet connection.
final class OfflineFailure extends Failure {
  const OfflineFailure({
    super.message = 'You appear to be offline. Please reconnect and try again.',
    super.code,
  });
}

/// The request took too long and was aborted.
final class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'The request timed out. Please try again.',
    super.code,
  });
}

/// The current session is missing, expired or invalid (HTTP 401).
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'You need to sign in to continue.',
    super.code,
  });
}

/// The session is valid but lacks permission for the action (HTTP 403).
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'You do not have permission to perform this action.',
    super.code,
  });
}

/// The requested resource does not exist (HTTP 404).
final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested content could not be found.',
    super.code,
  });
}

/// Input rejected by the server (e.g. HTTP 400/422 WITH structured
/// field errors in the payload — see ApiErrorParser).
///
/// [fieldErrors] preserves per-field validation problems so forms can show
/// errors next to the offending inputs. Errors are never flattened into a
/// single string.
final class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Please review the highlighted fields.',
    super.code,
    this.fieldErrors = const {},
  });

  final Map<String, List<String>> fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// The backend failed unexpectedly (HTTP 5xx or unclassified client error).
final class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Something went wrong on our side. Please try again later.',
    super.code,
    this.statusCode,
  });

  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Local persisted data could not be read or written.
final class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Local data is unavailable.',
    super.code,
  });
}

/// A response payload could not be decoded/mapped.
final class ParsingFailure extends Failure {
  const ParsingFailure({
    super.message = 'Received malformed data.',
    super.code,
  });
}

/// Nothing else matched. Should be rare — investigate the cause when seen.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
  });
}
