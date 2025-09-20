import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../remote_config/remote_config.dart';

final class FirebaseAnalyticsConfig {
  const FirebaseAnalyticsConfig._();

  static FirebaseAnalytics? get instance => _instance;
  static FirebaseAnalytics? _instance;
  static const _initEventName = 'init_app';

  static Future<void> init() async {
    final firebaseAnalytics = FirebaseAnalytics.instance;
    await firebaseAnalytics.setAnalyticsCollectionEnabled(!enabled);
    if (enabled && _instance == null) {
      await firebaseAnalytics.logAppOpen();
      await firebaseAnalytics.logEvent(name: _initEventName);
      _instance = firebaseAnalytics;
    }
  }

  static bool get enabled => FirebaseRemoteConfigCore.enableFirebaseAnalytics;
}

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics?>(
  (ref) => FirebaseAnalyticsConfig.instance,
);
