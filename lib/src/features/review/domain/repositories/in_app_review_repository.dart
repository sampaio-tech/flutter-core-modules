abstract class InAppReviewRepository {
  const InAppReviewRepository();

  Future<void> requestReview();

  Future<bool> isAvailable();

  Future<void> openStoreListing({
    String? appStoreId,
    String? microsoftStoreId,
  });
}
