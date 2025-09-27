import '../../../../core/domain/data_sources/cache_local_data_source.dart';
import '../../../../core/domain/entities/cache_key.dart';
import '../../../../core/domain/failures/storage_failure.dart';
import '../../../../core/domain/utils/either.dart';
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
  }) => forwardedGet<String>(
    path: path,
    key: const UrlCacheKey(),
    invalidateCacheBefore: invalidateCacheBefore,
    invalidateCacheDuration: invalidateCacheDuration,
    getFromRemote: remoteDataSource.getDownloadUrl,
    getFromLocal: localDataSource.getDownloadUrl,
    setLocal: localDataSource.setDownloadUrl,
    setSavedAtLocal: localDataSource.setSavedAt,
  );

  Future<Either<StorageFailure, dynamic>> getJson({
    required String path,
    required DateTime? invalidateCacheBefore,
    required Duration? invalidateCacheDuration,
  }) => forwardedGet<dynamic>(
    path: path,
    key: const JsonCacheKey(),
    invalidateCacheBefore: invalidateCacheBefore,
    invalidateCacheDuration: invalidateCacheDuration,
    getFromRemote: remoteDataSource.getJson,
    getFromLocal: localDataSource.getJson,
    setLocal: localDataSource.setJson,
    setSavedAtLocal: localDataSource.setSavedAt,
  );

  Future<Either<StorageFailure, T>> forwardedGet<T>({
    required String path,
    required CacheKey key,
    required DateTime? invalidateCacheBefore,
    required Duration? invalidateCacheDuration,
    required Future<Either<StorageFailure, T>> Function({required String path})
    getFromRemote,
    required Future<T?> Function({required String path}) getFromLocal,
    required Future<bool> setLocal({required String path, required T? value}),
    required Future<bool> setSavedAtLocal({
      required CacheKey key,
      required String path,
    }),
  }) async {
    try {
      final invalidateCache = await localDataSource.invalidateCacheRule(
        key: key,
        path: path,
        invalidateCacheBefore: invalidateCacheBefore,
        invalidateCacheDuration: invalidateCacheDuration,
      );
      if (invalidateCache) {
        final failureOrSuccess = await getFromRemote(path: path);
        return failureOrSuccess.fold(
          (failure) async {
            final value = await getFromLocal(path: path);
            if (value != null) {
              return Right(value);
            }
            return const Left(EmptyCacheStorageFailure());
          },
          (value) async {
            await Future.wait([
              setLocal(path: path, value: value),
              setSavedAtLocal(key: key, path: path),
            ]);
            return Right(value);
          },
        );
      }
      final value = await getFromLocal(path: path);
      if (value != null) {
        return Right(value);
      }
      return const Left(EmptyCacheStorageFailure());
    } catch (err) {
      return const Left(UnidentifiedStorageFailure());
    }
  }
}
