# flutter_core_modules

A production-ready Flutter package that bundles reusable, clean-architecture modules for common app concerns — analytics, caching, locale, in-app purchases, app review, routing, settings, Firebase Storage, and theming.

Each module follows a strict **domain → data → presentation** layer separation and exposes a Riverpod-first API surface.

---

## Table of contents

- [Features](#features)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Installation](#installation)
- [App initialization](#app-initialization)
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
- [Naming conventions](#naming-conventions)
- [AI tooling](#ai-tooling)
  - [Claude Code skills](#claude-code-skills)
  - [Cursor rules](#cursor-rules)
  - [Dart MCP server](#dart-mcp-server)
  - [Ralph orchestrator](#ralph-orchestrator)
- [Contributing](#contributing)

---

## Features

| Module | What it provides |
|---|---|
| **Core** | `Either<L,R>` monad, `State<F,S>` sealed lifecycle, `SafeStateNotifier`, `GetStateNotifier`, `CacheBoolStateNotifier`, SharedPreferences singleton, HTTP clients, hooks (`useSafeEffect`, `useDebounce`), shared widgets |
| **Analytics** | Unified event tracking across Firebase Analytics, Mixpanel, Amplitude, PostHog, and Statsig — all gated by Remote Config flags |
| **Locale** | Persist and restore the user's chosen `Locale` via SharedPreferences |
| **Revenue** | RevenueCat customer-info management, `isPremiumCustomerProvider`, paywall presentation with analytics |
| **Review** | Native in-app review dialog, App Store listing launcher, feedback email via `url_launcher` |
| **Route** | `ShellRouteWidget` (iOS tab shell) + `NavigationTab` + `defaultNavigatorObservers` for analytics |
| **Settings** | Haptic feedback toggle, wakelock toggle, `SwitchRowWidget`, `CacheBoolRowWidget`, `ThemeRowWidget` |
| **Storage** | Firebase Storage URL and JSON fetching with transparent SharedPreferences caching, `ImageNetworkFromStorageWidget`, `SvgFromStorageWidget` |
| **Theme** | Persist and restore `IosThemeData` (light / dark) via SharedPreferences, `ThemeStateNotifier`, `ThemeRowWidget` |

---

## Architecture

```
lib/src/
├── core/                     # Shared infrastructure
│   ├── domain/               # Either, State, failures, cache entities, use cases
│   ├── data/                 # SharedPreferences, HTTP client implementations
│   └── presentation/         # SafeStateNotifier, GetStateNotifier, hooks, widgets, setup providers
└── features/
    └── <feature>/
        ├── domain/           # Abstract repository, use cases, entities, failures
        ├── data/             # Concrete repository, data sources
        └── presentation/     # StateNotifier + provider, widgets, config
```

Every feature exposes:
- An **abstract repository** (domain layer) — the contract
- A **concrete repository** (data layer) — the implementation
- **Use cases** that call the repository and return `Either<Failure, T>`
- **Riverpod notifiers** that call use cases and expose `State<F, S>` or custom typed state

### State lifecycle

```dart
sealed class State<F, S> {}
class StartedState<F, S>      extends State<F, S> {} // before first fetch
class LoadInProgressState<F, S> extends State<F, S> {} // fetching
class LoadSuccessState<F, S>  extends State<F, S> { final S value; }
class LoadFailureState<F, S>  extends State<F, S> { final F failure; }
```

### Either

```dart
Either<Failure, String> result = Right('hello');
result.fold(
  (failure) => print(failure),
  (value)   => print(value),
);
```

---

## Requirements

| Dependency | Minimum version |
|---|---|
| Dart SDK | `>=3.10.0 <4.0.0` |
| Flutter | `>=3.38.3` |

---

## Installation

Add as a Git dependency in your app's `pubspec.yaml`:

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

## App initialization

`main()` must execute steps in this exact order:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase Core (required for Remote Config, Analytics, Storage, Crashlytics)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Firebase Remote Config (gates analytics provider initialization)
  final remoteConfig = await FirebaseRemoteConfigCore.init();

  // 3. SharedPreferences singleton (required before any provider reads it)
  await SharedPreferencesInstance.getInstanceSharedPreferences();

  // 4. DotEnv.init() — loads .env, initialises all analytics SDKs and RevenueCat
  await DotEnv.init(remoteConfig);

  // 5. App entry with ProviderScope
  runApp(ProviderScope(child: MyApp()));
}
```

### Required `.env` file

```env
# Analytics (all optional — omit to disable that provider)
STATSIG_CLIENT_SDK_KEY=client-...
MIXPANEL_TOKEN=...
POSTHOG_TOKEN=phc_...
AMPLITUDE_TOKEN=...
CLARITY_PROJECT_ID=...

# Revenue (required if using the revenue module)
REVENUECAT_PROJECT_APPLE_API_KEY=appl_...
REVENUECAT_PROJECT_GOOGLE_API_KEY=goog_...
```

---

## Modules

### Core

#### Hooks

```dart
// Run an effect after the first frame (avoids setState-during-build):
useSafeEffect(() {
  ref.read(myProvider.notifier).get();
  return () {};  // optional cleanup
}, []);

// Debounce a search query:
useDebounce(() => search(query), [query], duration: const Duration(milliseconds: 300));

// Repeating timer:
useInterval(() => refresh(), const Duration(seconds: 30));
```

#### Notifier base classes

| Class | Extends | Use for |
|---|---|---|
| `SafeStateNotifier<T>` | `StateNotifier<T>` | Any notifier — guards `state =` after dispose |
| `GetStateNotifier<F, E>` | `SafeStateNotifier<State<F,E>>` | Async fetch with `lazyGet()` / `get()` / `forwardedGet()` |
| `CacheBoolStateNotifier` | `SafeStateNotifier<bool>` | Boolean setting persisted to SharedPreferences |

#### Shared widgets

```dart
// Info row (copies value on tap):
LabelRowWidget(displayDivider: true, title: 'Version', label: '1.0.0', toastMessage: 'Copied!')

// Link row (opens WebView):
LabelRowWidget.link(displayDivider: false, title: 'Privacy Policy', description: 'https://example.com/privacy')

// Action button row:
LabelRowWidget.button(displayDivider: true, title: 'Rate App', displayChevronRight: true, onPressed: ...)

// Destructive action row:
LabelRowWidget.redButton(displayDivider: false, title: 'Delete Account', onPressed: ...)

// Error state:
ErrorIndicatorWidget(retryCallback: () => ref.read(myProvider.notifier).get(), label: 'Something went wrong')
```

---

### Analytics

`EventEntity` fans out to every configured provider (Firebase Analytics, Mixpanel, Amplitude, PostHog, Statsig). All providers are gated by `.env` tokens **and** Firebase Remote Config flags — disable any provider at runtime without a release.

#### Defining events

```dart
// Tap event:
class TapOnSubscribeButton extends EventEntity {
  const TapOnSubscribeButton();

  @override
  Map<String, Object>? get properties => const {};
}

// Event with properties:
class TapOnSelectPlan extends EventEntity {
  final String planId;
  final double price;

  const TapOnSelectPlan({required this.planId, required this.price});

  @override
  Map<String, Object>? get properties => {
    'plan_id': planId,
    'price': price,
  };
}
```

Event name is derived automatically: `TapOnSelectPlan` → `'tap_on_select_plan'`. Never override `name`.

#### Tracking events

```dart
// From any widget:
TapOnSubscribeButton().track(context: context);

// With properties:
TapOnSelectPlan(planId: 'pro_monthly', price: 9.99).track(context: context);
```

Analytics is silently disabled in debug mode (`kDebugMode`). Events are logged to the console instead.

---

### Locale

```dart
// Read persisted locale on app start (sync, null = system locale):
final savedLocale = ref.read(getLocaleUsecaseProvider)();

// Wire into CupertinoApp:
CupertinoApp(
  locale: savedLocale,
  supportedLocales: const [Locale('en'), Locale('pt', 'BR')],
  localizationsDelegates: const [...],
)

// Persist a locale change:
await ref.read(setLocaleUsecaseProvider)(locale: const Locale('pt', 'BR'));

// Reset to system locale:
await ref.read(removeLocaleUsecaseProvider)();
```

> There is no built-in reactive `StateNotifier` for locale. For live locale switching, wrap the use cases in a `SafeStateNotifier<Locale?>` in the consuming app (follow the `ThemeStateNotifier` pattern).

---

### Revenue (RevenueCat)

RevenueCat is initialised by `DotEnv.init()` — no additional setup required.

```dart
// On root widget mount — fetch and listen for real-time subscription changes:
useSafeEffect(() {
  final notifier = ref.read(customerInfoStateNotifierProvider.notifier);
  notifier.get().then((_) => notifier.listen());
  return () {};
}, []);

// Check premium status reactively (single source of truth):
final isPremium = ref.watch(isPremiumCustomerProvider);

// Gate a feature behind a paywall:
await presentPaywallForwarded(
  context: context,
  event: TapOnGetPremiumButton(),
  enable: true,
  featureLocked: true,
  onTap: () {
    // Called if user already has access or after a successful purchase
    Navigator.of(context).push(...);
  },
);

// Access raw subscription data:
final customerInfo = ref.watch(customerInfoStateNotifierProvider);
final activeSubscriptions = customerInfo?.activeSubscriptions ?? {};
```

---

### Review

```dart
// Check availability on mount, then show button conditionally:
useSafeEffect(() {
  ref.read(inAppReviewStateNotifierProvider.notifier).isAvailable();
  return () {};
}, []);

final canReview = ref.watch(inAppReviewStateNotifierProvider);

// Request in-app review with analytics:
await ref.read(inAppReviewStateNotifierProvider.notifier).requestReview(
  requestReviewCallback: () => TapOnReviewButton().track(context: context),
);

// Open App Store listing directly:
await ref.read(inAppReviewStateNotifierProvider.notifier).openStoreListing();

// Send feedback email (address from Remote Config `feedback_email` key):
await ref.read(launchFeedbackStateNotifierProvider.notifier).launch(
  appName: 'My App',
);
```

---

### Route

The routing module uses Flutter's native `CupertinoTabScaffold` — no third-party router required. Each tab is a `NavigationTab` subclass; `ShellRouteWidget` wires everything together.

Built-in behaviours:
- Tapping the active tab **pops to root** (`popUntil((r) => r.isFirst)`)
- **System back** pops within the tab before propagating up
- Per-tab **isolated navigator** with a stable `GlobalKey` managed by Riverpod

**1. Define your tabs**

```dart
class HomeTab extends NavigationTab {
  const HomeTab() : super(
    name: 'home',
    icon: CupertinoIcons.house_fill,
    initialTab: true,   // exactly one tab should be true
  );

  @override
  String label(BuildContext context) => AppLocalizations.of(context)!.home;

  @override
  Map<String, WidgetBuilder>? get routes => {
    '/': (_) => const HomeScreen(),
    '/detail': (_) => const DetailScreen(),
  };

  @override
  List<NavigatorObserver> navigatorObservers(BuildContext context) =>
      defaultNavigatorObservers(context); // Firebase Analytics + PostHog auto-tracking
}

class SettingsTab extends NavigationTab {
  const SettingsTab() : super(name: 'settings', icon: CupertinoIcons.settings);

  @override
  String label(BuildContext context) => 'Settings';

  @override
  Map<String, WidgetBuilder>? get routes => {
    '/': (_) => const SettingsScreen(),
  };
}
```

**2. Render the shell**

```dart
ShellRouteWidget(
  tabs: const [HomeTab(), SettingsTab()],
  activeColor: CupertinoColors.activeBlue, // optional
)
```

---

### Settings

```dart
// Haptic feedback toggle (persisted to SharedPreferences):
CacheBoolRowWidget(
  stateNotifierProvider: hapticFeedbackStateNotifierProvider,
  displayDivider: true,
  leftWidget: AppIconWidget.icon(iconData: CupertinoIcons.hand_tap),
  title: 'Haptic Feedback',
  description: null,
  onPressed: (newState) =>
      TapOnVibrationFeedbackSettings(enable: newState).track(context: context),
  onChanged: null,
)

// Prevent screen sleep (persisted):
CacheBoolRowWidget(
  stateNotifierProvider: wakelockStateNotifierProvider,
  displayDivider: true,
  leftWidget: AppIconWidget.icon(iconData: CupertinoIcons.brightness_solid),
  title: 'Keep Screen On',
  description: null,
  onPressed: (newState) {
    WakelockPlus.toggle(enable: newState); // apply immediately
    TapOnPreventSleepSettings(enable: newState).track(context: context);
  },
  onChanged: null,
)

// Dark mode toggle:
ThemeRowWidget(
  state: null,
  displayDivider: false,
  label: 'Dark Mode',
  description: null,
  onPressed: (newTheme) =>
      TapOnDarkModeSettings(themeData: newTheme).track(context: context),
)

// Generic non-persisted toggle:
SwitchRowWidget(
  state: null,           // null = internal hook state
  initialData: true,
  displayDivider: false,
  leftWidget: null,
  title: 'Notifications',
  description: null,
  onPressed: (newState) { /* handle */ },
  onChanged: null,
)
```

---

### Storage (Firebase)

Files are fetched from Firebase Storage and cached transparently in SharedPreferences. Use `invalidateCacheDuration` or `invalidateCacheBefore` to control staleness.

```dart
// Display a raster image (PNG/JPEG):
ImageNetworkFromStorageWidget(
  path: 'images/user_avatar.png',   // Firebase Storage path
  width: 48,
  height: 48,
  fit: BoxFit.cover,
  invalidateCacheDuration: const Duration(days: 7),
  progressIndicatorWidget: const CupertinoActivityIndicator(),
  errorWidget: const Icon(CupertinoIcons.person_circle),
)

// Display an SVG icon:
SvgFromStorageWidget(
  path: 'icons/category_sport.svg',
  width: 24,
  height: 24,
  color: IosTheme.of(context).defaultLabelColors.primary,
  invalidateCacheDuration: const Duration(days: 30),
)

// Force refresh after a content deploy:
ImageNetworkFromStorageWidget(
  path: 'images/hero_banner.png',
  invalidateCacheBefore: DateTime(2025, 6, 1),
)

// Fetch JSON from Firebase Storage:
ref.read(getJsonUsecaseProvider)(
  path: 'config/app_config.json',
  invalidateCacheDuration: const Duration(hours: 6),
  invalidateCacheBefore: null,
);
```

---

### Theme

```dart
// In your root HookConsumerWidget:
class MyApp extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeStateNotifierProvider); // IosThemeData?

    return IosTheme(
      data: themeData ?? IosLightThemeData(), // null = fallback to light
      child: CupertinoApp(
        theme: CupertinoThemeData(
          brightness: switch (themeData) {
            null                => Brightness.light,
            IosLightThemeData() => Brightness.light,
            IosDarkThemeData()  => Brightness.dark,
          },
        ),
        navigatorObservers: defaultNavigatorObservers(context),
      ),
    );
  }
}

// Toggle dark mode:
await ref.read(themeStateNotifierProvider.notifier).setThemeData(
  iosThemeData: IosDarkThemeData(),
);

// Preview without persisting (e.g. live preview in settings):
ref.read(themeStateNotifierProvider.notifier).setThemeData(
  iosThemeData: IosDarkThemeData(),
  save: false,   // updates state only, does not write to SharedPreferences
);

// Reset to system theme:
await ref.read(themeStateNotifierProvider.notifier).removeThemeData();

// Read theme in any widget (no Riverpod needed):
final theme = IosTheme.of(context);
final primaryColor = theme.defaultLabelColors.primary;
```

---

## Naming conventions

All symbols follow consistent patterns derived from the existing codebase:

| Symbol | Pattern | Examples |
|---|---|---|
| Files | `snake_case` + suffix | `theme_state_notifier.dart`, `get_locale_usecase.dart` |
| Classes | `PascalCase` + semantic suffix | `ThemeStateNotifier`, `GetLocaleUsecase` |
| Providers | `camelCase` + `Provider` | `themeStateNotifierProvider`, `getLocaleUsecaseProvider` |
| Use cases | `{Verb}{Entity}Usecase` | `GetThemeDataUsecase`, `InvalidateCustomerInfoCacheUsecase` |
| Notifiers | `{Feature}StateNotifier` | `CustomerInfoStateNotifier`, `HapticFeedbackStateNotifier` |
| Widgets | `{Descriptor}Widget` / `{Descriptor}RowWidget` | `LabelRowWidget`, `ImageNetworkFromStorageWidget` |
| Abstract repos | base name only | `ThemeRepository`, `StorageRepository` |
| Concrete repos | tech prefix or `Impl` suffix | `FirebaseStorageRepository`, `ThemeRepositoryImpl` |
| Failures | `{Specific}Failure` | `UnidentifiedStorageFailure`, `EmptyCacheStorageFailure` |
| Events (tap) | `TapOn{Target}` | `TapOnDarkModeSettings`, `TapOnReviewButton` |
| Events (callback) | `On{Event}Callback` | `OnSyncPurchasesCallback`, `OnPresentedPaywallCallback` |
| Hooks | `use{Feature}` | `useSafeEffect`, `useDebounce` |
| Constants | `k{Name}` | `kDefaultHapticFeedback`, `kEnableBackdropImageFilter` |
| SharedPreferences keys | function appending `Debug` in debug mode | `hapticFeedbackKey()`, `themeKey()` |
| Family args | `{Feature}FamilyArgs` | `GetDownloadUrlFamilyArgs`, `GetJsonFamilyArgs` |

---

## AI tooling

### Claude Code skills

The `.claude/skills/` directory contains structured skill files that Claude Code loads automatically based on context. Each skill documents a specific domain and includes a "What Is Already Implemented" table so the AI can answer "is X already done?" without scanning the codebase.

| Skill | Trigger context |
|---|---|
| `core-architecture` | Either, State, SafeStateNotifier, GetStateNotifier, hooks, setup providers |
| `feature-modules` | Adding a new feature module, layer structure questions |
| `analytics-feature` | Adding events, new analytics SDK, Remote Config gating |
| `riverpod-hooks-patterns` | Writing providers, widgets, hooks |
| `naming-conventions` | Creating any new file or symbol |
| `feature-locale` | Locale persistence, language selection |
| `feature-revenue` | In-app purchases, paywall, subscription status |
| `feature-review` | Rate-app flow, feedback email |
| `feature-route` | Tab navigation, NavigationTab, analytics observers |
| `feature-settings` | Settings toggles, haptic feedback, wakelock |
| `feature-storage` | Firebase Storage, image/SVG widgets, caching |
| `feature-theme` | Dark/light mode, ThemeStateNotifier, theme persistence |

### Cursor rules

The `.cursor/rules/` directory contains `.mdc` rule files that Cursor applies during code generation.

| Rule file | `alwaysApply` | Scope |
|---|---|---|
| `naming-conventions.mdc` | `true` | All files |
| `architecture.mdc` | `true` | All files |
| `riverpod-patterns.mdc` | `false` | `lib/**/*.dart` |
| `feature-development.mdc` | `false` | `lib/src/features/**/*.dart` |
| `analytics-events.mdc` | `false` | Analytics + event files |
| `package-usage.mdc` | `false` | Consuming app integration |
| `feature-locale.mdc` | `false` | `lib/src/features/locale/**` |
| `feature-revenue.mdc` | `false` | `lib/src/features/revenue/**` |
| `feature-review.mdc` | `false` | `lib/src/features/review/**` |
| `feature-route.mdc` | `false` | `lib/src/features/route/**` |
| `feature-settings.mdc` | `false` | `lib/src/features/settings/**` |
| `feature-storage.mdc` | `false` | `lib/src/features/storage/**` |
| `feature-theme.mdc` | `false` | `lib/src/features/theme/**` |

### Dart MCP server

The repository ships with `.cursor/mcp.json.example` that wires up the Dart MCP server so Cursor can resolve Dart/Flutter symbols in AI completions.

```bash
cp .cursor/mcp.json.example .cursor/mcp.json
```

Update the `dart` executable path to match your local Flutter SDK:

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

### Ralph orchestrator

The project supports [Ralph](https://github.com/mikeyobrien/ralph-orchestrator) for AI-driven task automation:

```bash
# Install ralph (requires Node.js)
npm install -g ralph-orchestrator

# Describe your task
echo "Add a new analytics event for onboarding completion" > PROMPT.md

# Run
ralph run
```

**Key `ralph.yml` options:**

| Key | Default | Description |
|---|---|---|
| `cli.backend` | `claude` | LLM backend |
| `event_loop.max_iterations` | `100` | Safety cap on iterations |
| `git.commit.message_format` | `conventional` | Commit style |
| `git.push.auto_push` | `true` | Push after each commit |
| `git.branch.prefix` | `ralph/` | Branch prefix |

```bash
cp ralph.yml.example ralph.yml
```

---

## Contributing

1. Fork the repository and create a feature branch.
2. Follow the clean-architecture layer conventions and naming conventions documented above.
3. Run `flutter analyze` and `flutter test` before opening a PR.
4. Use [Conventional Commits](https://www.conventionalcommits.org/) for all commit messages.
