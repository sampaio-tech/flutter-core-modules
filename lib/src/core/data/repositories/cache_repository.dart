import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/cache_repository.dart';
import '../../presentation/setup/shared_preferences/provider.dart';

class CacheRepositoryImpl extends CacheRepository {
  final SharedPreferences _sharedPreferences;

  const CacheRepositoryImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  @override
  bool? getBool({
    required String key,
  }) =>
      _sharedPreferences.getBool(key);
  @override
  Future<bool> setBool({
    required String key,
    required bool value,
  }) =>
      _sharedPreferences.setBool(key, value);

  @override
  Future<bool> remove({
    required String key,
  }) =>
      _sharedPreferences.remove(key);
}

final cacheRepositoryProvider = Provider.autoDispose<CacheRepository>(
  (ref) => CacheRepositoryImpl(
    sharedPreferences: ref.read(sharedPreferencesProvider),
  ),
);
