import '../../../../core/result/result.dart';
import '../entities/testimonial.dart';
import '../repositories/testimonials_repository.dart';

class GetTestimonialsUseCase {
  const GetTestimonialsUseCase(this._repository);

  final TestimonialsRepository _repository;

  Future<Result<List<Testimonial>>> call() => _repository.getTestimonials();
}
