import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../../../core/presentation/setup/dot_env/dot_env.dart';
import '../../../analytics/presentation/setup/firebase_analytics/firebase_analytics.dart';
import '../../../analytics/presentation/setup/posthog/posthog.dart';

List<NavigatorObserver> defaultNavigatorObservers(BuildContext context) {
  final firebaseAnalytics = ProviderScope.containerOf(
    context,
  ).read(firebaseAnalyticsProvider);
  final posthog = ProviderScope.containerOf(context).read(posthogProvider);
  return switch (DotEnv.enableAnalytics) {
    true => [
      if (FirebaseAnalyticsConfig.enabled && firebaseAnalytics != null)
        FirebaseAnalyticsObserver(analytics: firebaseAnalytics),
      if (PosthogConfig.enabled && posthog != null) PosthogObserver(),
    ],
    false => [],
  };
}
