import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SharedPreferencesInstance {
  static SharedPreferences? _sharedPreferences;

  const SharedPreferencesInstance._();

  static Future<SharedPreferences> getInstanceSharedPreferences() =>
      switch (_sharedPreferences) {
        null => SharedPreferences.getInstance()
            .then((value) => _sharedPreferences = value),
        final sharedPreferences => Future.value(sharedPreferences),
      };

  static SharedPreferences get getSharedPreferences => _sharedPreferences!;
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => SharedPreferencesInstance.getSharedPreferences,
);
