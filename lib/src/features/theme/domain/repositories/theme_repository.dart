import 'package:ios_design_system/ios_design_system.dart';

abstract class ThemeRepository {
  const ThemeRepository();

  IosThemeData? getThemeData();

  Future<bool> setThemeData({
    required IosThemeData iosThemeData,
  });

  Future<bool> removeThemeData();
}
