import 'dart:async';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:statsig/statsig.dart';

import '../../../../core/presentation/setup/dot_env/dot_env.dart';
import '../../domain/entities/events/event_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../presentation/setup/amplitude/amplitude.dart';
import '../../presentation/setup/firebase_analytics/firebase_analytics.dart';
import '../../presentation/setup/mixpanel/mixpanel.dart';
import '../../presentation/setup/posthog/posthog.dart';
import '../../presentation/setup/statsig/statsig.dart';

class AnalyticsRepositoryImpl extends AnalyticsRepository {
  final Amplitude? _amplitude;
  final FirebaseAnalytics? _firebaseAnalytics;
  final Posthog? _posthog;
  final Mixpanel? _mixpanel;

  const AnalyticsRepositoryImpl({
    required Amplitude? amplitude,
    required FirebaseAnalytics? firebaseAnalytics,
    required Posthog? posthog,
    required Mixpanel? mixpanel,
  })  : _amplitude = amplitude,
        _firebaseAnalytics = firebaseAnalytics,
        _posthog = posthog,
        _mixpanel = mixpanel;

  Future<void> track(
    EventEntity event,
  ) async {
    if (DotEnv.enableAnalytics) {
      await Future.wait(
        [
          if (AmplitudeConfig.enabled && _amplitude != null)
            execMicrotask(
              () => _amplitude.track(
                BaseEvent(
                  event.name,
                  eventProperties: event.properties,
                ),
              ),
            ),
          if (FirebaseAnalyticsConfig.enabled && _firebaseAnalytics != null)
            execMicrotask(
              () => _firebaseAnalytics.logEvent(
                name: event.name,
                parameters: event.propertiesToAvoidAssertInputTypes,
              ),
            ),
          if (PosthogConfig.enabled && _posthog != null)
            execMicrotask(
              () => _posthog.capture(
                eventName: event.name,
                properties: event.properties,
              ),
            ),
          if (MixpanelConfig.enabled && _mixpanel != null)
            execMicrotask(
              () => _mixpanel.track(
                event.name,
                properties: event.properties,
              ),
            ),
          if (StatsigConfig.enabled)
            execMicrotask(
              () => Statsig.logEvent(
                event.name,
                metadata: event.properties?.map(
                  (key, value) => MapEntry(
                    key,
                    value.toString(),
                  ),
                ),
              ),
            ),
        ],
      );
    }
  }
}

Future<void> execMicrotask(
  FutureOr<void> Function() computation,
) =>
    Future.microtask(computation).catchError((error) {});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => AnalyticsRepositoryImpl(
    amplitude: ref.read(amplitudeProvider),
    firebaseAnalytics: ref.read(firebaseAnalyticsProvider),
    posthog: ref.read(posthogProvider),
    mixpanel: ref.read(mixpanelProvider),
  ),
);
