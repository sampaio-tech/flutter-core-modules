---
name: feature-review
description: Everything about the review feature in flutter_core_modules — in-app review request, store listing redirect, feedback email via url_launcher, InAppReviewStateNotifier, LaunchFeedbackStateNotifier, and how to use both from a consuming app. Use when implementing rate-app flows, feedback buttons, or asking whether review/feedback is already implemented.
---

# Feature: Review

**Purpose:** Provides two independent capabilities — (1) request the native in-app review dialog via `in_app_review`, and (2) launch an email feedback client via `url_launcher`. Both are wrapped behind clean architecture layers.

---

## Layer Map

```
lib/src/features/review/
├── domain/
│   ├── repositories/in_app_review_repository.dart    # abstract InAppReviewRepository
│   └── usecases/
│       ├── is_available_usecase.dart                  # IsAvailableUsecase
│       ├── request_review_usecase.dart                # RequestReviewUsecase
│       └── open_store_listing_usecase.dart            # OpenStoreListingUsecase
├── data/
│   └── repositories/in_app_review_repository.dart    # InAppReviewRepositoryImpl + provider
└── presentation/
    ├── providers/in_app_review.dart                   # inAppReviewProvider (InAppReview SDK)
    ├── config/launch_url.dart                         # canLaunchFeedback / launchFeedback
    ├── notifiers/
    │   ├── in_app_review_state_notifier.dart          # InAppReviewStateNotifier
    │   └── launch_feedback_state_notifier.dart        # LaunchFeedbackStateNotifier
```

---

## Domain

### Repository Interface
```dart
abstract class InAppReviewRepository {
  Future<void> requestReview();
  Future<bool> isAvailable();
  Future<void> openStoreListing({String? appStoreId, String? microsoftStoreId});
}
```

### Use Cases

| Class | Provider | Return | Description |
|---|---|---|---|
| `IsAvailableUsecase` | `isAvailableUsecaseProvider` | `Future<bool>` | Whether device supports in-app review |
| `RequestReviewUsecase` | `requestReviewUsecaseProvider` | `Future<void>` | Triggers native review dialog |
| `OpenStoreListingUsecase` | `openStoreListingUsecaseProvider` | `Future<void>` | Opens App Store / Play Store listing |

All providers are `Provider.autoDispose`.

---

## Data

### `InAppReviewRepositoryImpl`
**File:** `lib/src/features/review/data/repositories/in_app_review_repository.dart`

Wraps `InAppReview.instance` (from `in_app_review` package). The SDK instance is provided via `inAppReviewProvider` (`Provider<InAppReview>`).

```dart
final inAppReviewProvider = Provider<InAppReview>((ref) => InAppReview.instance);

final inAppReviewRepositoryProvider = Provider.autoDispose<InAppReviewRepository>(
  (ref) => InAppReviewRepositoryImpl(inAppReview: ref.read(inAppReviewProvider)),
);
```

---

## Presentation

### `InAppReviewStateNotifier`
**File:** `lib/src/features/review/presentation/notifiers/in_app_review_state_notifier.dart`

State: `bool` — whether in-app review is currently available.

| Method | Description |
|---|---|
| `isAvailable()` | Checks availability, updates state, returns bool |
| `requestReview({callbacks, openStoreListing})` | Checks availability → requests review or opens store listing |
| `openStoreListing({callbacks, appStoreId, microsoftStoreId})` | Opens store listing directly |

```dart
// Provider — NOT autoDispose (persists review eligibility across screens):
final inAppReviewStateNotifierProvider =
    StateNotifierProvider<InAppReviewStateNotifier, bool>(...);
```

**`requestReview()` flow:**
1. Calls `isAvailable()` → fires `isAvailableCallback(bool)`
2. If available: fires `requestReviewCallback()`, calls the review usecase
3. Re-checks availability after review (OS may disallow further requests)
4. Fires `isAvailableCallback(bool)` again with updated result

### `LaunchFeedbackStateNotifier`
**File:** `lib/src/features/review/presentation/notifiers/launch_feedback_state_notifier.dart`

State: `bool` — whether feedback email can be launched (email client available).

| Method | Description |
|---|---|
| `canLaunch({appName, emailAddress?})` | Checks if email client available, updates state |
| `launch({appName, emailAddress?})` | Checks then launches `mailto:` URL |

```dart
final launchFeedbackStateNotifierProvider =
    StateNotifierProvider<LaunchFeedbackStateNotifier, bool>(...);
```

### `launch_url.dart` — Email Feedback Helpers
**File:** `lib/src/features/review/presentation/config/launch_url.dart`

Standalone functions (no Riverpod required):

```dart
// Check if email can be launched:
Future<bool> canLaunchFeedback({required String appName, String? emailAddress})

// Launch the email client:
Future<bool> launchFeedback({required String appName, String? emailAddress})

// Email subject format:
// "My App | Version 2.1.0+42"
String generateSubject({required String appName, required PackageInfo packageInfo})
```

- `emailAddress` defaults to `FirebaseRemoteConfigCore.feedbackEmail` (from Remote Config key `feedback_email`)
- Subject auto-includes app name, version, build number via `package_info_plus`

---

## How to Use From an External App

### 1. Request in-app review

```dart
await ref.read(inAppReviewStateNotifierProvider.notifier).requestReview(
  requestReviewCallback: () {
    TapOnReviewButton().track(context: context);
  },
  isAvailableCallback: (isAvailable) {
    InAppReviewIsAvailable(isAvailable: isAvailable).track(context: context);
  },
);
```

### 2. Show review button only when available

```dart
final canReview = ref.watch(inAppReviewStateNotifierProvider);

// First, check availability on mount:
useSafeEffect(() {
  ref.read(inAppReviewStateNotifierProvider.notifier).isAvailable();
  return () {};
}, []);

if (canReview) {
  LabelRowWidget.button(
    displayDivider: true,
    title: 'Rate the App',
    description: null,
    label: null,
    displayChevronRight: true,
    onPressed: ({required context, ...}) async {
      await ref.read(inAppReviewStateNotifierProvider.notifier).requestReview(
        requestReviewCallback: () => TapOnReviewButton().track(context: context),
      );
    },
    onLongPress: null,
  )
}
```

### 3. Open store listing directly (fallback or dedicated CTA)

```dart
await ref.read(inAppReviewStateNotifierProvider.notifier).openStoreListing(
  appStoreId: '123456789', // optional override
);
```

### 4. Feedback email button

```dart
LabelRowWidget.button(
  displayDivider: false,
  title: 'Send Feedback',
  description: null,
  label: null,
  displayChevronRight: true,
  onPressed: ({required context, ...}) async {
    TapOnFeedbackButton().track(context: context);
    await ref.read(launchFeedbackStateNotifierProvider.notifier).launch(
      appName: 'My App',
      // emailAddress: 'custom@example.com', // optional override
    );
  },
  onLongPress: null,
)
```

---

## What Is Already Implemented

| Capability | Status |
|---|---|
| Native in-app review dialog | ✅ `RequestReviewUsecase` / `InAppReviewStateNotifier` |
| Review availability check | ✅ `IsAvailableUsecase` / `notifier.isAvailable()` |
| Open App Store / Play Store listing | ✅ `OpenStoreListingUsecase` |
| Email feedback with auto-subject | ✅ `LaunchFeedbackStateNotifier` / `launchFeedback()` |
| Feedback email from Remote Config | ✅ `FirebaseRemoteConfigCore.feedbackEmail` |
| Analytics events for review/feedback | ✅ `TapOnReviewButton`, `TapOnFeedbackButton`, `InAppReviewIsAvailable` |
| Custom review request timing logic | ❌ Not in package — implement in consuming app |
| Review prompt frequency limiting | ❌ OS-controlled — not configurable |

---

## Exported Symbols

```dart
export 'src/features/review/domain/repositories/in_app_review_repository.dart';
export 'src/features/review/domain/usecases/is_available_usecase.dart';
export 'src/features/review/domain/usecases/open_store_listing_usecase.dart';
export 'src/features/review/domain/usecases/request_review_usecase.dart';
export 'src/features/review/data/repositories/in_app_review_repository.dart';
export 'src/features/review/presentation/config/launch_url.dart';
export 'src/features/review/presentation/notifiers/in_app_review_state_notifier.dart';
export 'src/features/review/presentation/notifiers/launch_feedback_state_notifier.dart';
export 'src/features/review/presentation/providers/in_app_review.dart';
```
