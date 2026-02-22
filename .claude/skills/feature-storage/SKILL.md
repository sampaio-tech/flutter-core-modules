---
name: feature-storage
description: Everything about the storage feature in flutter_core_modules — Firebase Storage integration, transparent local caching via SharedPreferences, GetDownloadUrlStateNotifier, GetJsonStateNotifier, ImageNetworkFromStorageWidget, SvgFromStorageWidget, and cache invalidation strategies. Use when loading images or JSON from Firebase Storage, asking whether storage/caching is already implemented, or understanding cache invalidation.
---

# Feature: Storage

**Purpose:** Fetch files from Firebase Storage with automatic transparent caching in `SharedPreferences`. Provides two notifiers and two widgets that handle the full fetch → cache → display lifecycle, including configurable cache invalidation by date or duration.

---

## Layer Map

```
lib/src/features/storage/
├── domain/
│   ├── repositories/storage_repository.dart           # abstract StorageRepository (with built-in cache logic)
│   ├── data_sources/storage_remote_data_source.dart   # abstract StorageRemoteDataSource
│   └── usecases/
│       ├── get_download_url_usecase.dart               # GetDownloadUrlUsecase + provider
│       └── get_json_usecase.dart                       # GetJsonUsecase + provider
├── data/
│   ├── repositories/firebase_storage_repository.dart  # FirebaseStorageRepository + provider
│   └── data_sources/
│       └── firebase_storage_remote_data_source.dart   # FirebaseStorageRemoteDataSource + provider
└── presentation/
    ├── notifiers/
    │   ├── get_download_url_state_notifier.dart        # GetDownloadUrlStateNotifier + provider
    │   └── get_json_state_notifier.dart                # GetJsonStateNotifier + provider
    └── widgets/
        ├── image_network_from_storage_widget.dart      # ImageNetworkFromStorageWidget
        └── svg_from_storage_widget.dart                # SvgFromStorageWidget
```

---

## Domain

### `StorageRepository` — Abstract With Built-In Cache Logic
**File:** `lib/src/features/storage/domain/repositories/storage_repository.dart`

Unlike other repositories, `StorageRepository` is **abstract but not empty** — it contains the full cache-or-fetch logic directly using `forwardedCachedGet`:

```dart
abstract class StorageRepository {
  final CacheLocalDataSource localDataSource;
  final StorageRemoteDataSource remoteDataSource;

  Future<Either<StorageFailure, String>> getDownloadUrl({
    required String path,
    required DateTime? invalidateCacheBefore,
    required Duration? invalidateCacheDuration,
  }) => forwardedCachedGet<StorageFailure, String>(
    path: path,
    key: const UrlCacheKey(),         // SharedPreferences key prefix: 'url'
    getFromRemote: remoteDataSource.getDownloadUrl,
    getFromLocal: localDataSource.getDownloadUrl,
    setLocal: localDataSource.setDownloadUrl,
    setSavedAtLocal: localDataSource.setSavedAt,
    emptyCacheFailure: const EmptyCacheStorageFailure(),
    unidentifiedFailure: const UnidentifiedStorageFailure(),
    localDataSource: localDataSource,
    ...
  );

  Future<Either<StorageFailure, dynamic>> getJson({...}) => forwardedCachedGet<...>(
    key: const JsonCacheKey(),         // SharedPreferences key prefix: 'json'
    ...
  );
}
```

Subclasses only need to inject the concrete `localDataSource` and `remoteDataSource`.

### `StorageRemoteDataSource`
```dart
abstract class StorageRemoteDataSource {
  Future<Either<StorageFailure, String>> getDownloadUrl({required String path});
  Future<Either<StorageFailure, dynamic>> getJson({required String path});
}
```

### Use Cases

| Class | Provider | Signature |
|---|---|---|
| `GetDownloadUrlUsecase` | `getDownloadUrlUsecaseProvider` | `Future<Either<StorageFailure, String>> call({required String path, DateTime? invalidateCacheBefore, Duration? invalidateCacheDuration})` |
| `GetJsonUsecase` | `getJsonUsecaseProvider` | `Future<Either<StorageFailure, dynamic>> call({...})` |

Both providers are `Provider.autoDispose` and resolve `firebaseStorageRepositoryProvider`.

---

## Data

### `FirebaseStorageRemoteDataSource`
**File:** `lib/src/features/storage/data/data_sources/firebase_storage_remote_data_source.dart`

- `getDownloadUrl`: calls `FirebaseStorage.ref(path).getDownloadURL()`
- `getJson`: gets the download URL, then performs an HTTP GET via `FirebaseStorageClient` (no extra headers), parses JSON body

Uses `firebaseStorageClientProvider` (the bare `FirebaseStorageClient` with no added headers).

### `FirebaseStorageRepository`
**File:** `lib/src/features/storage/data/repositories/firebase_storage_repository.dart`

Minimal — just injects `SharedPreferencesCacheLocalDataSource` and `FirebaseStorageRemoteDataSource` into `StorageRepository`.

```dart
final firebaseStorageRepositoryProvider = Provider.autoDispose<StorageRepository>(
  (ref) => FirebaseStorageRepository(
    localDataSource: ref.read(sharedPreferencesCacheLocalDataSourceProvider),
    remoteDataSource: ref.read(firebaseStorageRemoteDataSourceProvider),
  ),
);
```

---

## Cache Invalidation Strategy

Two optional parameters on every fetch:

| Parameter | Behavior |
|---|---|
| `invalidateCacheBefore: DateTime` | Cache is stale if it was saved **before** this date |
| `invalidateCacheDuration: Duration` | Cache is stale if saved more than this duration ago |
| Both `null` | Cache is only invalidated if it doesn't exist yet |

The `invalidateCacheRule()` in `CacheLocalDataSource` returns `true` (= fetch fresh) when:
- `cacheUpdatedAt == null` (cache miss — never saved)
- `invalidateCacheBefore != null && cacheUpdatedAt.isBefore(invalidateCacheBefore)` (before cutoff date)
- `invalidateCacheDuration != null && cacheUpdatedAt.add(duration).isBefore(DateTime.now())` (expired TTL)

---

## Presentation

### `GetDownloadUrlStateNotifier` + Provider
**File:** `lib/src/features/storage/presentation/notifiers/get_download_url_state_notifier.dart`

State: `State<StorageFailure, String>` (sealed class lifecycle)

```dart
// Family args:
class GetDownloadUrlFamilyArgs {
  final String path;
  final DateTime? invalidateCacheBefore;
  final Duration? invalidateCacheDuration;
}

// Provider (autoDispose.family):
final getDownloadUrlStateNotifierProvider =
    StateNotifierProvider.autoDispose.family<
        GetDownloadUrlStateNotifier,
        State<StorageFailure, String>,
        GetDownloadUrlFamilyArgs>(...);
```

Calls `notifier.lazyGet()` via `addPostFrameCallback` on provider creation — fetch starts after first frame.

### `GetJsonStateNotifier` + Provider
Same pattern as `GetDownloadUrlStateNotifier` but for `State<StorageFailure, dynamic>`.

```dart
final getJsonStateNotifierProvider =
    StateNotifierProvider.autoDispose.family<
        GetJsonStateNotifier,
        State<StorageFailure, dynamic>,
        GetJsonFamilyArgs>(...);
```

---

## Widgets

### `ImageNetworkFromStorageWidget`

```dart
ImageNetworkFromStorageWidget({
  required String path,              // Firebase Storage path (e.g. 'images/logo.png')
  BoxFit fit = BoxFit.cover,
  Alignment alignment = Alignment.center,
  Color? color,
  double? width,
  double? height,
  DateTime? invalidateCacheBefore,
  Duration? invalidateCacheDuration,
  bool enableImageCache = true,      // true = CachedNetworkImage, false = Image.network
  Widget? progressIndicatorWidget,
  Widget? errorWidget,
  Duration fadeDuration = Duration(milliseconds: 300),
  Duration animationDuration = Duration.zero,
})
```

- Wraps `getDownloadUrlStateNotifierProvider` internally
- Uses `AnimatedSwitcher` + `FadeTransition` for smooth transitions
- `enableImageCache: true` → `CachedNetworkImage` (cached to disk)
- `enableImageCache: false` → `Image.network` (no disk cache)
- `animationDuration > Duration.zero` → disables `fadeDuration` on image to avoid double-fade

### `SvgFromStorageWidget`

Same interface as `ImageNetworkFromStorageWidget` but for SVG files:
- `enableSvgCache: true` → `CachedNetworkSVGImage`
- `enableSvgCache: false` → `SvgPicture.network`
- `color` maps to a `ColorFilter.mode(color, BlendMode.srcIn)`
- Default `fit: BoxFit.contain` (unlike image widget which uses `BoxFit.cover`)

---

## How to Use From an External App

### 1. Display an image from Firebase Storage

```dart
// Auto-cached, refreshes every 7 days:
ImageNetworkFromStorageWidget(
  path: 'images/user_avatar.png',
  width: 48,
  height: 48,
  fit: BoxFit.cover,
  invalidateCacheDuration: const Duration(days: 7),
  progressIndicatorWidget: const CupertinoActivityIndicator(),
  errorWidget: const Icon(CupertinoIcons.person_circle),
)
```

### 2. Display an SVG icon from Firebase Storage

```dart
SvgFromStorageWidget(
  path: 'icons/category_sport.svg',
  width: 24,
  height: 24,
  color: IosTheme.of(context).defaultLabelColors.primary,
  invalidateCacheDuration: const Duration(days: 30),
)
```

### 3. Force refresh after content update

```dart
// Invalidate everything saved before a specific deploy date:
ImageNetworkFromStorageWidget(
  path: 'images/hero_banner.png',
  invalidateCacheBefore: DateTime(2025, 6, 1),
)
```

### 4. Fetch JSON from Firebase Storage

```dart
// In a StateNotifier using GetStateNotifier:
class MyConfigStateNotifier extends GetStateNotifier<StorageFailure, MyConfig> {
  @override
  Future<Either<StorageFailure, MyConfig>> forwardedGet() =>
      ref.read(getJsonUsecaseProvider)(
        path: 'config/app_config.json',
        invalidateCacheDuration: const Duration(hours: 6),
        invalidateCacheBefore: null,
      ).then((result) => result.fold(
        Left.new,
        (json) => Right(MyConfig.fromJson(json as Map<String, dynamic>)),
      ));
}
```

### 5. Manual download URL fetch

```dart
final familyArgs = GetDownloadUrlFamilyArgs(
  path: 'documents/report.pdf',
  invalidateCacheDuration: const Duration(hours: 1),
);
final state = ref.watch(getDownloadUrlStateNotifierProvider(familyArgs));

switch (state) {
  LoadSuccessState(value: final url) => launchUrlString(url),
  LoadFailureState()                 => showError(),
  _                                  => showLoading(),
}
```

---

## What Is Already Implemented

| Capability | Status |
|---|---|
| Firebase Storage download URL fetch | ✅ `GetDownloadUrlUsecase` |
| Firebase Storage JSON fetch | ✅ `GetJsonUsecase` |
| Transparent SharedPreferences caching | ✅ `SharedPreferencesCacheLocalDataSource` |
| Cache invalidation by date | ✅ `invalidateCacheBefore` parameter |
| Cache invalidation by duration (TTL) | ✅ `invalidateCacheDuration` parameter |
| Display raster image from Storage | ✅ `ImageNetworkFromStorageWidget` |
| Display SVG from Storage | ✅ `SvgFromStorageWidget` |
| Debug/prod cache key separation | ✅ `CacheKey.key` appends `_debug` |
| Firebase Storage upload | ❌ Not in package — implement directly |
| Firebase Storage delete | ❌ Not in package — implement directly |
| Alternative storage backends (S3, etc.) | ❌ Add new `StorageRemoteDataSource` impl |

---

## Exported Symbols

```dart
export 'src/features/storage/domain/data_sources/storage_remote_data_source.dart';
export 'src/features/storage/domain/repositories/storage_repository.dart';
export 'src/features/storage/domain/usecases/get_download_url_usecase.dart';
export 'src/features/storage/domain/usecases/get_json_usecase.dart';
export 'src/features/storage/data/data_sources/firebase_storage_remote_data_source.dart';
export 'src/features/storage/data/repositories/firebase_storage_repository.dart';
export 'src/features/storage/presentation/notifiers/get_download_url_state_notifier.dart';
export 'src/features/storage/presentation/notifiers/get_json_state_notifier.dart';
export 'src/features/storage/presentation/widgets/image_network_from_storage_widget.dart';
export 'src/features/storage/presentation/widgets/svg_from_storage_widget.dart';
```
