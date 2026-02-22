---
name: feature-theme
description: Everything about the theme feature in flutter_core_modules — ThemeStateNotifier, ThemeRepository, how theme is persisted and restored, IosThemeData (IosLightThemeData / IosDarkThemeData), and how to wire theme into a consuming app. Use when implementing dark/light mode, asking whether theme persistence is already implemented, or wiring the theme provider to a root widget.
---

# Feature: Theme

**Purpose:** Persist and restore the user's chosen `IosThemeData` (light or dark) across sessions using `SharedPreferences`, and expose a reactive `ThemeStateNotifier` that the app root widget watches to re-theme the entire app.

---

## Layer Map

```
lib/src/features/theme/
├── domain/
│   ├── repositories/theme_repository.dart          # abstract ThemeRepository
│   └── usecases/
│       ├── get_theme_data_usecase.dart              # GetThemeDataUsecase + provider
│       ├── set_theme_data_usecase.dart              # SetThemeDataUsecase + provider
│       └── remove_theme_data_usecase.dart           # RemoveThemeDataUsecase + provider
├── data/
│   └── repositories/theme_repository.dart          # ThemeRepositoryImpl + provider
└── presentation/
    └── notifiers/
        └── theme_state_notifier.dart               # ThemeStateNotifier + provider
```

---

## Domain

### Repository Interface
```dart
abstract class ThemeRepository {
  IosThemeData? getThemeData();                               // sync, nullable
  Future<bool> setThemeData({required IosThemeData iosThemeData});
  Future<bool> removeThemeData();
}
```

### Use Cases

| Class | Provider | Signature |
|---|---|---|
| `GetThemeDataUsecase` | `getThemeDataUsecaseProvider` | `IosThemeData? call()` |
| `SetThemeDataUsecase` | `setThemeDataUsecaseProvider` | `Future<bool> call({required IosThemeData iosThemeData})` |
| `RemoveThemeDataUsecase` | `removeThemeDataUsecaseProvider` | `Future<bool> call()` |

All providers are `Provider.autoDispose`.

---

## Data

### `ThemeRepositoryImpl`
**File:** `lib/src/features/theme/data/repositories/theme_repository.dart`

Stores the theme as a `String` (runtime type name) in SharedPreferences:

```
IosLightThemeData → stored as 'IosLightThemeData'
IosDarkThemeData  → stored as 'IosDarkThemeData'
```

Key: `DatabaseKeys.iosThemeData.key` → `'iosThemeData'` (prod) / `'iosThemeDataDebug'` (debug)

```dart
// Read: pattern-matches on the stored string to reconstruct the correct subclass
IosThemeData? getThemeData() => switch (_sharedPreferences.getString(key)) {
  null => null,
  final v when v == IosLightThemeData().runtimeType.toString() => IosLightThemeData(),
  final v when v == IosDarkThemeData().runtimeType.toString()  => IosDarkThemeData(),
  _ => null,
};
```

Provider: `themeRepositoryProvider` (autoDispose).

---

## Presentation

### `ThemeStateNotifier`
**File:** `lib/src/features/theme/presentation/notifiers/theme_state_notifier.dart`

State: `IosThemeData?` — `null` means "use system default"

```dart
class ThemeStateNotifier extends SafeStateNotifier<IosThemeData?> {
  // Constructor reads initial theme synchronously from SharedPreferences
  ThemeStateNotifier({...}) : super(getThemeDataUsecase());

  IosThemeData? getThemeData()         // re-reads from SharedPreferences, updates state
  Future<bool> setThemeData({required IosThemeData, bool save = true})
    // save: true = persist + update state
    // save: false = only update state (temporary, not persisted)
  Future<bool> removeThemeData()       // removes from SharedPreferences, sets state to null
}

// Provider — NOT autoDispose (global app state):
final themeStateNotifierProvider =
    StateNotifierProvider<ThemeStateNotifier, IosThemeData?>(...);
```

**`save: false` pattern:** Useful for live previewing a theme change before committing:
```dart
// Preview:
notifier.setThemeData(iosThemeData: IosDarkThemeData(), save: false);
// Commit on user confirmation:
notifier.setThemeData(iosThemeData: IosDarkThemeData(), save: true);
```

---

## IosThemeData — The Theme Type

From the `ios_design_system` package (local path dependency):

```dart
// Two concrete implementations:
class IosLightThemeData extends IosThemeData {}
class IosDarkThemeData  extends IosThemeData {}

// Access from widget tree:
final theme = IosTheme.of(context);

// Pattern match for theme-specific styling:
switch (theme) {
  IosLightThemeData() => theme.defaultLabelColors.primary,
  IosDarkThemeData()  => theme.stocksDecorations.defaultColors.primary,
}
```

---

## How to Use From an External App

### 1. Wire theme to app root

```dart
// In your root HookConsumerWidget:
class MyApp extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeStateNotifierProvider);

    return IosTheme(
      data: themeData ?? IosLightThemeData(), // null = fallback to light
      child: CupertinoApp(
        theme: CupertinoThemeData(
          brightness: switch (themeData) {
            null => Brightness.light,
            IosLightThemeData() => Brightness.light,
            IosDarkThemeData()  => Brightness.dark,
          },
        ),
        ...
      ),
    );
  }
}
```

### 2. Toggle dark mode from settings

```dart
// Using the pre-built widget (auto-wired to themeStateNotifierProvider):
ThemeRowWidget(
  state: null,
  displayDivider: false,
  label: 'Dark Mode',
  description: null,
  onPressed: (newTheme) {
    TapOnDarkModeSettings(themeData: newTheme).track(context: context);
  },
)

// Or manually:
ref.read(themeStateNotifierProvider.notifier).setThemeData(
  iosThemeData: IosDarkThemeData(),
);
```

### 3. Reset to system theme

```dart
await ref.read(themeStateNotifierProvider.notifier).removeThemeData();
// state becomes null → app root falls back to system brightness
```

### 4. Read theme in any widget

```dart
// Via Riverpod:
final themeData = ref.watch(themeStateNotifierProvider);

// Via IosTheme (reads from InheritedWidget, no Riverpod needed):
final theme = IosTheme.of(context);
final primaryColor = theme.defaultLabelColors.primary;
```

### 5. Preview theme without saving

```dart
// Show a live preview without persisting:
ref.read(themeStateNotifierProvider.notifier).setThemeData(
  iosThemeData: IosDarkThemeData(),
  save: false,
);
```

---

## What Is Already Implemented

| Capability | Status |
|---|---|
| Persist dark/light theme preference | ✅ `SetThemeDataUsecase` |
| Restore theme on app start (sync) | ✅ `ThemeStateNotifier` constructor |
| Reactive theme updates | ✅ `themeStateNotifierProvider` (non-autoDispose) |
| Reset to system theme | ✅ `RemoveThemeDataUsecase` / `notifier.removeThemeData()` |
| Preview without saving | ✅ `notifier.setThemeData(save: false)` |
| Dark/light mode toggle widget | ✅ `ThemeRowWidget` |
| System theme detection | ❌ Not built-in — implement by reading `MediaQuery.platformBrightnessOf(context)` when state is null |
| Multiple custom themes beyond light/dark | ❌ Only `IosLightThemeData` / `IosDarkThemeData` supported |

---

## Exported Symbols

```dart
export 'src/features/theme/domain/repositories/theme_repository.dart';
export 'src/features/theme/domain/usecases/get_theme_data_usecase.dart';
export 'src/features/theme/domain/usecases/remove_theme_data_usecase.dart';
export 'src/features/theme/domain/usecases/set_theme_data_usecase.dart';
export 'src/features/theme/data/repositories/theme_repository.dart';
export 'src/features/theme/presentation/notifiers/theme_state_notifier.dart';
```
