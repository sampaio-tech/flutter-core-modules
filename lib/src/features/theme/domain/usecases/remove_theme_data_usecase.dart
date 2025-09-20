import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/theme_repository.dart';
import '../repositories/theme_repository.dart';

class RemoveThemeDataUsecase {
  final ThemeRepository _repository;

  const RemoveThemeDataUsecase({
    required ThemeRepository repository,
  }) : _repository = repository;

  Future<bool> call() => _repository.removeThemeData();
}

final removeThemeDataUsecaseProvider =
    Provider.autoDispose<RemoveThemeDataUsecase>(
  (ref) => RemoveThemeDataUsecase(
    repository: ref.read(themeRepositoryProvider),
  ),
);
