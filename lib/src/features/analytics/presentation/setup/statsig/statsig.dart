import 'package:statsig/statsig.dart';

import '../../../../../core/presentation/setup/dot_env/dot_env.dart';
import '../remote_config/remote_config.dart';

final class StatsigConfig {
  const StatsigConfig._();

  static const _initEventName = 'init_app';

  static Future<void> init() async {
    if (enabled) {
      await Statsig.initialize(DotEnv.getStatsigClientSdkKey()!);
      Statsig.logEvent(_initEventName);
    }
  }

  static bool get enabled =>
      DotEnv.getStatsigClientSdkKey() != null &&
      FirebaseRemoteConfigCore.enableStatsig;
}
