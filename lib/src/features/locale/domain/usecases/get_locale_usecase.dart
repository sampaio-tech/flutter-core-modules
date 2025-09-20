import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/locale_repository.dart';
import '../repositories/locale_repository.dart';

class GetLocaleUsecase {
  final LocaleRepository _repository;

  const GetLocaleUsecase({
    required LocaleRepository repository,
  }) : _repository = repository;

  Locale? call() => _repository.getLocale();
}

final getLocaleUsecaseProvider = Provider.autoDispose<GetLocaleUsecase>(
  (ref) => GetLocaleUsecase(
    repository: ref.read(localeRepositoryProvider),
  ),
);
