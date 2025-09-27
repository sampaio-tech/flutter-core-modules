import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/domain/failures/storage_failure.dart';
import '../../../../core/domain/utils/either.dart';
import '../../data/repositories/firebase_storage_repository.dart';
import '../repositories/storage_repository.dart';

class GetDownloadUrlUsecase {
  final StorageRepository _repository;

  const GetDownloadUrlUsecase({required StorageRepository repository})
    : _repository = repository;

  Future<Either<StorageFailure, String>> call({
    required String path,
    required DateTime? invalidateCacheBefore,
    required Duration? invalidateCacheDuration,
  }) => _repository.getDownloadUrl(
    path: path,
    invalidateCacheBefore: invalidateCacheBefore,
    invalidateCacheDuration: invalidateCacheDuration,
  );
}

final getDownloadUrlUsecaseProvider =
    Provider.autoDispose<GetDownloadUrlUsecase>(
      (ref) => GetDownloadUrlUsecase(
        repository: ref.read(firebaseStorageRepositoryProvider),
      ),
    );
