import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/presentation/notifiers/safe_state_notifier.dart';
import '../../domain/usecases/is_available_usecase.dart';
import '../../domain/usecases/open_store_listing_usecase.dart';
import '../../domain/usecases/request_review_usecase.dart';

class InAppReviewStateNotifier extends SafeStateNotifier<bool> {
  final IsAvailableUsecase _isAvailableUsecase;
  final OpenStoreListingUsecase _openStoreListingUsecase;
  final RequestReviewUsecase _requestReviewUsecase;

  InAppReviewStateNotifier({
    required IsAvailableUsecase isAvailableUsecase,
    required OpenStoreListingUsecase openStoreListingUsecase,
    required RequestReviewUsecase requestReviewUsecase,
  }) : _isAvailableUsecase = isAvailableUsecase,
       _openStoreListingUsecase = openStoreListingUsecase,
       _requestReviewUsecase = requestReviewUsecase,
       super(false);

  Future<bool> isAvailable() async {
    final isAvailable = await _isAvailableUsecase();
    state = isAvailable;
    return isAvailable;
  }

  Future<bool> requestReview({
    void Function()? requestReviewCallback,
    void Function(bool value)? isAvailableCallback,
    bool openStoreListing = false,
  }) async {
    final canRequestReview = await isAvailable();
    isAvailableCallback?.call(canRequestReview);
    if (canRequestReview) {
      requestReviewCallback?.call();
      await switch (openStoreListing) {
        true => _openStoreListingUsecase(),
        false => _requestReviewUsecase(),
      };
      return isAvailable().then((value) async {
        isAvailableCallback?.call(value);
        return value;
      });
    }
    return canRequestReview;
  }

  Future<bool> openStoreListing({
    void Function()? openStoreListingCallback,
    void Function(bool value)? isAvailableCallback,
    String? appStoreId,
    String? microsoftStoreId,
  }) async {
    final canRequestReview = await isAvailable();
    isAvailableCallback?.call(canRequestReview);
    if (canRequestReview) {
      openStoreListingCallback?.call();
      await _openStoreListingUsecase(
        appStoreId: appStoreId,
        microsoftStoreId: microsoftStoreId,
      );
      return isAvailable().then((value) async {
        isAvailableCallback?.call(value);
        return value;
      });
    }
    return canRequestReview;
  }
}

final inAppReviewStateNotifierProvider =
    StateNotifierProvider<InAppReviewStateNotifier, bool>(
      (ref) => InAppReviewStateNotifier(
        isAvailableUsecase: ref.read(isAvailableUsecaseProvider),
        openStoreListingUsecase: ref.read(openStoreListingUsecaseProvider),
        requestReviewUsecase: ref.read(requestReviewUsecaseProvider),
      ),
    );
