# flutter_core_modules

A production-ready Flutter package that bundles reusable, clean-architecture modules for common app concerns — analytics, caching, locale, in-app purchases, app review, routing, settings, Firebase Storage, and theming.

Each module follows a strict **data → domain → presentation** layer separation and exposes a Riverpod-first API surface.

---

## Table of contents

- [Features](#features)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Installation](#installation)
- [Modules](#modules)
  - [Core](#core)
  - [Analytics](#analytics)
  - [Locale](#locale)
  - [Revenue (RevenueCat)](#revenue-revenuecat)
  - [Review](#review)
  - [Route](#route)
  - [Settings](#settings)
  - [Storage (Firebase)](#storage-firebase)
  - [Theme](#theme)
- [Development](#development)
  - [Dart MCP server](#dart-mcp-server)
  - [Ralph orchestrator](#ralph-orchestrator)
- [Contributing](#contributing)

---

## Features

| Module    | What it provides |
|-----------|-----------------|
| **Core**      | Cache (SharedPreferences), HTTP overrides, Either monad, safe hooks & notifiers, UI widgets |
| **Analytics** | Unified tracking across Firebase Analytics, Mixpanel, Amplitude, PostHog, Statsig, Remote Config |
| **Locale**    | Persist & restore app locale via cache |
| **Revenue**   | RevenueCat customer-info management (purchases, entitlements, anonymous ID) |
| **Review**    | In-app review prompts and App Store listing launcher |
| **Route**     | `ShellRouteWidget` + navigation observers for go_router |
| **Settings**  | Haptic feedback toggle, wakelock toggle, theme row, cached bool row |
| **Storage**   | Firebase Storage file URLs and JSON fetching with cached image / SVG widgets |
| **Theme**     | Persist & restore `ThemeMode` via cache |

---

## Architecture

```
lib/src/
├── core/
│   ├── data/          # Concrete implementations (SharedPreferences, HTTP)
│   ├── domain/        # Entities, repository contracts, use-cases, utils
│   └── presentation/  # Hooks, notifiers, widgets, Riverpod providers
└── features/
    └── <feature>/
        ├── data/
        ├── domain/
        └── presentation/
```

Every feature exposes:
- An **abstract repository** (domain layer) — the contract.
- A **concrete repository** (data layer) — the implementation.
- **Use-cases** that wrap repository calls with `Either<Failure, T>` result types.
- **Riverpod notifiers** that call use-cases and expose typed state.

---

## Requirements

| Dependency | Minimum version |
|-----------|----------------|
| Dart SDK  | `>=3.10.0 <4.0.0` |
| Flutter   | `>=3.38.3` |

---

## Installation

Add the package as a `path` or Git dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  flutter_core_modules:
    git:
      url: https://github.com/sampaio-tech/flutter_core_modules.git
      ref: main
```

Then run:

```bash
flutter pub get
```

Import the barrel file:

```dart
import 'package:flutter_core_modules/flutter_core_modules.dart';
```

---

## Modules

### Core

#### Cache

```dart
// Provide SharedPreferences
final prefs = await SharedPreferences.getInstance();
final container = ProviderContainer(overrides: [
  sharedPreferencesProvider.overrideWithValue(prefs),
]);

// Use a cached bool notifier
final notifier = container.read(
  cacheBoolStateNotifierProvider(CacheKey.myKey).notifier,
);
await notifier.setValue(true);
```

#### Either

```dart
Either<Failure, String> result = Right('hello');
result.fold(
  (failure) => print(failure),
  (value)   => print(value),
);
```

#### Hooks

```dart
// Debounce a text field search
useDebounce(() => search(query), [query], duration: const Duration(milliseconds: 300));

// Safe effect — skips the first run
useSafeEffect(() { /* runs only on subsequent rebuilds */ }, [dep]);
```

---

### Analytics

The `TrackEventUsecase` fans out a single `EventEntity` to every configured provider.

```dart
// 1. Initialise providers at app start
await AmplitudeSetup.init(apiKey: env.amplitudeKey);
await MixpanelSetup.init(token: env.mixpanelToken);
await PosthogSetup.init(apiKey: env.posthogKey, host: env.posthogHost);

// 2. Track events anywhere
final track = ref.read(trackEventUsecaseProvider);
await track(TapOnEvents.button(name: 'subscribe_cta'));
```

Built-in event types extend `EventEntity`. Add your own by extending the base class.

---

### Locale

```dart
// Persist locale
final setLocale = ref.read(setLocaleUsecaseProvider);
await setLocale(const Locale('pt', 'BR'));

// Restore on startup
final getLocale = ref.read(getLocaleUsecaseProvider);
final locale = await getLocale();
```

---

### Revenue (RevenueCat)

```dart
// Configure at app start
await RevenueCatConfig.init(apiKey: env.revenueCatKey);

// Read current customer info
final customerInfo = ref.watch(customerInfoStateNotifierProvider);
customerInfo.when(
  data: (info) => Text(info.activeSubscriptions.toString()),
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);
```

---

### Review

```dart
// Check availability and request review
final isAvailable = await ref.read(isAvailableUsecaseProvider)();
if (isAvailable) {
  await ref.read(requestReviewUsecaseProvider)();
}

// Open the store listing directly
await ref.read(openStoreListingUsecaseProvider)();
```

---

### Route

The routing module is built on top of Flutter's native `CupertinoTabScaffold` — no third-party router required. Each tab is described by a `NavigationTab` subclass. `ShellRouteWidget` wires everything together and handles Android system-back correctly (pops within the tab before popping the host route).

**1. Define your tabs**

```dart
class HomeTab extends NavigationTab {
  const HomeTab() : super(
    name: 'home',
    icon: CupertinoIcons.house_fill,
    initialTab: true,
  );

  @override
  String label(BuildContext context) => 'Home';

  @override
  Map<String, WidgetBuilder>? get routes => {
    '/': (_) => const HomeScreen(),
    '/detail': (_) => const DetailScreen(),
  };

  @override
  List<NavigatorObserver> navigatorObservers(BuildContext context) =>
      defaultNavigatorObservers(context); // Firebase Analytics + PostHog
}

class ProfileTab extends NavigationTab {
  const ProfileTab() : super(
    name: 'profile',
    icon: CupertinoIcons.person_fill,
  );

  @override
  String label(BuildContext context) => 'Profile';

  @override
  Map<String, WidgetBuilder>? get routes => {
    '/': (_) => const ProfileScreen(),
  };
}
```

**2. Render with `ShellRouteWidget`**

```dart
ShellRouteWidget(
  tabs: const [HomeTab(), ProfileTab()],
  activeColor: CupertinoColors.systemBlue,
)
```

`ShellRouteWidget` renders a `CupertinoTabScaffold` where each tab has its own `CupertinoTabView` and an isolated `NavigatorKey` (provided via Riverpod). Tapping an already-active tab pops the stack back to the root route.

**3. Navigation observers**

`defaultNavigatorObservers` automatically attaches `FirebaseAnalyticsObserver` and `PosthogObserver` when the respective integrations are enabled in your `.env`:

```dart
// Enabled automatically when DotEnv.enableAnalytics == true
List<NavigatorObserver> navigatorObservers(BuildContext context) =>
    defaultNavigatorObservers(context);
```

---

### Settings

Drop-in settings rows for common toggles:

```dart
Column(
  children: [
    ThemeRowWidget(),           // light / dark / system
    CacheBoolRowWidget(cacheKey: CacheKey.notifications),
    SwitchRowWidget(
      title: 'Haptic feedback',
      notifier: hapticFeedbackStateNotifierProvider,
    ),
  ],
)
```

---

### Storage (Firebase)

```dart
// Display an image stored in Firebase Storage
ImageNetworkFromStorageWidget(storagePath: 'avatars/user_123.jpg')

// Display an SVG stored in Firebase Storage
SvgFromStorageWidget(storagePath: 'icons/logo.svg')

// Fetch a JSON file
final getJson = ref.read(getJsonUsecaseProvider);
final result = await getJson('config/remote.json');
```

---

### Theme

```dart
// Persist chosen theme
final setTheme = ref.read(setThemeDataUsecaseProvider);
await setTheme(ThemeMode.dark);

// Watch and apply in MaterialApp
final themeMode = ref.watch(themeStateNotifierProvider);
MaterialApp(
  themeMode: themeMode,
  ...
)
```

---

## Development

### Dart MCP server

The repository ships with a `.cursor/mcp.json.example` that wires up the [Dart MCP server](https://dart.dev/tools/dart-devtools) so Cursor can resolve Dart/Flutter symbols in AI completions.

Copy and customise for your local setup:

```bash
cp .cursor/mcp.json.example .cursor/mcp.json
```

Then update the `dart` executable path to match your local Flutter SDK:

```json
{
  "mcpServers": {
    "dart": {
      "command": "/path/to/flutter/bin/cache/dart-sdk/bin/dart",
      "args": ["mcp-server"]
    }
  }
}
```

> `.cursor/mcp.json` is git-ignored so each developer keeps their own local paths.

---

### Ralph orchestrator

The project uses [Ralph](https://github.com/mikeyobrien/ralph-orchestrator) for AI-driven task automation. The workflow is:

1. Write your task description in `PROMPT.md`.
2. Run `ralph run` — Ralph drives Claude in a loop until the task is complete or `LOOP_COMPLETE` is written.

**Quick start:**

```bash
# Install ralph (requires Node.js)
npm install -g ralph-orchestrator

# Create your task
echo "Add a new analytics event for onboarding completion" > PROMPT.md

# Run
ralph run
```

**Key `ralph.yml` options:**

| Key | Default | Description |
|-----|---------|-------------|
| `cli.backend` | `claude` | LLM backend to use |
| `event_loop.max_iterations` | `100` | Safety cap on LLM iterations |
| `git.commit.message_format` | `conventional` | Commit style: `conventional`, `simple`, or `custom` |
| `git.push.auto_push` | `true` | Push to `origin` after each commit |
| `git.branch.prefix` | `ralph/` | Branch prefix for Ralph-generated branches |

Copy `ralph.yml.example` to `ralph.yml` and fill in your git credentials if you need to reset the config:

```bash
cp ralph.yml.example ralph.yml
```

---

## Contributing

1. Fork the repository and create a feature branch.
2. Follow the existing clean-architecture layer conventions.
3. Run `flutter analyze` and `flutter test` before opening a PR.
4. Use [Conventional Commits](https://www.conventionalcommits.org/) for all commit messages.
