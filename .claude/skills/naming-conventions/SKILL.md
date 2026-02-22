---
name: naming-conventions
description: All naming conventions used in flutter_core_modules — files, classes, providers, use cases, notifiers, widgets, hooks, failures, events, constants, family args, cache keys, abstract vs implementation classes, and directory structure. Use when creating any new file or symbol, or when verifying whether a name follows project conventions.
---

# Naming Conventions — flutter_core_modules

All conventions below are derived directly from the existing codebase. Every new file or symbol must follow these patterns.

---

## 1. Files — `snake_case` with Semantic Suffix

| Suffix | Contents | Examples |
|---|---|---|
| `*_usecase.dart` | Domain use case class | `get_theme_data_usecase.dart`, `sync_purchases_usecase.dart` |
| `*_state_notifier.dart` | StateNotifier class | `theme_state_notifier.dart`, `haptic_feedback_state_notifier.dart` |
| `*_repository.dart` | Repository abstract or impl | `theme_repository.dart` (both layers, in separate dirs) |
| `*_data_source.dart` | DataSource abstract or impl | `firebase_storage_remote_data_source.dart` |
| `*_widget.dart` | Widget class | `label_row_widget.dart`, `switch_row_widget.dart` |
| `*_failure.dart` | Failure sealed class | `storage_failure.dart` |
| (no suffix) | Hooks, utils, config | `safe_effect.dart`, `debounce.dart`, `revenue_cat.dart` |

---

## 2. Classes — `PascalCase` with Semantic Suffix

### Use Cases
Pattern: `{Verb}{Entity}Usecase`

| Verb | Examples |
|---|---|
| `Get` | `GetThemeDataUsecase`, `GetLocaleUsecase`, `GetCustomerInfoUsecase`, `GetDownloadUrlUsecase`, `GetJsonUsecase`, `GetAppUserIdUsecase` |
| `Set` | `SetThemeDataUsecase`, `SetLocaleUsecase` |
| `Remove` | `RemoveThemeDataUsecase`, `RemoveLocaleUsecase`, `RemoveCustomerInfoUpdateListenerUsecase` |
| `Sync` | `SyncPurchasesUsecase` |
| `Invalidate` | `InvalidateCustomerInfoCacheUsecase` |
| `Add` | `AddCustomerInfoUpdateListenerUsecase` |
| `Track` | `TrackEventUsecase` |
| `Is` | `IsAvailableUsecase` |
| `Request` | `RequestReviewUsecase` |
| `Open` | `OpenStoreListingUsecase` |

### State Notifiers
Pattern: `{Feature}StateNotifier`

```
ThemeStateNotifier
HapticFeedbackStateNotifier
WakelockStateNotifier
CustomerInfoStateNotifier
GetDownloadUrlStateNotifier
GetJsonStateNotifier
InAppReviewStateNotifier
LaunchFeedbackStateNotifier
```

### Repositories
Pattern: abstract = `{Feature}Repository`, concrete = `{Technology}{Feature}Repository` or `{Feature}RepositoryImpl`

```
// Abstract:
ThemeRepository
LocaleRepository
RevenueRepository
StorageRepository
InAppReviewRepository

// Concrete:
ThemeRepositoryImpl        // impl suffix when no technology prefix
LocaleRepositoryImpl
RevenueRepositoryImpl
FirebaseStorageRepository  // technology prefix when meaningful
```

### Data Sources
Pattern: abstract = `{Domain}DataSource`, concrete = `{Technology}{Domain}DataSource`

```
// Abstract:
StorageRemoteDataSource
CacheLocalDataSource

// Concrete:
FirebaseStorageRemoteDataSource
SharedPreferencesCacheLocalDataSource
```

### Widgets
Pattern: `{Descriptor}Widget` or `{Descriptor}RowWidget`

```
LabelRowWidget
ThemeRowWidget
SwitchRowWidget
CacheBoolRowWidget
ImageNetworkFromStorageWidget
SvgFromStorageWidget
ErrorIndicatorWidget
NextButtonWidget
ShellRouteWidget
WebViewModalSheetWidget
TitleGroupedTableWidget
```

### Failures
Pattern: `{Specific}Failure` extending a sealed base class

```
StorageFailure             // sealed base
UnidentifiedStorageFailure
EmptyCacheStorageFailure
```

### Analytics Events
Three sub-patterns by event type:

| Type | Pattern | Examples |
|---|---|---|
| UI tap | `TapOn{Target}` | `TapOnDarkModeSettings`, `TapOnReviewButton`, `TapOnGetPremiumButton`, `TapOnFeedbackButton`, `TapOnCopyToClipboard` |
| Action/state change | `{Action}{Entity}` | `ChangeLanguageTo`, `InAppReviewIsAvailable`, `InitApp` |
| SDK callback | `On{Event}Callback` | `OnHasActiveSubscriptionCallback`, `OnPresentedPaywallCallback`, `OnSyncPurchasesCallback`, `OnPresentPaywallResultCallback` |

### Base Classes (Abstract)
No suffix — they are the canonical name:
```
SafeStateNotifier<T>
GetStateNotifier<F, E>
CacheBoolStateNotifier
EventEntity
NavigationTab
CacheKey
```

### Family Args
Pattern: `{Feature}FamilyArgs`

```
GetDownloadUrlFamilyArgs
GetJsonFamilyArgs
```

### Cache Keys
Pattern: `{Domain}CacheKey`

```
UrlCacheKey
JsonCacheKey
```

---

## 3. Providers — `camelCase` with `Provider` suffix

Pattern: `{feature}{Purpose}Provider`

### Use case providers
```dart
getThemeDataUsecaseProvider
setThemeDataUsecaseProvider
removeThemeDataUsecaseProvider
getLocaleUsecaseProvider
setLocaleUsecaseProvider
getDownloadUrlUsecaseProvider
getJsonUsecaseProvider
getCustomerInfoUsecaseProvider
syncPurchasesUsecaseProvider
trackEventUsecaseProvider
isAvailableUsecaseProvider
```

### Notifier providers
```dart
themeStateNotifierProvider
hapticFeedbackStateNotifierProvider
wakelockStateNotifierProvider
customerInfoStateNotifierProvider
getDownloadUrlStateNotifierProvider   // family
getJsonStateNotifierProvider          // family
inAppReviewStateNotifierProvider
launchFeedbackStateNotifierProvider
```

### Repository providers
```dart
themeRepositoryProvider
localeRepositoryProvider
revenueRepositoryProvider
firebaseStorageRepositoryProvider
inAppReviewRepositoryProvider
```

### Data source providers
```dart
firebaseStorageRemoteDataSourceProvider
sharedPreferencesCacheLocalDataSourceProvider
```

### Derived / computed providers
```dart
isPremiumCustomerProvider    // Provider<bool> derived from customerInfoStateNotifierProvider
navigatiorKeyProvider        // family, one GlobalKey per NavigationTab
sharedPreferencesProvider    // provides SharedPreferences singleton
```

---

## 4. Hooks — `use` prefix, `camelCase`

Pattern: `use{Feature}`

```dart
useSafeEffect()                   // runs effect after first frame
useDebounce()                     // debounced value
useInterval() / useSafeInterval() // repeating timer
useFixedExtentScrollController()  // scroll controller hook
```

---

## 5. Constants — `k` prefix, `PascalCase` body

```dart
const kDefaultHapticFeedback = true;
const kDefaultWakelock = true;
const kEnableBackdropImageFilter = true;
const kDisableOpacity = .5;
```

Private key base strings use a private `_key` local constant:
```dart
const _key = 'hapticFeedback';
String hapticFeedbackKey() => kDebugMode ? '${_key}Debug' : _key;
```

---

## 6. SharedPreferences Keys — Function-based with Debug Suffix

For any setting persisted to `SharedPreferences`, use a function that appends `Debug` in debug mode:

```dart
const _key = 'myFeature';
String myFeatureKey() => kDebugMode ? '${_key}Debug' : _key;
```

**Never** hardcode the debug-variant key as a literal — always generate it via a function.

---

## 7. Directory Structure per Feature

```
lib/src/features/{feature_name}/
├── domain/
│   ├── repositories/       # abstract interface only
│   ├── data_sources/       # abstract interface (if needed)
│   ├── entities/           # domain models
│   ├── failures/           # sealed failure classes (if needed)
│   └── usecases/           # one file per use case
├── data/
│   ├── repositories/       # concrete implementations
│   └── data_sources/       # concrete implementations (if needed)
└── presentation/
    ├── notifiers/          # StateNotifier subclasses
    ├── widgets/            # Widget classes
    ├── hooks/              # feature-specific hooks (if needed)
    ├── providers/          # simple Provider (not StateNotifier)
    ├── config/             # initialization / SDK setup code
    └── utils/              # stateless helpers
```

Features with no domain/data layers (presentation-only):
```
lib/src/features/route/
lib/src/features/settings/
```

---

## 8. Quick Reference — New Symbol Checklist

When adding a new symbol, confirm:

1. **File**: `snake_case`, correct suffix (`_usecase`, `_state_notifier`, `_repository`, `_widget`, `_data_source`)
2. **Class**: `PascalCase`, suffix matches type (`Usecase`, `StateNotifier`, `Repository`, `Widget`, `Failure`)
3. **Use case**: verb-first (`Get`, `Set`, `Remove`, `Add`, `Remove`, `Sync`, `Track`, `Is`, `Request`, `Open`)
4. **Provider**: matches class name lowercased first letter + `Provider` suffix
5. **Analytics event**: `TapOn*` for taps, `On*Callback` for SDK callbacks, descriptive verb-noun otherwise
6. **Hook**: starts with `use`
7. **Constant**: starts with `k`
8. **SharedPreferences key**: function that appends `Debug` suffix in `kDebugMode`
9. **File location**: domain → data → presentation layer order; correct sub-directory within each
