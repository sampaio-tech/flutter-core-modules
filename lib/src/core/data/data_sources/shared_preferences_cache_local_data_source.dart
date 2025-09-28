import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../flutter_core_modules.dart';

class SharedPreferencesCacheLocalDataSource extends CacheLocalDataSource {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesCacheLocalDataSource({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  @override
  Future<String?> getDownloadUrl({required String path}) async =>
      _sharedPreferences.getString(const UrlCacheKey().keyByPath(path));

  @override
  Future<dynamic> getJson({required String path}) async =>
      switch (_sharedPreferences.getString(
        const JsonCacheKey().keyByPath(path),
      )) {
        null => null,
        final json => jsonDecode(json),
      };

  @override
  Future<DateTime?> getSavedAt({
    required CacheKey key,
    required String path,
  }) async => switch (_sharedPreferences.getString(
    const JsonCacheKey().savedAt(path),
  )) {
    null => null,
    final formattedString => DateTime.tryParse(formattedString),
  };

  @override
  Future<bool> setDownloadUrl({
    required String path,
    required String? value,
  }) async {
    final key = const UrlCacheKey().keyByPath(path);
    if (value == null) {
      return _sharedPreferences.remove(key);
    }
    return _sharedPreferences.setString(key, value);
  }

  @override
  Future<bool> setJson({required String path, required dynamic value}) async {
    final key = const JsonCacheKey().keyByPath(path);
    if (value == null) {
      return _sharedPreferences.remove(key);
    }
    return _sharedPreferences.setString(key, jsonEncode(value));
  }

  @override
  Future<bool> setSavedAt({required CacheKey key, required String path}) async {
    final key = const JsonCacheKey().savedAt(path);
    return _sharedPreferences.setString(key, DateTime.now().toIso8601String());
  }
}

final sharedPreferencesCacheLocalDataSourceProvider =
    Provider.autoDispose<SharedPreferencesCacheLocalDataSource>(
      (ref) => SharedPreferencesCacheLocalDataSource(
        sharedPreferences: ref.read(sharedPreferencesProvider),
      ),
    );
