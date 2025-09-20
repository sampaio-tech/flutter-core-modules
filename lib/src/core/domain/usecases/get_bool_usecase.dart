import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/cache_repository.dart';
import '../repositories/cache_repository.dart';

class GetBoolUsecase {
  final CacheRepository _repository;

  const GetBoolUsecase({
    required CacheRepository repository,
  }) : _repository = repository;

  bool? call({
    required String key,
  }) =>
      _repository.getBool(key: key);
}

final getBoolUsecaseProvider = Provider.autoDispose<GetBoolUsecase>(
  (ref) => GetBoolUsecase(
    repository: ref.read(cacheRepositoryProvider),
  ),
);
