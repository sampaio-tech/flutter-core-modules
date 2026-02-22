---
name: core-architecture
description: Explains the core architecture of flutter_core_modules — Either, State sealed classes, SafeStateNotifier, GetStateNotifier, CacheBoolStateNotifier, setup providers (SharedPreferences, HTTP, dotenv), hooks, and shared widgets. Use when understanding or extending the core layer, implementing state machines, or setting up app infrastructure.
---

# Core Architecture — flutter_core_modules

This package is a shared Flutter library providing clean-architecture foundations consumed by multiple apps. It lives at `lib/src/core/` and everything here is re-exported via `lib/flutter_core_modules.dart`.

---

## 1. Either — Functional Error Handling

**File:** `lib/src/core/domain/utils/either.dart`

A custom `sealed class Either<L, R>` (no external dependency) inspired by Scala/dartz:

```dart
sealed class Either<L, R> {
  T fold<T>(T Function(L) fa, T Function(R) fb);
}
class Right<L, R> extends Either<L, R> { R get value; }
class Left<L, R>  extends Either<L, R> { L get value; }
```

**Convention:** `L` is always the **Failure** type, `R` is the **success** value.

All use cases and repositories that can fail return `Future<Either<Failure, Entity>>`. Never throw exceptions across layer boundaries — wrap them in `Left`.

```dart
// Correct pattern in a use case:
Future<Either<StorageFailure, String>> call(...) =>
    _repository.getDownloadUrl(...);

// Consuming in a notifier:
final failureOrSuccess = await forwardedGet();
state = failureOrSuccess.fold(
  LoadFailureState.new,
  LoadSuccessState.new,
);
```

---

## 2. State — Sealed State Machine

**File:** `lib/src/core/presentation/notifiers/state.dart`

```dart
sealed class State<F, S> {}
class StartedState<F, S>      extends State<F, S> {}  // initial, no data
class LoadInProgressState<F, S> extends State<F, S> {} // loading, optional prev data
class LoadSuccessState<F, S>  extends State<F, S> { S get value; }
class LoadFailureState<F, S>  extends State<F, S> { F get value; }
```

- `F` = Failure type (e.g., `StorageFailure`)
- `S` = Success type (e.g., `String`, `CustomerInfo`)
- `LoadInProgressState` optionally carries previous `f`/`s` for "loading with previous data" UX patterns.

**Pattern-matching in UI:**

```dart
switch (state) {
  StartedState()                          => const SizedBox.shrink(),
  LoadInProgressState()                   => const CircularProgressIndicator(),
  LoadSuccessState(value: final url)      => Image.network(url),
  LoadFailureState()                      => ErrorIndicatorWidget(...),
}
```

---

## 3. SafeStateNotifier

**File:** `lib/src/core/presentation/notifiers/safe_state_notifier.dart`

All notifiers in this package extend `SafeStateNotifier<T>` instead of `StateNotifier<T>` directly:

```dart
class SafeStateNotifier<T> extends StateNotifier<T> {
  @override
  set state(T value) {
    if (mounted) super.state = value;
  }
}
```

**Why:** Prevents `setState called after dispose` crashes when async operations complete after the widget tree disposes the provider. **Every notifier in this codebase extends this**.

---

## 4. GetStateNotifier — Async Fetch Pattern

**File:** `lib/src/core/presentation/notifiers/get_state_notifier.dart`

Abstract base for notifiers that fetch remote/async data once and cache as `State<F, S>`:

```dart
abstract class GetStateNotifier<Failure, Entity>
    extends SafeStateNotifier<State<Failure, Entity>> {

  // Only fetches if in Started or Failure state (idempotent lazy fetch)
  Future<void> lazyGet();

  // Always fetches: sets LoadInProgress → runs forwardedGet() → sets result
  Future<Either<Failure, Entity>> get();

  // Subclasses implement this with the actual use case call
  Future<Either<Failure, Entity>> forwardedGet();
}
```

**Concrete example** from `GetDownloadUrlStateNotifier`:
```dart
class GetDownloadUrlStateNotifier
    extends GetStateNotifier<StorageFailure, String> {

  @override
  Future<Either<StorageFailure, String>> forwardedGet() =>
      _getDownloadUrlUsecase(
        path: path,
        invalidateCacheBefore: invalidateCacheBefore,
        invalidateCacheDuration: invalidateCacheDuration,
      );
}
```

The provider calls `lazyGet()` via `addPostFrameCallback` so the first frame renders with `StartedState` before the fetch begins:

```dart
final myProvider = StateNotifierProvider.autoDispose.family<...>((ref, args) {
  final notifier = MyStateNotifier(...);
  WidgetsBinding.instance.addPostFrameCallback((_) => notifier.lazyGet());
  return notifier;
});
```

---

## 5. CacheBoolStateNotifier — Persisted Boolean Settings

**File:** `lib/src/core/presentation/notifiers/cache_bool_state_notifier.dart`

Abstract base for boolean settings that auto-persist to `SharedPreferences`:

```dart
abstract class CacheBoolStateNotifier extends SafeStateNotifier<bool> {
  // Reads current value from SharedPreferences on construction
  CacheBoolStateNotifier({
    required bool initialData,
    required String key,
    required GetBoolUsecase getBoolUsecase,
    required SetBoolUsecase setBoolUsecase,
    required RemoveCacheUsecase removeCacheUsecase,
  });

  bool? get();           // reads from SharedPreferences, updates state
  Future<bool> set({required bool value}); // writes to SharedPreferences, updates state
  Future<bool> remove(); // removes from SharedPreferences
}
```

**Usage** — extend and provide a key:

```dart
class HapticFeedbackStateNotifier extends CacheBoolStateNotifier {
  HapticFeedbackStateNotifier({...})
      : super(key: hapticFeedbackKey(), initialData: true, ...);
}
```

Keys always use `kDebugMode` suffix to avoid polluting production data during development:

```dart
String hapticFeedbackKey() => switch (kDebugMode) {
  true  => '${_key}Debug',
  false => _key,
};
```

---

## 6. Setup — SharedPreferences

**File:** `lib/src/core/presentation/setup/shared_preferences/provider.dart`

`SharedPreferences` is a singleton accessed via a static instance pattern:

```dart
final class SharedPreferencesInstance {
  static SharedPreferences? _sharedPreferences;
  static Future<SharedPreferences> getInstanceSharedPreferences() => ...;
  static SharedPreferences get getSharedPreferences => _sharedPreferences!;
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => SharedPreferencesInstance.getSharedPreferences,
);
```

**App initialization requirement:** Call `SharedPreferencesInstance.getInstanceSharedPreferences()` in `main()` before `runApp()`.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesInstance.getInstanceSharedPreferences();
  runApp(ProviderScope(child: MyApp()));
}
```

---

## 7. Setup — HTTP Clients

**File:** `lib/src/core/presentation/setup/http/provider.dart`

Three pre-configured HTTP clients as Riverpod providers:

| Provider | Class | Use case |
|---|---|---|
| `httpClientProvider` | `HttpClient` | JSON APIs — adds `Content-Type: application/json` + `Connection: close` |
| `defaultHttpClientProvider` | `DefaultClient` | Generic requests — adds `Content-Type: application/json` |
| `firebaseStorageClientProvider` | `FirebaseStorageClient` | Firebase Storage — no extra headers |

All extend `BaseClient` and auto-close via `ref.onDispose`.

**Also:** `CertificateHttpOverrides` in `overrides.dart` bypasses SSL certificate validation — useful for development proxies. Set it with `HttpOverrides.global = CertificateHttpOverrides()` in `main()` when needed.

---

## 8. Setup — DotEnv

**File:** `lib/src/core/presentation/setup/dot_env/dot_env.dart`

Centralizes all `.env` key access. Reads from a `.env` file using `flutter_dotenv`:

```dart
class DotEnv {
  static Future<void> load() => dotenv.load();
  static bool enableAnalytics = !kDebugMode; // analytics disabled in debug
  static bool enableClarity   = !kDebugMode;
  static String? getAmplitudeToken()           => dotenv.maybeGet('AMPLITUDE_TOKEN');
  static String? getMixpanelToken()            => dotenv.maybeGet('MIXPANEL_TOKEN');
  static String? getRevenueCatProjectAppleApiKey() => ...;
  // etc.

  // Master init: loads .env, then initializes all analytics + RevenueCat
  static Future<void> init(FirebaseRemoteConfig firebaseRemoteConfig) async {
    await load();
    await Future.wait([
      if (enableAnalytics) StatsigConfig.init(),
      if (enableAnalytics) MixpanelConfig.init(),
      if (enableAnalytics) AmplitudeConfig.init(),
      if (enableAnalytics) FirebaseAnalyticsConfig.init(),
      if (enableAnalytics) PosthogConfig.init(),
      initPlatformState(), // RevenueCat
    ]);
  }
}
```

**Keys in `.env`:**
- `STATSIG_CLIENT_SDK_KEY`
- `MIXPANEL_TOKEN`
- `POSTHOG_TOKEN`
- `AMPLITUDE_TOKEN`
- `CLARITY_PROJECT_ID`
- `REVENUECAT_PROJECT_APPLE_API_KEY`
- `REVENUECAT_PROJECT_GOOGLE_API_KEY`

---

## 9. CacheLocalDataSource — Caching Infrastructure

**File:** `lib/src/core/domain/data_sources/cache_local_data_source.dart`

Abstract data source for the **two-layer cache** pattern (remote + local fallback):

```dart
abstract class CacheLocalDataSource {
  Future<String?> getDownloadUrl({required String path});
  Future<bool>    setDownloadUrl({required String path, required String? value});
  Future<dynamic> getJson({required String path});
  Future<bool>    setJson({required String path, required dynamic value});
  Future<DateTime?> getSavedAt({required CacheKey key, required String path});
  Future<bool>    setSavedAt({required CacheKey key, required String path});
  Future<bool>    invalidateCacheRule({...}); // built-in logic
}
```

**CacheKey** (`lib/src/core/domain/entities/cache_key.dart`): Abstract key type that appends `_debug` in debug mode:

```dart
abstract class CacheKey {
  String get key;         // e.g. 'url' or 'url_debug'
  String keyByPath(String path); // e.g. 'url/images/logo.png'
  String savedAt(String path);   // e.g. 'url/images/logo.png_saved_at'
}
class UrlCacheKey  extends CacheKey { const UrlCacheKey()  : super(name: 'url'); }
class JsonCacheKey extends CacheKey { const JsonCacheKey() : super(name: 'json'); }
```

The concrete implementation is `SharedPreferencesCacheLocalDataSource` (uses JSON-encoded strings for arbitrary data).

---

## 10. forwardedCachedGet — Cache-or-Fetch Helper

**File:** `lib/src/core/domain/utils/fowarded_cache_functions.dart`

Two utility functions that implement the "check cache → fetch remote → store cache → fallback to cache" logic:

```dart
// Generic cache-or-fetch
Future<Either<F, T>> forwardedCachedGet<F, T>({
  required String path,
  required CacheKey key,
  required DateTime? invalidateCacheBefore,  // invalidate before this date
  required Duration? invalidateCacheDuration, // max age
  required Future<Either<F, T>> Function({required String path}) getFromRemote,
  required Future<T?> Function({required String path}) getFromLocal,
  required Future<bool> Function({required String path, required T? value}) setLocal,
  required Future<bool> Function({required CacheKey key, required String path}) setSavedAtLocal,
  required F emptyCacheFailure,
  required F unidentifiedFailure,
  required CacheLocalDataSource localDataSource,
});

// HTTP-specific variant (parses JSON, handles status codes)
Future<Either<F, T>> forwardedCachedHttpRequest<F, T>({...});
```

**Logic flow:** `invalidateCacheRule()` → if stale: fetch remote → store → return Right; if fresh: return from local; if local empty: return `emptyCacheFailure`.

---

## 11. Core Hooks

**Files:** `lib/src/core/presentation/hooks/`

| Hook | Signature | Purpose |
|---|---|---|
| `useDebounce` | `ValueChanged<VoidCallback> useDebounce(Duration)` | Returns a debounced callback runner. Cancels timer on rebuild/dispose. |
| `useSafeEffect` | `void useSafeEffect(effect, keys)` | Runs effect after first frame via `addPostFrameCallback`. Prevents effects on initial frame. |
| `useInterval` | `void useInterval(VoidCallback, Duration)` | Periodic timer tied to hook lifecycle. |
| `useSafeInterval` | `void useSafeInterval(VoidCallback, Duration)` | Same but deferred to first frame. |
| `useFixedExtentScrollController` | `FixedExtentScrollController useFixedExtentScrollController({int initialItem})` | Lifecycle-managed `FixedExtentScrollController`. |

---

## 12. Core Shared Widgets

| Widget | Purpose |
|---|---|
| `LabelRowWidget` | iOS-style list row with title/description/label/chevron. Multiple factory constructors: `.link()`, `.button()`, `.blueButton()`, `.orangeButton()`, `.redButton()`. Integrates haptic feedback + analytics tracking. |
| `ErrorIndicatorWidget` | Error state with retry button. Supports horizontal and vertical axis. |
| `CheckInternetErrorIndicatorWidget` | Semantic wrapper around `ErrorIndicatorWidget` for connectivity errors. |
| `NextButtonWidget` | Blue large `ButtonWidget.label` from `ios_design_system`. |
| `TitleGroupedTableWidget` | Section header for grouped tables. Supports large/small variant. |
| `WebViewModalSheetWidget` | Cupertino modal sheet with embedded WebView. |
| `MultiSliver` | Allows multiple slivers to be wrapped in a single widget. |

---

## Failure Types

**File:** `lib/src/core/domain/failures/storage_failure.dart`

```dart
sealed class StorageFailure {}
class UnidentifiedStorageFailure extends StorageFailure {} // unexpected error
class EmptyCacheStorageFailure   extends StorageFailure {} // cache miss, no remote data
```

Feature-specific failures follow this sealed class pattern. Define a `sealed class XFailure` per feature domain when needed.

---

## Constants

**File:** `lib/src/core/presentation/setup/constants.dart`

```dart
const kEnableBackdropImageFilter = true;
const kDisableOpacity = .5;
```

---

## Key Architectural Rules for the Core Layer

1. **Domain layer** (`domain/`) has **zero Flutter or third-party imports** — only Dart SDK.
2. **Data layer** (`data/`) implements domain abstractions. May import third-party packages.
3. **Presentation layer** (`presentation/`) is the only layer that imports Flutter + Riverpod.
4. **Failures** are sealed classes. Never use raw `Exception` or `String` as error types.
5. **Providers** follow the naming pattern: `myThingProvider` (not global variables).
6. **`autoDispose`** on all providers that don't need to persist globally (use cases, repositories).
7. **Global providers** (non-autoDispose): `sharedPreferencesProvider`, `themeStateNotifierProvider`, `customerInfoStateNotifierProvider`, `hapticFeedbackStateNotifierProvider`, `wakelockStateNotifierProvider`.
