---
name: feature-settings
description: Everything about the settings feature in flutter_core_modules — HapticFeedbackStateNotifier, WakelockStateNotifier, SwitchRowWidget, CacheBoolRowWidget, ThemeRowWidget, and how to use them in a settings screen. Use when building settings UI, wiring haptic or wakelock toggles, or asking whether these settings are already implemented.
---

# Feature: Settings

**Purpose:** Provides two persisted boolean settings (haptic feedback, wakelock/prevent-sleep) and three ready-made settings row widgets that integrate with Riverpod state. There is no domain or data layer — settings use the core `CacheBoolStateNotifier` and `ThemeStateNotifier` patterns directly.

---

## Layer Map

```
lib/src/features/settings/
└── presentation/
    ├── notifiers/
    │   ├── haptic_feedback_state_notifier.dart  # HapticFeedbackStateNotifier
    │   └── wakelock_state_notifier.dart          # WakelockStateNotifier
    └── widgets/
        ├── switch_row_widget.dart               # SwitchRowWidget (generic toggle row)
        ├── cache_bool_row_widget.dart           # CacheBoolRowWidget (wires to StateNotifier)
        └── theme_row_widget.dart                # ThemeRowWidget (dark/light mode toggle)
```

---

## Notifiers

### `HapticFeedbackStateNotifier`
**File:** `lib/src/features/settings/presentation/notifiers/haptic_feedback_state_notifier.dart`

Extends `CacheBoolStateNotifier`. Persists haptic feedback preference to `SharedPreferences`.

```dart
const _key = 'hapticFeedback';
const kDefaultHapticFeedback = true; // enabled by default

// Key is debug-aware:
String hapticFeedbackKey() => kDebugMode ? '${_key}Debug' : _key;

// Provider — NOT autoDispose (global app setting):
final hapticFeedbackStateNotifierProvider =
    StateNotifierProvider<HapticFeedbackStateNotifier, bool>(...);
```

**Usage in other widgets:** `LabelRowWidget.copyToClipboard` and `LabelRowWidget.openLink` both read `hapticFeedbackStateNotifierProvider` via `ProviderScope.containerOf(context)` to trigger `HapticFeedback.lightImpact()` before the action. Haptic feedback is therefore automatic across all list rows.

### `WakelockStateNotifier`
**File:** `lib/src/features/settings/presentation/notifiers/wakelock_state_notifier.dart`

Extends `CacheBoolStateNotifier`. Persists wakelock (prevent screen sleep) preference and applies it immediately via `WakelockPlus.toggle(enable: state)` on initialization.

```dart
const _key = 'wakelock';
const kDefaultWakelock = true; // enabled by default

// Provider — NOT autoDispose (global app setting):
final wakelockStateNotifierProvider =
    StateNotifierProvider<WakelockStateNotifier, bool>(...);
```

**Important:** The wakelock is applied in the constructor — the screen will stay on by default when the app starts, before any user action.

---

## Widgets

### `SwitchRowWidget` — Generic Toggle Row

```dart
SwitchRowWidget({
  required ValueNotifier<bool>? state, // null = internal hook state
  required bool initialData,
  required bool displayDivider,
  required Widget? leftWidget,
  required String title,
  required String? description,
  required void Function(bool newState)? onPressed,  // tap anywhere on row
  required void Function(bool newState)? onChanged,  // directly on the switch
})
```

- When `state` is null, manages its own `ValueNotifier<bool>` via `useValueNotifier(initialData)`
- When `state` is provided, it is externally controlled (e.g., from a `CacheBoolRowWidget`)
- Both `onPressed` and `onChanged` update the state via `addPostFrameCallback` to avoid setState-during-build

### `CacheBoolRowWidget` — Toggle Wired to a `CacheBoolStateNotifier`

```dart
CacheBoolRowWidget({
  required StateNotifierProvider<CacheBoolStateNotifier, bool> stateNotifierProvider,
  required bool displayDivider,
  required Widget? leftWidget,
  required String title,
  required String? description,
  required void Function(bool newState)? onPressed,
  required void Function(bool newState)? onChanged,
})
```

- Reads initial state from the provider synchronously
- `onPressed`/`onChanged` call `notifier.set(value: value)` which persists to `SharedPreferences`
- Uses `Consumer` with `child` optimization: only the switch state rebuilds, not the entire row

### `ThemeRowWidget` — Dark/Light Mode Toggle

```dart
ThemeRowWidget({
  required ValueNotifier<IosThemeData>? state, // null = uses IosTheme.of(context)
  required bool displayDivider,
  required String label,
  required String? description,
  void Function(IosThemeData newState)? onPressed,
  void Function(IosThemeData newState)? onChanged,
})
```

- Toggles between `IosLightThemeData` and `IosDarkThemeData`
- When state changes, calls `themeStateNotifierProvider.notifier.setThemeData()` via a `useSafeEffect` listener
- Uses `AppIconWidget.icon(iconData: Icons.dark_mode)` as the left icon automatically

---

## How to Use From an External App

### 1. Haptic feedback toggle in settings screen

```dart
CacheBoolRowWidget(
  stateNotifierProvider: hapticFeedbackStateNotifierProvider,
  displayDivider: true,
  leftWidget: AppIconWidget.icon(iconData: CupertinoIcons.hand_tap),
  title: 'Haptic Feedback',
  description: 'Vibrate when tapping actions',
  onPressed: (newState) {
    TapOnVibrationFeedbackSettings(enable: newState).track(context: context);
  },
  onChanged: null,
)
```

### 2. Wakelock toggle (prevent screen sleep)

```dart
CacheBoolRowWidget(
  stateNotifierProvider: wakelockStateNotifierProvider,
  displayDivider: true,
  leftWidget: AppIconWidget.icon(iconData: CupertinoIcons.brightness_solid),
  title: 'Keep Screen On',
  description: 'Prevents the screen from sleeping',
  onPressed: (newState) {
    TapOnPreventSleepSettings(enable: newState).track(context: context);
    WakelockPlus.toggle(enable: newState); // sync actual wakelock
  },
  onChanged: null,
)
```

> Note: `WakelockStateNotifier` applies the wakelock on init but does NOT re-apply it when `set()` is called. The consuming app should call `WakelockPlus.toggle(enable: newState)` in the `onPressed` callback.

### 3. Dark mode toggle

```dart
ThemeRowWidget(
  state: null,               // uses IosTheme.of(context) as initial value
  displayDivider: false,
  label: 'Dark Mode',
  description: null,
  onPressed: (newTheme) {
    TapOnDarkModeSettings(themeData: newTheme).track(context: context);
  },
)
```

### 4. Generic custom toggle (not persisted)

```dart
SwitchRowWidget(
  state: myExternalValueNotifier, // or null for internal state
  initialData: true,
  displayDivider: false,
  leftWidget: null,
  title: 'Notifications',
  description: 'Receive push notifications',
  onPressed: (newState) => myService.setNotifications(newState),
  onChanged: null,
)
```

### 5. Read haptic setting in code

```dart
// Check before triggering haptic feedback:
final hapticEnabled = ref.read(hapticFeedbackStateNotifierProvider);
if (hapticEnabled) {
  HapticFeedback.lightImpact();
}

// Or via ProviderScope (no WidgetRef needed):
final hapticEnabled = ProviderScope.containerOf(context)
    .read(hapticFeedbackStateNotifierProvider);
```

---

## What Is Already Implemented

| Capability | Status |
|---|---|
| Haptic feedback toggle (persisted) | ✅ `HapticFeedbackStateNotifier` |
| Prevent screen sleep / wakelock (persisted) | ✅ `WakelockStateNotifier` |
| Generic toggle row widget | ✅ `SwitchRowWidget` |
| Toggle wired to `CacheBoolStateNotifier` | ✅ `CacheBoolRowWidget` |
| Dark/Light mode toggle row | ✅ `ThemeRowWidget` |
| Auto-haptic on list row tap | ✅ Built into `LabelRowWidget.copyToClipboard` / `openLink` |
| Notification permission settings | ❌ Not in package — use `app_settings` package directly |
| Custom settings persistence type (non-bool) | ❌ Not in package — implement with `ThemeStateNotifier` as template |

---

## Exported Symbols

```dart
export 'src/features/settings/presentation/notifiers/haptic_feedback_state_notifier.dart';
export 'src/features/settings/presentation/notifiers/wakelock_state_notifier.dart';
export 'src/features/settings/presentation/widgets/cache_bool_row_widget.dart';
export 'src/features/settings/presentation/widgets/switch_row_widget.dart';
export 'src/features/settings/presentation/widgets/theme_row_widget.dart';
```
