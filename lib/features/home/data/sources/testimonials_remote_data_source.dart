import '../../../../core/network/api_client.dart';
import '../models/testimonials_dto.dart';

abstract interface class TestimonialsRemoteDataSource {
  Future<TestimonialsResponseDto> getTestimonials();
}

class ApiTestimonialsRemoteDataSource
    implements TestimonialsRemoteDataSource {
  const ApiTestimonialsRemoteDataSource(this._apiClient);

  static const String _reviewsPath = '/api/reviews';

  final ApiClient _apiClient;

  @override
  Future<TestimonialsResponseDto> getTestimonials() async {
    final json = await _apiClient.get<Map<String, dynamic>>(_reviewsPath);
    return TestimonialsResponseDto.fromJson(json);
  }
}
