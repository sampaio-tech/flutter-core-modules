import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/in_app_review_repository.dart';
import '../repositories/in_app_review_repository.dart';

class OpenStoreListingUsecase {
  final InAppReviewRepository _repository;

  const OpenStoreListingUsecase({
    required InAppReviewRepository repository,
  }) : _repository = repository;

  Future<void> call({
    String? appStoreId,
    String? microsoftStoreId,
  }) =>
      _repository.openStoreListing(
        appStoreId: appStoreId,
        microsoftStoreId: microsoftStoreId,
      );
}

final openStoreListingUsecaseProvider =
    Provider.autoDispose<OpenStoreListingUsecase>(
  (ref) => OpenStoreListingUsecase(
    repository: ref.read(inAppReviewRepositoryProvider),
  ),
);
