import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/domain/failures/storage_failure.dart';
import '../../../../core/domain/utils/either.dart';
import '../../data/repositories/firebase_storage_repository.dart';
import '../repositories/storage_repository.dart';

class GetJsonUsecase {
  final StorageRepository _repository;

  const GetJsonUsecase({required StorageRepository repository})
    : _repository = repository;

  Future<Either<StorageFailure, dynamic>> call({
    required String path,
    required DateTime? invalidateCacheBefore,
    required Duration? invalidateCacheDuration,
  }) => _repository.getJson(
    path: path,
    invalidateCacheBefore: invalidateCacheBefore,
    invalidateCacheDuration: invalidateCacheDuration,
  );
}

final getJsonUsecaseProvider = Provider.autoDispose<GetJsonUsecase>(
  (ref) =>
      GetJsonUsecase(repository: ref.read(firebaseStorageRepositoryProvider)),
);
