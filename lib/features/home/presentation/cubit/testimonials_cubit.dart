import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/testimonial.dart';
import '../../domain/use_cases/get_testimonials_use_case.dart';

sealed class TestimonialsState extends Equatable {
  const TestimonialsState();

  @override
  List<Object?> get props => [];
}

final class TestimonialsInitial extends TestimonialsState {
  const TestimonialsInitial();
}

final class TestimonialsLoading extends TestimonialsState {
  const TestimonialsLoading();
}

final class TestimonialsLoaded extends TestimonialsState {
  const TestimonialsLoaded(this.testimonials);

  final List<Testimonial> testimonials;

  @override
  List<Object?> get props => [testimonials];
}

final class TestimonialsError extends TestimonialsState {
  const TestimonialsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class TestimonialsCubit extends Cubit<TestimonialsState> {
  TestimonialsCubit({required GetTestimonialsUseCase getTestimonialsUseCase})
      : _getTestimonialsUseCase = getTestimonialsUseCase,
        super(const TestimonialsInitial());

  final GetTestimonialsUseCase _getTestimonialsUseCase;

  Future<void> load() async {
    emit(const TestimonialsLoading());
    final result = await _getTestimonialsUseCase.call();
    result.fold(
      onFailure: (failure) => emit(TestimonialsError(failure)),
      onSuccess: (testimonials) => emit(TestimonialsLoaded(testimonials)),
    );
  }
}
