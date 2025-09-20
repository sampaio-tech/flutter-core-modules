import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_design_system/ios_design_system.dart';

import '../../data/repositories/theme_repository.dart';
import '../repositories/theme_repository.dart';

class GetThemeDataUsecase {
  final ThemeRepository _repository;

  const GetThemeDataUsecase({
    required ThemeRepository repository,
  }) : _repository = repository;

  IosThemeData? call() => _repository.getThemeData();
}

final getThemeDataUsecaseProvider = Provider.autoDispose<GetThemeDataUsecase>(
  (ref) => GetThemeDataUsecase(
    repository: ref.read(themeRepositoryProvider),
  ),
);
