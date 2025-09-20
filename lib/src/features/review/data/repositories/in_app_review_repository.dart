import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../domain/repositories/in_app_review_repository.dart';
import '../../presentation/providers/in_app_review.dart';

class InAppReviewRepositoryImpl extends InAppReviewRepository {
  final InAppReview _inAppReview;

  const InAppReviewRepositoryImpl({
    required InAppReview inAppReview,
  }) : _inAppReview = inAppReview;

  @override
  Future<void> requestReview() => _inAppReview.requestReview();

  @override
  Future<bool> isAvailable() => _inAppReview.isAvailable();

  @override
  Future<void> openStoreListing({
    String? appStoreId,
    String? microsoftStoreId,
  }) =>
      _inAppReview.openStoreListing(
        appStoreId: appStoreId,
        microsoftStoreId: microsoftStoreId,
      );
}

final inAppReviewRepositoryProvider =
    Provider.autoDispose<InAppReviewRepository>(
  (ref) => InAppReviewRepositoryImpl(
    inAppReview: ref.read(inAppReviewProvider),
  ),
);
