---
name: analytics-feature
description: Explains the analytics feature in flutter_core_modules — EventEntity, how to define and track new events, the multi-provider architecture (Amplitude, Firebase Analytics, Mixpanel, PostHog, Statsig), remote config gating, and how analytics integrates with the route observer. Use when adding new analytics events, understanding how events are routed to providers, or extending analytics with a new SDK.
---

# Analytics Feature — flutter_core_modules

The analytics feature provides a **provider-agnostic event tracking API**. A single `EventEntity.track(context)` call fans out to all enabled analytics providers simultaneously.

---

## 1. Architecture Overview

```
EventEntity.track(context)
    │
    └──► ProviderScope.containerOf(context)
             │
             └──► analyticsRepositoryProvider (AnalyticsRepositoryImpl)
                      │
                      ├──► AmplitudeConfig.enabled  → amplitude.track(BaseEvent)
                      ├──► FirebaseAnalyticsConfig.enabled → firebaseAnalytics.logEvent()
                      ├──► PosthogConfig.enabled    → posthog.capture()
                      ├──► MixpanelConfig.enabled   → mixpanel.track()
                      └──► StatsigConfig.enabled    → Statsig.logEvent()
```

Each provider runs as a `Future.microtask` with `.catchError(() {})` — failures in one provider never affect others.

---

## 2. EventEntity — Base Class for All Events

**File:** `lib/src/features/analytics/domain/entities/events/event_entity.dart`

```dart
abstract class EventEntity {
  const EventEntity();

  // Override to provide event properties
  Map<String, Object>? get properties;

  // Derived — converts class name to snake_case automatically
  // e.g. TapOnReviewButton → 'tap_on_review_button'
  String get name => formatToSnakeCase(runtimeType.toString());

  // Tracks to all enabled analytics providers via ProviderScope
  Future<void> track({required BuildContext context});

  // Properties with all values toString'd (needed for Firebase which rejects non-String/num)
  Map<String, Object>? get propertiesToAvoidAssertInputTypes;
}
```

**Key design decision:** Event names are derived **automatically** from the class name via `runtimeType.toString()` converted to snake_case. No manual `name` override needed.

---

## 3. How to Define a New Event

### Simple event (no properties):
```dart
// In the relevant file or a new events file:
class TapOnMyFeature extends EventEntity {
  const TapOnMyFeature();

  @override
  Map<String, Object>? get properties => const {};
}
```

### Event with properties:
```dart
class SelectPlan extends EventEntity {
  final String planId;
  final double price;
  const SelectPlan({required this.planId, required this.price});

  @override
  Map<String, Object>? get properties => {
    'plan_id': planId,
    'price': price,
  };
}
```

### Where to put new events:
- Generic app events → `lib/src/features/analytics/domain/entities/events/events.dart`
- Tap-related UI events → `lib/src/features/analytics/domain/entities/events/tap_on_events.dart`
- Feature-specific events → create a new file: `lib/src/features/analytics/domain/entities/events/<feature>_events.dart`
- Export from `lib/flutter_core_modules.dart`

---

## 4. How to Track an Event

From any widget with `BuildContext`:
```dart
// In build() or event handlers:
TapOnMyFeature().track(context: context);

// With properties:
SelectPlan(planId: 'premium_annual', price: 99.99).track(context: context);
```

From a `HookConsumerWidget` or `ConsumerWidget`, you can also use the `TrackEventUsecase`:
```dart
final trackEvent = ref.read(trackEventUsecaseProvider);
await trackEvent(event: TapOnMyFeature());
```

In debug mode, `track()` logs the event name and properties to the console via `developer.log()`.

---

## 5. Existing Events Reference

### `events.dart`
| Class | Properties | Description |
|---|---|---|
| `ChangeLanguageTo` | `locale: {languageCode, countryCode}` | User changes app language |
| `InAppReviewIsAvailable` | `isAvailable: bool` | In-app review availability check result |
| `OnHasActiveSubscriptionCallback` | `featureLocked, event?` | User already has subscription when paywall shown |
| `OnPresentedPaywallCallback` | `featureLocked, event?` | Paywall presented |
| `OnSyncPurchasesCallback` | `featureLocked, event?, paywallResult` | Purchase synced after paywall |
| `OnPresentPaywallResultCallback` | `featureLocked, event?, paywallResult` | Paywall result returned |
| `InitApp` | `{}` | App initialized |

### `tap_on_events.dart`
| Class | Properties | Description |
|---|---|---|
| `TapOnDarkModeSettings` | `enable, theme` | Dark mode toggle |
| `TapOnChangeLanguageSettings` | `{}` | Language setting opened |
| `TapOnPreventSleepSettings` | `enable` | Wakelock toggle |
| `TapOnVibrationFeedbackSettings` | `enable` | Haptic toggle |
| `TapOnCopyToClipboard` | `label?, title?, description?` | Row value copied |
| `TapOnOpenLink` | `label?, title?, description?` | Link opened in WebView |
| `TapOnReviewButton` | `{}` | Review requested |
| `TapOnFeedbackButton` | `{}` | Feedback opened |
| `TapOnGetPremiumButton` | `{}` | Premium CTA tapped |
| `TapOnManagePremiumButton` | `{}` | Subscription management tapped |

---

## 6. Analytics Providers — Init and Configuration

All providers are initialized by `DotEnv.init()`. Each has a static `enabled` getter that checks:
1. The corresponding `.env` token is not null
2. The Firebase Remote Config flag is `true`

### Firebase Remote Config Gates

**File:** `lib/src/features/analytics/presentation/setup/remote_config/remote_config.dart`

Remote Config key → analytics toggle:
| RC Key | Controls |
|---|---|
| `enable_firebase_analytics` | `FirebaseAnalyticsConfig.enabled` |
| `enable_amplitude` | `AmplitudeConfig.enabled` |
| `enable_mixpanel` | `MixpanelConfig.enabled` |
| `enable_statsig` | `StatsigConfig.enabled` |
| `enable_posthog` | `PosthogConfig.enabled` |
| `enable_clarity` | `DotEnv.enableClarity` |
| `feedback_email` | `FirebaseRemoteConfigCore.feedbackEmail` |

All analytics is automatically **disabled in debug mode** via `DotEnv.enableAnalytics = !kDebugMode`.

### Provider Initialization Details

| Provider | File | Notes |
|---|---|---|
| **Amplitude** | `presentation/setup/amplitude/amplitude.dart` | Singleton via `AmplitudeConfig._instance`. Tracks `init_app` on init. |
| **Firebase Analytics** | `presentation/setup/firebase_analytics/firebase_analytics.dart` | Uses `FirebaseAnalytics.instance`. Logs `app_open` + `init_app` on init. |
| **Mixpanel** | `presentation/setup/mixpanel/mixpanel.dart` | Singleton. `optOutTrackingDefault: true`. Tracks `init_app`. |
| **PostHog** | `presentation/setup/posthog/posthog.dart` | Host: `https://us.i.posthog.com`. Debug mode enabled in `kDebugMode`. |
| **Statsig** | `presentation/setup/statsig/statsig.dart` | No singleton needed — uses Statsig singleton SDK. |

All providers expose a Riverpod provider returning the nullable instance:
```dart
final amplitudeProvider  = Provider<Amplitude?> ((ref) => AmplitudeConfig.instance);
final mixpanelProvider   = Provider<Mixpanel?>  ((ref) => MixpanelConfig.instance);
final posthogProvider    = Provider<Posthog?>   ((ref) => PosthogConfig.instance);
final firebaseAnalyticsProvider = Provider<FirebaseAnalytics?>(...);
```

`null` means the provider is not initialized (disabled or token missing).

---

## 7. Analytics Repository

**File:** `lib/src/features/analytics/data/repositories/analytics_repository.dart`

```dart
class AnalyticsRepositoryImpl extends AnalyticsRepository {
  Future<void> track(EventEntity event) async {
    if (DotEnv.enableAnalytics) {
      await Future.wait([
        if (AmplitudeConfig.enabled && _amplitude != null)
          execMicrotask(() => _amplitude.track(BaseEvent(event.name, ...))),
        if (FirebaseAnalyticsConfig.enabled && _firebaseAnalytics != null)
          execMicrotask(() => _firebaseAnalytics.logEvent(
            name: event.name,
            parameters: event.propertiesToAvoidAssertInputTypes, // strings only
          )),
        // ... other providers
      ]);
    }
  }
}
```

`execMicrotask()` wraps each call in `Future.microtask().catchError((_) {})` so analytics errors are silently swallowed and never crash the app.

Firebase Analytics uses `propertiesToAvoidAssertInputTypes` (all values converted to `String`) because the Firebase SDK asserts that event parameter values must be `String` or `num`. Other providers use `properties` directly.

---

## 8. Navigation Observers

**File:** `lib/src/features/route/presentation/utils/navigation_observers.dart`

```dart
List<NavigatorObserver> defaultNavigatorObservers(BuildContext context) {
  return switch (DotEnv.enableAnalytics) {
    true => [
      if (FirebaseAnalyticsConfig.enabled && firebaseAnalytics != null)
        FirebaseAnalyticsObserver(analytics: firebaseAnalytics),
      if (PosthogConfig.enabled && posthog != null) PosthogObserver(),
    ],
    false => [],
  };
}
```

Pass `defaultNavigatorObservers(context)` to `navigatorObservers` in `CupertinoApp` or `NavigationTab.navigatorObservers()`.

---

## 9. How to Add a New Analytics Provider

1. Create `lib/src/features/analytics/presentation/setup/<sdk>/<sdk>.dart`:
   ```dart
   final class MySdkConfig {
     static MySdk? _instance;
     static MySdk? get instance => _instance;

     static Future<void> init() async {
       if (enabled && _instance == null) {
         _instance = await MySdk.init(DotEnv.getMyToken()!);
       }
     }

     static bool get enabled =>
         DotEnv.getMyToken() != null &&
         FirebaseRemoteConfigCore.enableMySdk;
   }

   final mySdkProvider = Provider<MySdk?>((ref) => MySdkConfig.instance);
   ```

2. Add token getter to `DotEnv`:
   ```dart
   static String? getMyToken() => dotenv.maybeGet('MY_SDK_TOKEN');
   ```

3. Add Remote Config toggle getter to `FirebaseRemoteConfigCore`:
   ```dart
   static bool get enableMySdk => FirebaseRemoteConfig.instance.getBool('enable_my_sdk');
   ```

4. Add init call to `DotEnv.init()`:
   ```dart
   if (enableAnalytics) MySdkConfig.init(),
   ```

5. Add tracking call to `AnalyticsRepositoryImpl.track()`:
   ```dart
   if (MySdkConfig.enabled && _mySdk != null)
     execMicrotask(() => _mySdk.track(event.name, event.properties)),
   ```

6. Add provider to `AnalyticsRepositoryImpl` constructor and `analyticsRepositoryProvider`.

7. Export the new config file from `lib/flutter_core_modules.dart`.
