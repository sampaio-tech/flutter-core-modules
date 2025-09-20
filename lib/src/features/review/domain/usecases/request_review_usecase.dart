import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/in_app_review_repository.dart';
import '../repositories/in_app_review_repository.dart';

class RequestReviewUsecase {
  final InAppReviewRepository _repository;

  const RequestReviewUsecase({
    required InAppReviewRepository repository,
  }) : _repository = repository;

  Future<void> call() => _repository.requestReview();
}

final requestReviewUsecaseProvider = Provider.autoDispose<RequestReviewUsecase>(
  (ref) => RequestReviewUsecase(
    repository: ref.read(inAppReviewRepositoryProvider),
  ),
);
