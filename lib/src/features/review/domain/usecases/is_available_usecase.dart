import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/in_app_review_repository.dart';
import '../repositories/in_app_review_repository.dart';

class IsAvailableUsecase {
  final InAppReviewRepository _repository;

  const IsAvailableUsecase({
    required InAppReviewRepository repository,
  }) : _repository = repository;

  Future<bool> call() => _repository.isAvailable();
}

final isAvailableUsecaseProvider = Provider.autoDispose<IsAvailableUsecase>(
  (ref) => IsAvailableUsecase(
    repository: ref.read(inAppReviewRepositoryProvider),
  ),
);
