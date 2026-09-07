import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/service.dart';
import '../../domain/use_cases/get_services_use_case.dart';

sealed class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object?> get props => [];
}

final class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

final class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

final class ServicesLoaded extends ServicesState {
  const ServicesLoaded(this.services);

  final List<Service> services;

  @override
  List<Object?> get props => [services];
}

final class ServicesError extends ServicesState {
  const ServicesError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit({required GetServicesUseCase getServicesUseCase})
      : _getServicesUseCase = getServicesUseCase,
        super(const ServicesInitial());

  final GetServicesUseCase _getServicesUseCase;
  final Map<String, List<Service>> _cache = {};

  /// Types with a request currently in flight. Used to dedupe rapid
  /// taps (e.g. hero "Book" tapped twice) so the second call is a
  /// no-op instead of re-emitting Loading + firing a second request.
  final Set<String> _loadingTypes = {};

  /// Last type the UI asked to *display*. Guards against stale
  /// responses: a slow `clinic` fetch must not overwrite the list
  /// when the user already switched to `online`.
  String? _currentType;

  /// Cached services for [type], or null if never fetched.
  List<Service>? cachedFor(String type) => _cache[type];

  /// Loads services for the given type ('clinic' or 'online').
  /// Returns instantly when that type is cached or already loading;
  /// pass [forceRefresh] to refetch in the background (keeps showing
  /// the cached list instead of flashing a skeleton).
  Future<void> load(String type, {bool forceRefresh = false}) async {
    _currentType = type;
    final cached = _cache[type];
    if (!forceRefresh && cached != null) {
      final current = state;
      if (current is! ServicesLoaded || current.services != cached) {
        emit(ServicesLoaded(cached));
      }
      return;
    }
    if (_loadingTypes.contains(type)) return;
    // Keep the cached list visible during pull-to-refresh / retry
    // instead of flashing the skeleton.
    if (cached == null) {
      emit(const ServicesLoading());
    }
    _loadingTypes.add(type);
    try {
      final result = await _getServicesUseCase.call(type);
      if (isClosed) return;
      result.fold(
        onFailure: (failure) {
          // Show the error screen only when there is nothing cached
          // to keep; otherwise stay on the cached list.
          if (_currentType == type && _cache[type] == null) {
            emit(ServicesError(failure));
          }
        },
        onSuccess: (services) {
          _cache[type] = services;
          if (_currentType == type) {
            emit(ServicesLoaded(services));
          }
        },
      );
    } finally {
      _loadingTypes.remove(type);
    }
  }

  /// Fetches [type] in the background and caches it without touching
  /// [_currentType] or emitting state, so a foreground list is never
  /// clobbered. Used to warm the `online` tab while `clinic` is shown.
  Future<void> preload(String type, {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        (_cache.containsKey(type) || _loadingTypes.contains(type))) {
      return;
    }
    _loadingTypes.add(type);
    try {
      final result = await _getServicesUseCase.call(type);
      if (isClosed) return;
      result.fold(
        onFailure: (_) {},
        onSuccess: (services) => _cache[type] = services,
      );
    } finally {
      _loadingTypes.remove(type);
    }
  }
}
