import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../../../../core/presentation/setup/dot_env/dot_env.dart';
import '../remote_config/remote_config.dart';

final class PosthogConfig {
  const PosthogConfig._();

  static Posthog? get instance => _instance;
  static Posthog? _instance;
  static const _initEventName = 'init_app';
  static const host = 'https://us.i.posthog.com';

  static Future<void> init() async {
    if (enabled && _instance == null) {
      final config = PostHogConfig(DotEnv.getPosthogToken()!);
      config.debug = kDebugMode;
      config.captureApplicationLifecycleEvents = true;
      config.host = host;
      final posthog = Posthog();
      await posthog.setup(config);
      await posthog.capture(eventName: _initEventName);
      _instance = posthog;
    }
  }

  static bool get enabled =>
      DotEnv.getPosthogToken() != null &&
      FirebaseRemoteConfigCore.enablePosthog;
}

final posthogProvider = Provider<Posthog?>((ref) => PosthogConfig.instance);
