---
name: feature-modules
description: Explains how feature modules are structured in flutter_core_modules — directory layout, domain/data/presentation layers, repository pattern, use case pattern, and how to implement a new feature module from scratch. Use when adding a new feature, understanding an existing feature module, or deciding where code belongs in the architecture.
---

# Feature Modules Architecture — flutter_core_modules

Each feature under `lib/src/features/<feature>/` follows the same three-layer clean architecture. This skill documents the exact pattern so new features are consistent.

---

## 1. Directory Layout

Every feature follows this structure:

```
lib/src/features/<feature>/
├── domain/
│   ├── repositories/
│   │   └── <feature>_repository.dart       # abstract contract
│   ├── data_sources/                        # (if needed)
│   │   └── <feature>_data_source.dart       # abstract contract
│   ├── entities/                            # (if needed)
│   │   └── <entity>.dart
│   ├── usecases/
│   │   └── <verb>_<noun>_usecase.dart       # one file per use case
│   └── failures/                            # (if not using core StorageFailure)
│       └── <feature>_failure.dart
├── data/
│   ├── repositories/
│   │   └── <feature>_repository.dart        # implementation + Riverpod provider
│   └── data_sources/                        # (if needed)
│       └── <concrete>_data_source.dart      # implementation + Riverpod provider
└── presentation/
    ├── notifiers/
    │   └── <noun>_state_notifier.dart       # SafeStateNotifier subclass + provider
    ├── setup/                               # (optional, for SDK init)
    │   └── <sdk>/
    │       └── <sdk>.dart
    ├── config/                              # (optional, for config helpers)
    │   └── <config>.dart
    ├── providers/                           # (optional, for derived providers)
    │   └── <thing>.dart
    └── widgets/                             # (optional, feature-specific widgets)
        └── <widget>.dart
```

---

## 2. Domain Layer

### 2a. Repository Interface (Abstract Contract)

The domain repository defines **what** the feature can do, with no implementation details:

```dart
// lib/src/features/locale/domain/repositories/locale_repository.dart
abstract class LocaleRepository {
  const LocaleRepository();

  Locale? getLocale();
  Future<bool> setLocale({required Locale locale});
  Future<bool> removeLocale();
}
```

Rules:
- `const` constructor
- Methods return domain types only (never `SharedPreferences`, `FirebaseAuth`, etc.)
- Return `Either<Failure, T>` for operations that can fail with a meaningful error
- Return `T?` for simple nullable reads
- Return `Future<bool>` for simple write/delete confirmations

### 2b. Use Cases

One Dart file per use case. Each use case is a callable class with a `call()` method and its own Riverpod provider:

```dart
// lib/src/features/locale/domain/usecases/set_locale_usecase.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/locale_repository.dart'; // data layer provider import
import '../repositories/locale_repository.dart';          // domain interface import

class SetLocaleUsecase {
  final LocaleRepository _repository;

  const SetLocaleUsecase({required LocaleRepository repository})
      : _repository = repository;

  Future<bool> call({required Locale locale}) => _repository.setLocale(locale: locale);
}

final setLocaleUsecaseProvider = Provider.autoDispose<SetLocaleUsecase>(
  (ref) => SetLocaleUsecase(
    repository: ref.read(localeRepositoryProvider),
  ),
);
```

Rules:
- `const` constructor
- `call()` method with named parameters matching the repository method
- `Provider.autoDispose` for all use case providers
- Import the data layer provider to resolve the repository implementation
- Import the domain interface for the type

### 2c. Failures (When Needed)

```dart
sealed class LocaleFailure {}
class UnidentifiedLocaleFailure extends LocaleFailure {}
class NotFoundLocaleFailure extends LocaleFailure {}
```

Use `StorageFailure` from core when the feature is storage-related.

---

## 3. Data Layer

### 3a. Repository Implementation

The data repository implements the domain interface. It receives dependencies via constructor injection:

```dart
// lib/src/features/locale/data/repositories/locale_repository.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/presentation/setup/shared_preferences/provider.dart';
import '../../domain/repositories/locale_repository.dart';

class LocaleRepositoryImpl extends LocaleRepository {
  final SharedPreferences _sharedPreferences;

  const LocaleRepositoryImpl({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  @override
  Locale? getLocale() => switch (_sharedPreferences.getStringList(DatabaseKeys.locale.key)) {
    null => null,
    [final languageCode, final countryCode] => Locale(languageCode, countryCode),
    [final languageCode] => Locale(languageCode),
    _ => null,
  };

  @override
  Future<bool> setLocale({required Locale locale}) {
    return _sharedPreferences.setStringList(DatabaseKeys.locale.key, [...]);
  }

  @override
  Future<bool> removeLocale() => _sharedPreferences.remove(DatabaseKeys.locale.key);
}

// Debug/prod key separation
enum DatabaseKeys {
  locale;
  String get key => switch (kDebugMode) {
    true  => '${name}Debug',
    false => name,
  };
}

// Provider in the data layer
final localeRepositoryProvider = Provider.autoDispose<LocaleRepository>(
  (ref) => LocaleRepositoryImpl(
    sharedPreferences: ref.read(sharedPreferencesProvider),
  ),
);
```

Rules:
- Always `Provider.autoDispose` for repository providers
- Debug/prod key separation using `kDebugMode` in `enum DatabaseKeys`
- The provider returns the **abstract type** (`LocaleRepository`), not the impl class
- Inject `SharedPreferences` via `sharedPreferencesProvider`

### 3b. Remote Data Source (When Needed)

For features that have both local and remote data sources:

```dart
class FirebaseStorageRemoteDataSource extends StorageRemoteDataSource {
  final FirebaseStorage _storage;
  const FirebaseStorageRemoteDataSource({required FirebaseStorage storage})
      : _storage = storage;

  @override
  Future<Either<StorageFailure, String>> getDownloadUrl({required String path}) async {
    try {
      final ref = _storage.ref(path);
      return Right(await ref.getDownloadURL());
    } catch (_) {
      return const Left(UnidentifiedStorageFailure());
    }
  }
}

final firebaseStorageRemoteDataSourceProvider =
    Provider.autoDispose<FirebaseStorageRemoteDataSource>((ref) =>
        FirebaseStorageRemoteDataSource(
          storage: ref.read(firebaseStorageProvider),
        ));
```

---

## 4. Presentation Layer

### 4a. Notifiers for Simple State (bool, Locale, ThemeData)

For settings that are read synchronously from `SharedPreferences`, extend `SafeStateNotifier<T>`:

```dart
class ThemeStateNotifier extends SafeStateNotifier<IosThemeData?> {
  ThemeStateNotifier({
    required GetThemeDataUsecase getThemeDataUsecase,
    required SetThemeDataUsecase setThemeDataUsecase,
    required RemoveThemeDataUsecase removeThemeDataUsecase,
  }) : _getThemeDataUsecase = getThemeDataUsecase,
       ...
       super(getThemeDataUsecase()); // Initial state read synchronously

  Future<bool> setThemeData({required IosThemeData iosThemeData}) async {
    final settedUp = await _setThemeDataUsecase(iosThemeData: iosThemeData);
    if (settedUp) state = iosThemeData;
    return settedUp;
  }
}

final themeStateNotifierProvider =
    StateNotifierProvider<ThemeStateNotifier, IosThemeData?>(
      (ref) => ThemeStateNotifier(
        getThemeDataUsecase: ref.read(getThemeDataUsecaseProvider),
        ...
      ),
    );
```

Note: `themeStateNotifierProvider` is **not** `autoDispose` because theme must persist across the entire app lifecycle.

### 4b. Notifiers for Async Fetch (GetStateNotifier pattern)

For features that asynchronously fetch data (Firebase Storage, API calls), extend `GetStateNotifier`:

```dart
class GetDownloadUrlStateNotifier
    extends GetStateNotifier<StorageFailure, String> {
  final String path;
  final GetDownloadUrlUsecase _getDownloadUrlUsecase;

  GetDownloadUrlStateNotifier({required this.path, ...});

  @override
  Future<Either<StorageFailure, String>> forwardedGet() =>
      _getDownloadUrlUsecase(path: path, ...);
}

// autoDispose.family for parameterized providers
final getDownloadUrlStateNotifierProvider =
    StateNotifierProvider.autoDispose.family<
        GetDownloadUrlStateNotifier,
        State<StorageFailure, String>,
        GetDownloadUrlFamilyArgs>((ref, args) {
  final notifier = GetDownloadUrlStateNotifier(...);
  WidgetsBinding.instance.addPostFrameCallback((_) => notifier.lazyGet());
  return notifier;
});
```

**Family args class:** Use a dedicated args class when provider needs multiple parameters:

```dart
class GetDownloadUrlFamilyArgs {
  final String path;
  final DateTime? invalidateCacheBefore;
  final Duration? invalidateCacheDuration;
  const GetDownloadUrlFamilyArgs({required this.path, ...});
}
```

### 4c. Notifiers for Boolean Settings (CacheBoolStateNotifier pattern)

For app settings stored as boolean in `SharedPreferences`, extend `CacheBoolStateNotifier`:

```dart
class HapticFeedbackStateNotifier extends CacheBoolStateNotifier {
  HapticFeedbackStateNotifier({
    required super.getBoolUsecase,
    required super.setBoolUsecase,
    required super.removeCacheUsecase,
    super.initialData = kDefaultHapticFeedback, // default when no saved value
  }) : super(key: hapticFeedbackKey()); // debug/prod key separation
}

final hapticFeedbackStateNotifierProvider =
    StateNotifierProvider<HapticFeedbackStateNotifier, bool>(
      (ref) => HapticFeedbackStateNotifier(
        getBoolUsecase: ref.read(getBoolUsecaseProvider),
        setBoolUsecase: ref.read(setBoolUsecaseProvider),
        removeCacheUsecase: ref.read(removeCacheUsecaseProvider),
      ),
    );
```

---

## 5. How to Implement a New Feature Module

Follow these steps in order:

**Step 1: Domain — Repository Interface**
```dart
// lib/src/features/<feature>/domain/repositories/<feature>_repository.dart
abstract class MyFeatureRepository {
  const MyFeatureRepository();
  Future<Either<MyFeatureFailure, MyEntity>> getEntity({required String id});
}
```

**Step 2: Domain — Use Cases (one per operation)**
```dart
// lib/src/features/<feature>/domain/usecases/get_entity_usecase.dart
class GetEntityUsecase {
  const GetEntityUsecase({required MyFeatureRepository repository}) : _repository = repository;
  Future<Either<MyFeatureFailure, MyEntity>> call({required String id}) =>
      _repository.getEntity(id: id);
}
final getEntityUsecaseProvider = Provider.autoDispose<GetEntityUsecase>(
  (ref) => GetEntityUsecase(repository: ref.read(myFeatureRepositoryProvider)),
);
```

**Step 3: Data — Repository Implementation + Provider**
```dart
// lib/src/features/<feature>/data/repositories/<feature>_repository.dart
class MyFeatureRepositoryImpl extends MyFeatureRepository {
  const MyFeatureRepositoryImpl({...});
  @override
  Future<Either<MyFeatureFailure, MyEntity>> getEntity({required String id}) async {
    try {
      // fetch logic
      return Right(entity);
    } catch (_) {
      return const Left(UnidentifiedMyFeatureFailure());
    }
  }
}
final myFeatureRepositoryProvider = Provider.autoDispose<MyFeatureRepository>(
  (ref) => MyFeatureRepositoryImpl(...),
);
```

**Step 4: Presentation — Notifier**

Choose the right base class:
- `GetStateNotifier` → async fetch with `State<F, S>` lifecycle
- `CacheBoolStateNotifier` → boolean SharedPreferences setting
- `SafeStateNotifier` → anything else

**Step 5: Export from `lib/flutter_core_modules.dart`**

Add all public files to the barrel export file.

---

## 6. Existing Features Quick Reference

| Feature | Domain | Data Implementation | Presentation |
|---|---|---|---|
| `analytics` | `AnalyticsRepository` (track events) | `AnalyticsRepositoryImpl` (Amplitude, Firebase, Mixpanel, Posthog, Statsig) | No notifier — events tracked directly via `EventEntity.track(context)` |
| `locale` | `LocaleRepository` | `LocaleRepositoryImpl` (SharedPreferences) | No dedicated notifier — use usecases directly |
| `revenue` | `RevenueRepository` (RevenueCat) | `RevenueRepositoryImpl` (Purchases SDK) | `CustomerInfoStateNotifier` (paywall + subscription state) |
| `review` | `InAppReviewRepository` | `InAppReviewRepositoryImpl` (in_app_review) | `InAppReviewStateNotifier`, `LaunchFeedbackStateNotifier` |
| `route` | None | None | `ShellRouteWidget`, `NavigationTab`, `navigatiorKeyProvider`, `defaultNavigatorObservers` |
| `settings` | None | None | `HapticFeedbackStateNotifier`, `WakelockStateNotifier`, `SwitchRowWidget`, `CacheBoolRowWidget`, `ThemeRowWidget` |
| `storage` | `StorageRepository`, `StorageRemoteDataSource`, `CacheLocalDataSource` | `FirebaseStorageRepository`, `FirebaseStorageRemoteDataSource`, `SharedPreferencesCacheLocalDataSource` | `GetDownloadUrlStateNotifier`, `GetJsonStateNotifier`, `ImageNetworkFromStorageWidget`, `SvgFromStorageWidget` |
| `theme` | `ThemeRepository` | `ThemeRepositoryImpl` (SharedPreferences) | `ThemeStateNotifier` |

---

## 7. Critical Naming Conventions

- Repository interfaces: `abstract class FooRepository`
- Repository implementations: `class FooRepositoryImpl extends FooRepository`
- Use cases: `class VerbNounUsecase` → `GetLocaleUsecase`, `SetThemeDataUsecase`, `TrackEventUsecase`
- Notifiers: `class NounStateNotifier extends [Base]`
- Providers: `fooRepositoryProvider`, `getFooUsecaseProvider`, `fooStateNotifierProvider`
- Family args: `FooFamilyArgs` class with `const` constructor
- Debug keys: Always suffix with `Debug` when `kDebugMode == true`
