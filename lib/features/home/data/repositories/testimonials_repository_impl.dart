import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/testimonial.dart';
import '../../domain/repositories/testimonials_repository.dart';
import '../sources/testimonials_remote_data_source.dart';

class TestimonialsRepositoryImpl implements TestimonialsRepository {
  const TestimonialsRepositoryImpl({
    required TestimonialsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final TestimonialsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Testimonial>>> getTestimonials() async {
    try {
      final dto = await _remoteDataSource.getTestimonials();
      return Success(
        dto.testimonials.map((item) => item.toEntity()).toList(growable: false),
      );
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}
