import '../../../../core/result/result.dart';
import '../entities/home_slider.dart';
import '../repositories/sliders_repository.dart';

class GetSlidersUseCase {
  const GetSlidersUseCase(this._repository);

  final SlidersRepository _repository;

  Future<Result<List<HomeSlider>>> call() => _repository.getSliders();
}
