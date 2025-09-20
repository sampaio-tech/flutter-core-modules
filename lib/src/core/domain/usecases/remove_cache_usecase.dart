import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/cache_repository.dart';
import '../repositories/cache_repository.dart';

class RemoveCacheUsecase {
  final CacheRepository _repository;

  const RemoveCacheUsecase({
    required CacheRepository repository,
  }) : _repository = repository;

  Future<bool> call({
    required String key,
  }) =>
      _repository.remove(key: key);
}

final removeCacheUsecaseProvider = Provider.autoDispose<RemoveCacheUsecase>(
  (ref) => RemoveCacheUsecase(
    repository: ref.read(cacheRepositoryProvider),
  ),
);
