import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';

import '../../data/repositories/revenue_repository.dart';
import '../repositories/revenue_repository.dart';

class AddCustomerInfoUpdateListenerUsecase {
  final RevenueRepository _repository;

  const AddCustomerInfoUpdateListenerUsecase({
    required RevenueRepository repository,
  }) : _repository = repository;

  Future<void> call(
    void Function(CustomerInfo) listener,
  ) =>
      _repository.addCustomerInfoUpdateListener(listener);
}

final addCustomerInfoUpdateListenerUsecaseProvider =
    Provider.autoDispose<AddCustomerInfoUpdateListenerUsecase>(
  (ref) => AddCustomerInfoUpdateListenerUsecase(
    repository: ref.read(revenueRepositoryProvider),
  ),
);
