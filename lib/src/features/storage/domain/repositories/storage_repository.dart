import '../../../../core/domain/data_sources/cache_local_data_source.dart';
import '../../../../core/domain/entities/cache_key.dart';
import '../../../../core/domain/failures/storage_failure.dart';
import '../../../../core/domain/utils/either.dart';
import '../../../../core/domain/utils/fowarded_cache_functions.dart';
import '../data_sources/storage_remote_data_source.dart';

abstract class StorageRepository {
  final CacheLocalDataSource localDataSource;
  final StorageRemoteDataSource remoteDataSource;

  const StorageRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  Future<Either<StorageFailure, String>> getDownloadUrl({
    required String path,
    required DateTime? invalidateCacheBefore,
    required Duration? invalidateCacheDuration,
  }) => forwardedCachedGet<StorageFailure, String>(
    path: path,
    key: const UrlCacheKey(),
    invalidateCacheBefore: invalidateCacheBefore,
    invalidateCacheDuration: invalidateCacheDuration,
    getFromRemote: remoteDataSource.getDownloadUrl,
    getFromLocal: localDataSource.getDownloadUrl,
    setLocal: localDataSource.setDownloadUrl,
    setSavedAtLocal: localDataSource.setSavedAt,
    emptyCacheFailure: const EmptyCacheStorageFailure(),
    unidentifiedFailure: const UnidentifiedStorageFailure(),
    localDataSource: localDataSource,
  );

  Future<Either<StorageFailure, dynamic>> getJson({
    required String path,
    required DateTime? invalidateCacheBefore,
    required Duration? invalidateCacheDuration,
  }) => forwardedCachedGet<StorageFailure, dynamic>(
    path: path,
    key: const JsonCacheKey(),
    invalidateCacheBefore: invalidateCacheBefore,
    invalidateCacheDuration: invalidateCacheDuration,
    getFromRemote: remoteDataSource.getJson,
    getFromLocal: localDataSource.getJson,
    setLocal: localDataSource.setJson,
    setSavedAtLocal: localDataSource.setSavedAt,
    emptyCacheFailure: const EmptyCacheStorageFailure(),
    unidentifiedFailure: const UnidentifiedStorageFailure(),
    localDataSource: localDataSource,
  );
}
