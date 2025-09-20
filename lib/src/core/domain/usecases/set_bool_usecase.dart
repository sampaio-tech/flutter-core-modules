import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/cache_repository.dart';
import '../repositories/cache_repository.dart';

class SetBoolUsecase {
  final CacheRepository _repository;

  const SetBoolUsecase({
    required CacheRepository repository,
  }) : _repository = repository;

  Future<bool> call({
    required String key,
    required bool value,
  }) =>
      _repository.setBool(
        key: key,
        value: value,
      );
}

final setBoolUsecaseProvider = Provider.autoDispose<SetBoolUsecase>(
  (ref) => SetBoolUsecase(
    repository: ref.read(cacheRepositoryProvider),
  ),
);
