import '../error/failure.dart';

/// Typed result of an operation: exactly one of success data or [Failure].
///
/// Repositories and use cases return `Result<T>`; failures keep their full
/// machine-readable type all the way up to presentation.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is FailureResult<T>;

  /// Data when this is a success, otherwise `null`.
  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    FailureResult<T>() => null,
  };

  /// Failure when this is a failure, otherwise `null`.
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    FailureResult<T>(:final failure) => failure,
  };

  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T data) onSuccess,
  }) => switch (this) {
    Success<T>(:final data) => onSuccess(data),
    FailureResult<T>(:final failure) => onFailure(failure),
  };

  Result<R> map<R>(R Function(T data) mapper) => switch (this) {
    Success<T>(:final data) => Success(mapper(data)),
    FailureResult<T>(:final failure) => FailureResult(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  String toString() => 'Success<$T>($data)';
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  String toString() => 'FailureResult<$T>($failure)';
}
