import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_design_system/ios_design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/presentation/setup/shared_preferences/provider.dart';
import '../../domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl extends ThemeRepository {
  final SharedPreferences _sharedPreferences;

  const ThemeRepositoryImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  @override
  IosThemeData? getThemeData() {
    final key = _DatabaseKeys.iosThemeData.key;
    final value = _sharedPreferences.getString(key);
    return switch (value) {
      null => null,
      final iosThemeData => switch (iosThemeData) {
          final value
              when value == IosLightThemeData().runtimeType.toString() =>
            IosLightThemeData(),
          final value when value == IosDarkThemeData().runtimeType.toString() =>
            IosDarkThemeData(),
          _ => null,
        },
    };
  }

  @override
  Future<bool> setThemeData({
    required IosThemeData iosThemeData,
  }) async {
    final key = _DatabaseKeys.iosThemeData.key;
    final value = iosThemeData.runtimeType.toString();
    return _sharedPreferences.setString(
      key,
      value,
    );
  }

  @override
  Future<bool> removeThemeData() =>
      _sharedPreferences.remove(_DatabaseKeys.iosThemeData.key);
}

enum _DatabaseKeys {
  iosThemeData;

  String get key => switch (kDebugMode) {
        true => '${name}Debug',
        false => name,
      };
}

final themeRepositoryProvider = Provider.autoDispose<ThemeRepository>(
  (ref) => ThemeRepositoryImpl(
    sharedPreferences: ref.read(sharedPreferencesProvider),
  ),
);
