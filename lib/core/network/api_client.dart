import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import 'api_error_parser.dart';

/// Thin transport abstraction over Dio.
///
/// Knows NOTHING about business models or JSON parsing — remote data sources
/// request a primitive shape (`Map<String, dynamic>`, `List<dynamic>`,
/// `void`, ...) and own DTO decoding themselves.
///
/// Error contract:
/// - every DioException is translated ONCE, centrally, by [ApiErrorParser];
/// - everything leaves this class as a typed [AppException] — raw
///   DioException/SocketException/FormatException never leak upward.
///
/// Success contract:
/// - any 2xx is success (Dio default validateStatus);
/// - empty bodies (e.g. HTTP 204) are valid: request `void`/`dynamic`/
///   nullable types. Asking for a non-nullable JSON shape on an empty body
///   raises SerializationException deliberately (contract mismatch at the
///   data boundary), not a transport error;
/// - a 2xx body whose decoded shape does not match the requested type also
///   raises SerializationException (HTTP 200 with wrong JSON shape is a
///   parsing failure, never a ServerFailure).
///
/// Request options supported per call: query parameters, custom headers,
/// body/data and cancellation. Authentication headers will be injected by
/// a future AuthInterceptor registered in DioFactory — no redesign needed.
abstract interface class ApiClient {
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });
}

class DioApiClient implements ApiClient {
  const DioApiClient(this._dio);

  final Dio _dio;

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => _dio.post<T>(
        path,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => _dio.put<T>(
        path,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => _dio.patch<T>(
        path,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _guard(
      () => _dio.delete<T>(
        path,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<T> _guard<T>(Future<Response<T>> Function() request) async {
    Response<T> response;
    try {
      response = await request();
    } on DioException catch (error) {
      throw ApiErrorParser.parse(error);
    }

    var data = response.data;

    // Normalize "no body" variants (e.g. HTTP 204 with or without a JSON
    // content-type header) to null, so a legitimate empty response can
    // never fail regardless of server header quirks.
    if (data is String && data.trim().isEmpty) {
      data = null;
    }

    if (data == null && null is! T) {
      throw SerializationException(
        message:
            'Expected a JSON body but the server returned none '
            '(HTTP ${response.statusCode}).',
      );
    }

    try {
      return data as T;
    } on TypeError catch (error) {
      // HTTP was successful but the payload shape does not match what the
      // caller declared — this is a parsing problem at the data boundary,
      // NOT a transport/server failure.
      throw SerializationException(
        message:
            'Unexpected response shape for $T '
            '(HTTP ${response.statusCode}).',
        cause: error,
      );
    }
  }
}
