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

  /// Loads services for the given type ('clinic' or 'online').
  /// Skipped when that type was already fetched this session; pass
  /// [forceRefresh] to refetch and replace the cached entry.
  Future<void> load(String type, {bool forceRefresh = false}) async {
    final cached = _cache[type];
    if (!forceRefresh && cached != null) {
      emit(ServicesLoaded(cached));
      return;
    }
    emit(const ServicesLoading());
    final result = await _getServicesUseCase.call(type);
    result.fold(
      onFailure: (failure) => emit(ServicesError(failure)),
      onSuccess: (services) {
        _cache[type] = services;
        emit(ServicesLoaded(services));
      },
    );
  }
}
