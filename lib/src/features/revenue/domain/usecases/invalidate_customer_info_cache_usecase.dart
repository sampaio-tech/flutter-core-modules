import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/revenue_repository.dart';
import '../repositories/revenue_repository.dart';

class InvalidateCustomerInfoCacheUsecase {
  final RevenueRepository _repository;

  const InvalidateCustomerInfoCacheUsecase({
    required RevenueRepository repository,
  }) : _repository = repository;

  Future<void> call() => _repository.invalidateCustomerInfoCache();
}

final invalidateCustomerInfoCacheUsecaseProvider =
    Provider.autoDispose<InvalidateCustomerInfoCacheUsecase>(
  (ref) => InvalidateCustomerInfoCacheUsecase(
    repository: ref.read(revenueRepositoryProvider),
  ),
);
