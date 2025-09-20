import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final class FirebaseRemoteConfigCore {
  const FirebaseRemoteConfigCore._();

  static Future<FirebaseRemoteConfig> init() async {
    final firebaseRemoteConfig = FirebaseRemoteConfig.instance;
    await firebaseRemoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 2),
        minimumFetchInterval: switch (kDebugMode) {
          true => const Duration(minutes: 1),
          false => const Duration(minutes: 5),
        },
      ),
    );
    await firebaseRemoteConfig.ensureInitialized();
    await firebaseRemoteConfig.fetchAndActivate();
    return firebaseRemoteConfig;
  }

  static String get feedbackEmail =>
      FirebaseRemoteConfig.instance.getString('feedback_email');

  static bool get enableClarity =>
      FirebaseRemoteConfig.instance.getBool('enable_clarity');

  static bool get enableFirebaseAnalytics =>
      FirebaseRemoteConfig.instance.getBool('enable_firebase_analytics');

  static bool get enableAmplitude =>
      FirebaseRemoteConfig.instance.getBool('enable_amplitude');

  static bool get enableMixpanel =>
      FirebaseRemoteConfig.instance.getBool('enable_mixpanel');

  static bool get enableStatsig =>
      FirebaseRemoteConfig.instance.getBool('enable_statsig');

  static bool get enablePosthog =>
      FirebaseRemoteConfig.instance.getBool('enable_posthog');
}

final firebaseRemoteConfigProvider = Provider<FirebaseRemoteConfig>(
  (ref) => FirebaseRemoteConfig.instance,
);
