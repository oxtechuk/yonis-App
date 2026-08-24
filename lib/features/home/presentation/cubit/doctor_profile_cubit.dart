import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/use_cases/get_doctor_profile_use_case.dart';

sealed class DoctorProfileState extends Equatable {
  const DoctorProfileState();

  @override
  List<Object?> get props => [];
}

final class DoctorProfileInitial extends DoctorProfileState {
  const DoctorProfileInitial();
}

final class DoctorProfileLoading extends DoctorProfileState {
  const DoctorProfileLoading();
}

final class DoctorProfileLoaded extends DoctorProfileState {
  const DoctorProfileLoaded(this.profile);

  final DoctorProfile profile;

  @override
  List<Object?> get props => [profile];
}

final class DoctorProfileError extends DoctorProfileState {
  const DoctorProfileError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class DoctorProfileCubit extends Cubit<DoctorProfileState> {
  DoctorProfileCubit({required GetDoctorProfileUseCase getDoctorProfileUseCase})
      : _getDoctorProfileUseCase = getDoctorProfileUseCase,
        super(const DoctorProfileInitial());

  final GetDoctorProfileUseCase _getDoctorProfileUseCase;

  Future<void> load() async {
    emit(const DoctorProfileLoading());
    final result = await _getDoctorProfileUseCase.call();
    result.fold(
      onFailure: (failure) => emit(DoctorProfileError(failure)),
      onSuccess: (profile) => emit(DoctorProfileLoaded(profile)),
    );
  }
}
