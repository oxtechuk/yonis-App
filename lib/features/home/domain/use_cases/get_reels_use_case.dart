import '../../../../core/result/result.dart';
import '../entities/reel.dart';
import '../repositories/reels_repository.dart';

class GetReelsUseCase {
  const GetReelsUseCase(this._repository);

  final ReelsRepository _repository;

  Future<Result<List<Reel>>> call() => _repository.getReels();
}