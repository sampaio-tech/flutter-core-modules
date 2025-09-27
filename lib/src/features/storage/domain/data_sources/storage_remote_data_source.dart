import '../../../../core/domain/failures/storage_failure.dart';
import '../../../../core/domain/utils/either.dart';

abstract class StorageRemoteDataSource {
  const StorageRemoteDataSource();

  Future<Either<StorageFailure, String>> getDownloadUrl({required String path});

  Future<Either<StorageFailure, dynamic>> getJson({required String path});
}
