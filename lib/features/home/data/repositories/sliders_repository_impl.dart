import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/home_slider.dart';
import '../../domain/repositories/sliders_repository.dart';
import '../sources/sliders_remote_data_source.dart';

class SlidersRepositoryImpl implements SlidersRepository {
  const SlidersRepositoryImpl({
    required SlidersRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final SlidersRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<HomeSlider>>> getSliders() async {
    try {
      final response = await _remoteDataSource.getSliders();
      final entities = response.sliders
          .map((dto) => dto.toEntity())
          .toList(growable: false);
      return Success(entities);
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}
