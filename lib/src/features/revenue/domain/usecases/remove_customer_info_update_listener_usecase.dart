import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';

import '../../data/repositories/revenue_repository.dart';
import '../repositories/revenue_repository.dart';

class RemoveCustomerInfoUpdateListenerUsecase {
  final RevenueRepository _repository;

  const RemoveCustomerInfoUpdateListenerUsecase({
    required RevenueRepository repository,
  }) : _repository = repository;

  Future<void> call(
    void Function(CustomerInfo) listener,
  ) =>
      _repository.removeCustomerInfoUpdateListener(listener);
}

final removeCustomerInfoUpdateListenerUsecaseProvider =
    Provider.autoDispose<RemoveCustomerInfoUpdateListenerUsecase>(
  (ref) => RemoveCustomerInfoUpdateListenerUsecase(
    repository: ref.read(revenueRepositoryProvider),
  ),
);
