import 'package:hooks_riverpod/legacy.dart';
import 'package:ios_design_system/ios_design_system.dart';

import '../../../../core/presentation/notifiers/safe_state_notifier.dart';
import '../../domain/usecases/get_theme_data_usecase.dart';
import '../../domain/usecases/remove_theme_data_usecase.dart';
import '../../domain/usecases/set_theme_data_usecase.dart';

class ThemeStateNotifier extends SafeStateNotifier<IosThemeData?> {
  final GetThemeDataUsecase _getThemeDataUsecase;
  final RemoveThemeDataUsecase _removeThemeDataUsecase;
  final SetThemeDataUsecase _setThemeDataUsecase;

  ThemeStateNotifier({
    required GetThemeDataUsecase getThemeDataUsecase,
    required RemoveThemeDataUsecase removeThemeDataUsecase,
    required SetThemeDataUsecase setThemeDataUsecase,
  }) : _getThemeDataUsecase = getThemeDataUsecase,
       _removeThemeDataUsecase = removeThemeDataUsecase,
       _setThemeDataUsecase = setThemeDataUsecase,
       super(getThemeDataUsecase());

  IosThemeData? getThemeData() {
    final iosThemeData = _getThemeDataUsecase();
    state = iosThemeData;
    return iosThemeData;
  }

  Future<bool> setThemeData({
    required IosThemeData iosThemeData,
    bool save = true,
  }) async {
    if (save) {
      final settedUp = await _setThemeDataUsecase(iosThemeData: iosThemeData);
      if (settedUp) {
        state = iosThemeData;
      }
      return settedUp;
    }
    state = iosThemeData;
    return false;
  }

  Future<bool> removeThemeData() async {
    final removed = await _removeThemeDataUsecase();
    if (removed) {
      state = null;
    }
    return removed;
  }
}

final themeStateNotifierProvider =
    StateNotifierProvider<ThemeStateNotifier, IosThemeData?>(
      (ref) => ThemeStateNotifier(
        getThemeDataUsecase: ref.read(getThemeDataUsecaseProvider),
        removeThemeDataUsecase: ref.read(removeThemeDataUsecaseProvider),
        setThemeDataUsecase: ref.read(setThemeDataUsecaseProvider),
      ),
    );
