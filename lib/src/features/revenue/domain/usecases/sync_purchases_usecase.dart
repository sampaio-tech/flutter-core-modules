import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/revenue_repository.dart';
import '../repositories/revenue_repository.dart';

class SyncPurchasesUsecase {
  final RevenueRepository _repository;

  const SyncPurchasesUsecase({
    required RevenueRepository repository,
  }) : _repository = repository;

  Future<void> call() => _repository.syncPurchases();
}

final syncPurchasesUsecaseProvider = Provider.autoDispose<SyncPurchasesUsecase>(
  (ref) => SyncPurchasesUsecase(
    repository: ref.read(revenueRepositoryProvider),
  ),
);
