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

  /// Loads the services list. Skipped when valid data is already cached
  /// (the sheet reuses this cubit, so repeated openings render instantly);
  /// pass [forceRefresh] to refetch.
  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh && state is ServicesLoaded) return;
    emit(const ServicesLoading());
    final result = await _getServicesUseCase.call();
    result.fold(
      onFailure: (failure) => emit(ServicesError(failure)),
      onSuccess: (services) => emit(ServicesLoaded(services)),
    );
  }
}
