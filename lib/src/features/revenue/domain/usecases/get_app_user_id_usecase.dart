import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/revenue_repository.dart';
import '../repositories/revenue_repository.dart';

class GetAppUserIdUsecase {
  final RevenueRepository _repository;

  const GetAppUserIdUsecase({required RevenueRepository repository})
    : _repository = repository;

  Future<String?> call() => _repository.getAppUserID();
}

final getAppUserIdUsecaseProvider = Provider.autoDispose<GetAppUserIdUsecase>(
  (ref) => GetAppUserIdUsecase(repository: ref.read(revenueRepositoryProvider)),
);
