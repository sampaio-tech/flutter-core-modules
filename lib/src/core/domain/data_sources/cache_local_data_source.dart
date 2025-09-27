import '../entities/cache_key.dart';

abstract class CacheLocalDataSource {
  const CacheLocalDataSource();

  Future<String?> getDownloadUrl({required String path});

  Future<bool> setDownloadUrl({required String path, required String? value});

  Future<dynamic> getJson({required String path});

  Future<bool> setJson({required String path, required dynamic value});

  Future<DateTime?> getSavedAt({required CacheKey key, required String path});

  Future<bool> setSavedAt({required CacheKey key, required String path});

  Future<bool> invalidateCacheRule({
    required CacheKey key,
    required String path,
    required DateTime? invalidateCacheBefore,
    required Duration? invalidateCacheDuration,
  }) async {
    final cacheUpdatedAt = await getSavedAt(key: key, path: path);
    return (invalidateCacheBefore != null &&
            cacheUpdatedAt != null &&
            cacheUpdatedAt.isBefore(invalidateCacheBefore)) ||
        (invalidateCacheDuration != null &&
            cacheUpdatedAt != null &&
            cacheUpdatedAt
                .add(invalidateCacheDuration)
                .isBefore(DateTime.now())) ||
        cacheUpdatedAt == null;
  }
}
