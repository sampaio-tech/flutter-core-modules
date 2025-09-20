import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../features/analytics/presentation/setup/amplitude/amplitude.dart';
import '../../../../features/analytics/presentation/setup/firebase_analytics/firebase_analytics.dart';
import '../../../../features/analytics/presentation/setup/mixpanel/mixpanel.dart';
import '../../../../features/analytics/presentation/setup/posthog/posthog.dart';
import '../../../../features/analytics/presentation/setup/statsig/statsig.dart';
import '../../../../features/revenue/presentation/config/revenue_cat.dart';

class DotEnv {
  static Future<void> load() => dotenv.load();

  static bool enableAnalytics = !kDebugMode;

  static bool enableClarity = !kDebugMode;

  static bool enableCrashlytics = !kDebugMode;

  static String? getClarityProjectId() => dotenv.maybeGet('CLARITY_PROJECT_ID');

  static String? getStatsigClientSdkKey() =>
      dotenv.maybeGet('STATSIG_CLIENT_SDK_KEY');

  static String? getMixpanelToken() => dotenv.maybeGet('MIXPANEL_TOKEN');

  static String? getPosthogToken() => dotenv.maybeGet('POSTHOG_TOKEN');

  static String? getAmplitudeToken() => dotenv.maybeGet('AMPLITUDE_TOKEN');

  static String? getRevenueCatProjectAppleApiKey() =>
      dotenv.maybeGet('REVENUECAT_PROJECT_APPLE_API_KEY');

  static String? getRevenueCatProjectGoogleApiKey() =>
      dotenv.maybeGet('REVENUECAT_PROJECT_GOOGLE_API_KEY');

  static Future<void> init(FirebaseRemoteConfig firebaseRemoteConfig) async {
    await load();
    await Future.wait(
      [
        if (enableAnalytics) StatsigConfig.init(),
        if (enableAnalytics) MixpanelConfig.init(),
        if (enableAnalytics) PosthogConfig.init(),
        if (enableAnalytics) AmplitudeConfig.init(),
        if (enableAnalytics) FirebaseAnalyticsConfig.init(),
        initPlatformState(),
      ],
    );
  }
}
