import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/locale_repository.dart';
import '../repositories/locale_repository.dart';

class SetLocaleUsecase {
  final LocaleRepository _repository;

  const SetLocaleUsecase({
    required LocaleRepository repository,
  }) : _repository = repository;

  Future<bool> call({
    required Locale locale,
  }) =>
      _repository.setLocale(locale: locale);
}

final setLocaleUsecaseProvider = Provider.autoDispose<SetLocaleUsecase>(
  (ref) => SetLocaleUsecase(
    repository: ref.read(localeRepositoryProvider),
  ),
);
