import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../../../../../core/presentation/setup/dot_env/dot_env.dart';
import '../remote_config/remote_config.dart';

final class MixpanelConfig {
  const MixpanelConfig._();

  static Mixpanel? get instance => _instance;
  static Mixpanel? _instance;
  static const _initEventName = 'init_app';

  static Future<void> init() async {
    if (enabled && _instance == null) {
      _instance =
          await Mixpanel.init(
            DotEnv.getMixpanelToken()!,
            trackAutomaticEvents: true,
            optOutTrackingDefault: true,
          ).then(
            (mixpanel) => mixpanel
              ..setLoggingEnabled(kDebugMode)
              ..track(_initEventName),
          );
    }
  }

  static bool get enabled =>
      DotEnv.getMixpanelToken() != null &&
      FirebaseRemoteConfigCore.enableMixpanel;
}

final mixpanelProvider = Provider<Mixpanel?>((ref) => MixpanelConfig.instance);
