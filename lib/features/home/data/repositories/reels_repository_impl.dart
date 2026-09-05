import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/reel.dart';
import '../../domain/repositories/reels_repository.dart';
import '../sources/reels_remote_data_source.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  const ReelsRepositoryImpl({
    required ReelsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ReelsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Reel>>> getReels() async {
    try {
      final dto = await _remoteDataSource.getReels();
      return Success(
        dto.reels.map((item) => item.toEntity()).toList(growable: false),
      );
    } on AppException catch (exception) {
      return FailureResult(FailureMapper.map(exception));
    }
  }
}