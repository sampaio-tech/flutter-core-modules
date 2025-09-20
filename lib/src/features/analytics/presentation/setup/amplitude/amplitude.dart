import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/constants.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/presentation/setup/dot_env/dot_env.dart';
import '../remote_config/remote_config.dart';

final class AmplitudeConfig {
  const AmplitudeConfig._();

  static Amplitude? get instance => _instance;
  static Amplitude? _instance;
  static const _initEventName = 'init_app';

  static Future<void> init() async {
    if (enabled && _instance == null) {
      final amplitude = Amplitude(
        Configuration(
          apiKey: DotEnv.getAmplitudeToken()!,
          logLevel: switch (kDebugMode) {
            true => LogLevel.debug,
            false => LogLevel.off,
          },
        ),
      );
      final isBuilt = await amplitude.isBuilt;
      if (isBuilt) {
        await amplitude.track(BaseEvent(_initEventName));
        await amplitude.flush();
      }
      _instance = amplitude;
    }
  }

  static bool get enabled =>
      DotEnv.getAmplitudeToken() != null &&
      FirebaseRemoteConfigCore.enableAmplitude;
}

final amplitudeProvider = Provider<Amplitude?>(
  (ref) => AmplitudeConfig.instance,
);
