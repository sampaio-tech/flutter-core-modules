import 'dart:convert';

import 'package:http/http.dart';

import '../data_sources/cache_local_data_source.dart';
import '../entities/cache_key.dart';
import 'either.dart';

Future<Either<F, T>> forwardedCachedGet<F, T>({
  required String path,
  required CacheKey key,
  required DateTime? invalidateCacheBefore,
  required Duration? invalidateCacheDuration,
  required Future<Either<F, T>> Function({required String path}) getFromRemote,
  required Future<T?> Function({required String path}) getFromLocal,
  required Future<bool> Function({required String path, required T? value})
  setLocal,
  required Future<bool> Function({required CacheKey key, required String path})
  setSavedAtLocal,
  required F emptyCacheFailure,
  required F unidentifiedFailure,
  required CacheLocalDataSource localDataSource,
}) async {
  try {
    Future<Either<F, T>> getFromCache() async {
      final value = await getFromLocal(path: path);
      if (value != null) {
        return Right(value);
      }
      return Left(emptyCacheFailure);
    }

    final invalidateCache = await localDataSource.invalidateCacheRule(
      key: key,
      path: path,
      invalidateCacheBefore: invalidateCacheBefore,
      invalidateCacheDuration: invalidateCacheDuration,
    );
    if (invalidateCache) {
      final failureOrSuccess = await getFromRemote(path: path);
      return failureOrSuccess.fold((failure) async => getFromCache(), (
        value,
      ) async {
        await Future.wait([
          setLocal(path: path, value: value),
          setSavedAtLocal(key: key, path: path),
        ]);
        return Right(value);
      });
    }
    return getFromCache();
  } catch (err) {
    return Left(unidentifiedFailure);
  }
}

Future<Either<F, T>> forwardedCachedHttpRequest<F, T>({
  required String path,
  required CacheKey key,
  required DateTime? invalidateCacheBefore,
  required Duration? invalidateCacheDuration,
  required Either<F, Response> Function(Response response) fromResponse,
  required T Function(dynamic json) fromJson,
  required Future<Response> Function({required String path}) getFromRemote,
  required F emptyCacheFailure,
  required F unidentifiedFailure,
  required CacheLocalDataSource localDataSource,
  Future<dynamic> Function({required String path})? getFromLocal,
  Future<bool> Function({required String path, required dynamic value})?
  setLocal,
  Future<bool> Function({required CacheKey key, required String path})?
  setSavedAtLocal,
}) async {
  try {
    Future<Either<F, T>> getFromCache() async {
      final value =
          await (getFromLocal?.call(path: path) ??
              localDataSource.getJson(path: path));
      if (value != null) {
        return Right(fromJson(value));
      }
      return Left(emptyCacheFailure);
    }

    final invalidateCache = await localDataSource.invalidateCacheRule(
      key: key,
      path: path,
      invalidateCacheBefore: invalidateCacheBefore,
      invalidateCacheDuration: invalidateCacheDuration,
    );
    if (invalidateCache) {
      final response = await getFromRemote(path: path);
      final failureOrSuccess = await fromResponse(response);
      return failureOrSuccess.fold<Future<Either<F, T>>>(
        (failure) async => getFromCache(),
        (response) async {
          if (response.statusCode == 200) {
            final value = jsonDecode(response.body);
            await Future.wait([
              setLocal?.call(path: path, value: value) ??
                  localDataSource.setJson(path: path, value: value),
              setSavedAtLocal?.call(key: key, path: path) ??
                  localDataSource.setSavedAt(key: key, path: path),
            ]);
            return Right(fromJson(value));
          }
          return getFromCache();
        },
      );
    }
    return getFromCache();
  } catch (err) {
    return Left(unidentifiedFailure);
  }
}
