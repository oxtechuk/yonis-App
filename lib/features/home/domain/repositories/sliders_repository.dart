import '../../../../core/result/result.dart';
import '../entities/home_slider.dart';

abstract interface class SlidersRepository {
  Future<Result<List<HomeSlider>>> getSliders();
}
