import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_design_system/ios_design_system.dart';

import '../../data/repositories/theme_repository.dart';
import '../repositories/theme_repository.dart';

class SetThemeDataUsecase {
  final ThemeRepository _repository;

  const SetThemeDataUsecase({
    required ThemeRepository repository,
  }) : _repository = repository;

  Future<bool> call({
    required IosThemeData iosThemeData,
  }) =>
      _repository.setThemeData(
        iosThemeData: iosThemeData,
      );
}

final setThemeDataUsecaseProvider = Provider.autoDispose<SetThemeDataUsecase>(
  (ref) => SetThemeDataUsecase(
    repository: ref.read(themeRepositoryProvider),
  ),
);
