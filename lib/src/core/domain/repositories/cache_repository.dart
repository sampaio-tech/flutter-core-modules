abstract class CacheRepository {
  const CacheRepository();

  bool? getBool({
    required String key,
  });

  Future<bool> setBool({
    required String key,
    required bool value,
  });

  Future<bool> remove({
    required String key,
  });
}
