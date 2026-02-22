---
name: feature-route
description: Everything about the route feature in flutter_core_modules — ShellRouteWidget, NavigationTab abstract class, navigatiorKeyProvider, defaultNavigatorObservers, and how to build a tab-based iOS navigation shell from a consuming app. Use when setting up tab navigation, asking whether a navigation shell exists, or wiring analytics observers to routes.
---

# Feature: Route

**Purpose:** Provides a ready-made iOS-style tab navigation shell (`CupertinoTabScaffold` + `CupertinoTabView`) with system-back handling, pop-to-root on double-tap, analytics observer integration, and per-tab `GlobalKey<NavigatorState>` management via Riverpod.

There is no domain or data layer — this feature is **presentation-only**.

---

## Layer Map

```
lib/src/features/route/
└── presentation/
    ├── utils/navigation_observers.dart     # defaultNavigatorObservers()
    └── widgets/shell_route_widget.dart     # ShellRouteWidget + NavigationTab + navigatiorKeyProvider
```

---

## Core Abstractions

### `NavigationTab` — Abstract Tab Definition
**File:** `lib/src/features/route/presentation/widgets/shell_route_widget.dart`

```dart
abstract class NavigationTab {
  final String name;         // unique identifier
  final IconData icon;       // tab bar icon
  final bool initialTab;     // set true for the default selected tab
  final String? restorationScopeId;

  // Override to provide localized label:
  String label(BuildContext context);

  // Optional: override to provide named routes:
  Map<String, Widget Function(BuildContext)>? get routes;

  // Optional: default title for the CupertinoTabView:
  String? defaultTitle(BuildContext context) => null;

  // Optional: analytics + other navigator observers for this tab:
  List<NavigatorObserver> navigatorObservers(BuildContext context) => [];

  // Resolved via Riverpod — stable GlobalKey per tab instance:
  GlobalKey<NavigatorState> navigatorKey(BuildContext context);
}
```

Implement this abstract class once per tab in the consuming app.

### `navigatiorKeyProvider` — Per-Tab Navigator Key
```dart
// Note: "navigatior" is the spelling used in the codebase (not a typo to fix)
final navigatiorKeyProvider =
    Provider.family<GlobalKey<NavigatorState>, NavigationTab?>(
      (ref, args) => GlobalKey<NavigatorState>(),
    );
```

Each `NavigationTab.navigatorKey(context)` calls `ProviderScope.containerOf(context).read(navigatiorKeyProvider(this))`, which creates a stable `GlobalKey` per tab identity (based on `==` + `hashCode`).

### `ShellRouteWidget`
**File:** `lib/src/features/route/presentation/widgets/shell_route_widget.dart`

```dart
ShellRouteWidget({
  required List<NavigationTab> tabs,
  Color? activeColor,  // defaults to theme.acessibleColors.systemGreen
})
```

Behaviors built-in:
- **Pop to root:** Tapping the active tab calls `popUntil((route) => route.isFirst)` on its navigator
- **System back:** Pops the current tab's navigator stack; if at root, allows the system to handle it
- **Tab controller:** Uses `useCupertinoTabController` (flutter_hooks)
- **Per-tab navigator:** Each tab gets its own `CupertinoTabView` with isolated navigation stack

### `defaultNavigatorObservers()` — Analytics Auto-Tracking
**File:** `lib/src/features/route/presentation/utils/navigation_observers.dart`

```dart
List<NavigatorObserver> defaultNavigatorObservers(BuildContext context)
```

Returns `FirebaseAnalyticsObserver` and `PosthogObserver` when enabled. Returns empty list in debug mode or when respective SDKs are not initialized.

---

## How to Use From an External App

### 1. Implement a tab

```dart
class HomeTab extends NavigationTab {
  const HomeTab() : super(
    name: 'home',
    icon: CupertinoIcons.house_fill,
    initialTab: true, // default selected tab
  );

  @override
  String label(BuildContext context) =>
      AppLocalizations.of(context)!.home;

  @override
  Map<String, Widget Function(BuildContext)>? get routes => {
    '/': (context) => const HomeScreen(),
    '/detail': (context) => const DetailScreen(),
  };

  @override
  List<NavigatorObserver> navigatorObservers(BuildContext context) =>
      defaultNavigatorObservers(context); // analytics auto-tracking
}

class SettingsTab extends NavigationTab {
  const SettingsTab() : super(
    name: 'settings',
    icon: CupertinoIcons.settings,
  );

  @override
  String label(BuildContext context) => 'Settings';

  @override
  Map<String, Widget Function(BuildContext)>? get routes => {
    '/': (context) => const SettingsScreen(),
  };
}
```

### 2. Compose the shell

```dart
// In your app widget's body:
ShellRouteWidget(
  tabs: const [HomeTab(), SettingsTab(), ProfileTab()],
  activeColor: CupertinoColors.activeBlue, // optional, defaults to systemGreen
)
```

### 3. Navigate within a tab

```dart
// Push from within a tab's navigator:
Navigator.of(context).pushNamed('/detail');

// Or with a GlobalKey (e.g., from outside the tab context):
final key = ProviderScope.containerOf(context).read(navigatiorKeyProvider(homeTab));
key.currentState?.pushNamed('/detail');
```

### 4. Pop to root programmatically

The shell handles this on tab double-tap automatically. For programmatic pop-to-root:
```dart
final key = ProviderScope.containerOf(context).read(navigatiorKeyProvider(activeTab));
key.currentState?.popUntil((route) => route.isFirst);
```

---

## What Is Already Implemented

| Capability | Status |
|---|---|
| iOS tab scaffold (`CupertinoTabScaffold`) | ✅ `ShellRouteWidget` |
| Pop-to-root on tab double-tap | ✅ Built into `ShellRouteWidget` |
| System back handling | ✅ `PopScope` in `ShellRouteWidget` |
| Per-tab isolated navigator | ✅ `CupertinoTabView` per tab |
| Stable GlobalKey per tab | ✅ `navigatiorKeyProvider` (family provider) |
| Analytics screen tracking (Firebase + PostHog) | ✅ `defaultNavigatorObservers()` |
| Deep-link / go_router integration | ❌ Not in package — implement in consuming app |
| Bottom tab badge support | ❌ Not in package — extend `NavigationTab` |
| Custom tab bar | ❌ Uses `CupertinoTabBar` directly — customize via `activeColor` |

---

## Exported Symbols

```dart
export 'src/features/route/presentation/utils/navigation_observers.dart';
export 'src/features/route/presentation/widgets/shell_route_widget.dart';
// Exposes: ShellRouteWidget, NavigationTab, navigatiorKeyProvider
```
