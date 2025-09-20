import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/locale_repository.dart';
import '../repositories/locale_repository.dart';

class RemoveLocaleUsecase {
  final LocaleRepository _repository;

  const RemoveLocaleUsecase({
    required LocaleRepository repository,
  }) : _repository = repository;

  Future<bool> call() => _repository.removeLocale();
}

final removeLocaleUsecaseProvider = Provider.autoDispose<RemoveLocaleUsecase>(
  (ref) => RemoveLocaleUsecase(
    repository: ref.read(localeRepositoryProvider),
  ),
);
