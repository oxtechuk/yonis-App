import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/use_cases/get_doctors_use_case.dart';

sealed class DoctorsState extends Equatable {
  const DoctorsState();

  @override
  List<Object?> get props => [];
}

final class DoctorsInitial extends DoctorsState {
  const DoctorsInitial();
}

final class DoctorsLoading extends DoctorsState {
  const DoctorsLoading();
}

final class DoctorsLoaded extends DoctorsState {
  const DoctorsLoaded({
    required this.result,
    this.selectedDoctor,
  });

  final DoctorsResult result;
  final Doctor? selectedDoctor;

  /// True when the user does not need to manually pick a doctor (either
  /// already selected, auto-selected by the backend, or only 1 doctor exists).
  bool get hasResolvedDoctor =>
      selectedDoctor != null || result.shouldSkipSelection;

  Doctor? get activeDoctor =>
      selectedDoctor ?? result.effectiveAutoSelectedDoctor;

  @override
  List<Object?> get props => [result, selectedDoctor];
}

final class DoctorsError extends DoctorsState {
  const DoctorsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class DoctorsCubit extends Cubit<DoctorsState> {
  DoctorsCubit({required GetDoctorsUseCase getDoctorsUseCase})
      : _getDoctorsUseCase = getDoctorsUseCase,
        super(const DoctorsInitial());

  final GetDoctorsUseCase _getDoctorsUseCase;
  DoctorsResult? _cachedResult;
  Doctor? _selectedDoctor;
  bool _isLoading = false;

  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedResult != null) {
      final cached = _cachedResult!;
      final resolved = _selectedDoctor ??
          (cached.shouldSkipSelection
              ? cached.effectiveAutoSelectedDoctor
              : null);
      emit(DoctorsLoaded(result: cached, selectedDoctor: resolved));
      return;
    }
    if (_isLoading) return;
    if (_cachedResult == null) {
      emit(const DoctorsLoading());
    }
    _isLoading = true;
    try {
      final response = await _getDoctorsUseCase.call();
      if (isClosed) return;
      response.fold(
        onFailure: (failure) {
          if (_cachedResult == null) {
            emit(DoctorsError(failure));
          }
        },
        onSuccess: (result) {
          _cachedResult = result;
          if (result.shouldSkipSelection) {
            _selectedDoctor = result.effectiveAutoSelectedDoctor;
          } else if (_selectedDoctor != null &&
              !result.doctors.any((d) => d.id == _selectedDoctor!.id)) {
            _selectedDoctor = null;
          }
          emit(
            DoctorsLoaded(
              result: result,
              selectedDoctor: _selectedDoctor,
            ),
          );
        },
      );
    } finally {
      _isLoading = false;
    }
  }

  void selectDoctor(Doctor doctor) {
    _selectedDoctor = doctor;
    final current = _cachedResult;
    if (current != null) {
      emit(DoctorsLoaded(result: current, selectedDoctor: doctor));
    }
  }

  void clearSelectedDoctor() {
    _selectedDoctor = null;
    final current = _cachedResult;
    if (current != null) {
      emit(DoctorsLoaded(result: current, selectedDoctor: null));
    }
  }
}
