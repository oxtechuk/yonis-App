import '../../../../core/result/result.dart';
import '../entities/reel.dart';

abstract interface class ReelsRepository {
  Future<Result<List<Reel>>> getReels();
}