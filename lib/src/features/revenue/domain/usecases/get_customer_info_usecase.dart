import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../data/repositories/revenue_repository.dart';
import '../repositories/revenue_repository.dart';

class GetCustomerInfoUsecase {
  final RevenueRepository _repository;

  const GetCustomerInfoUsecase({
    required RevenueRepository repository,
  }) : _repository = repository;

  Future<CustomerInfo?> call() => _repository.getCustomerInfo();
}

final getCustomerInfoUsecaseProvider =
    Provider.autoDispose<GetCustomerInfoUsecase>(
  (ref) => GetCustomerInfoUsecase(
    repository: ref.read(revenueRepositoryProvider),
  ),
);
