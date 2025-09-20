import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/revenue_repository.dart';
import '../repositories/revenue_repository.dart';

class GetIsAnonymousUsecase {
  final RevenueRepository _repository;

  const GetIsAnonymousUsecase({required RevenueRepository repository})
    : _repository = repository;

  Future<bool?> call() => _repository.getIsAnonymous();
}

final getIsAnonymousUsecaseProvider =
    Provider.autoDispose<GetIsAnonymousUsecase>(
      (ref) => GetIsAnonymousUsecase(
        repository: ref.read(revenueRepositoryProvider),
      ),
    );
