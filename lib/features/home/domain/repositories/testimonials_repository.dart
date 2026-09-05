import '../../../../core/result/result.dart';
import '../entities/testimonial.dart';

abstract interface class TestimonialsRepository {
  Future<Result<List<Testimonial>>> getTestimonials();
}
