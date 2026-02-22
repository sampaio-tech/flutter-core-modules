---
name: riverpod-hooks-patterns
description: Explains how Riverpod and flutter_hooks are used in flutter_core_modules — provider types, state flow through layers, hook patterns, HookConsumerWidget usage, common mistakes to avoid, and best practices. Use when writing new providers, widgets, or hooks, or when debugging state-related issues.
---

# Riverpod + flutter_hooks Patterns — flutter_core_modules

This package uses `hooks_riverpod` (v3.x) + `flutter_hooks` (v0.21.x). Every widget that needs either Riverpod or hooks extends `HookConsumerWidget`. Every widget that needs only hooks extends `HookWidget`.

---

## 1. Provider Type Selection Guide

| Use Case | Provider Type | Example in Codebase |
|---|---|---|
| Sync read-only value | `Provider` | `sharedPreferencesProvider`, `amplitudeProvider` |
| Sync read-only, dispose when unused | `Provider.autoDispose` | `cacheRepositoryProvider`, `getBoolUsecaseProvider` |
| Parameterized provider | `Provider.family` | `navigatiorKeyProvider` |
| Mutable state, no async | `StateNotifierProvider` | `themeStateNotifierProvider`, `hapticFeedbackStateNotifierProvider` |
| Mutable state, dispose when unused | `StateNotifierProvider.autoDispose` | — |
| Mutable state + params | `StateNotifierProvider.autoDispose.family` | `getDownloadUrlStateNotifierProvider`, `getJsonStateNotifierProvider` |
| Derived/computed value | `Provider` watching another | `isPremiumCustomerProvider` |

---

## 2. When to Use autoDispose

**Use `autoDispose`** for:
- Use cases (they have no state, just method calls)
- Repository implementations (stateless)
- Feature-specific state that only lives while a screen is visible

**Do NOT use `autoDispose`** for:
- Global app state: `themeStateNotifierProvider`, `hapticFeedbackStateNotifierProvider`, `wakelockStateNotifierProvider`
- RevenueCat: `customerInfoStateNotifierProvider` (persists subscription state)
- In-app review: `inAppReviewStateNotifierProvider`, `launchFeedbackStateNotifierProvider`
- Riverpod root providers: `sharedPreferencesProvider` (singleton)

---

## 3. State Flow Through Layers

```
UI (HookConsumerWidget)
    │
    ├── ref.watch(myStateNotifierProvider)        ← subscribe to State<F, S>
    ├── ref.read(myStateNotifierProvider.notifier) ← call methods
    └── ref.read(myUsecaseProvider)               ← direct use case access
          │
          └── StateNotifier (SafeStateNotifier subclass)
                    │
                    └── UseCase.call(...)
                              │
                              └── Repository.method(...)  ← Either<Failure, T>
                                        │
                                        └── DataSource / SDK
```

**Conventions:**
- `ref.watch()` → always in `build()` for reactive state
- `ref.read()` → always in callbacks and event handlers (never in `build()`)
- `ref.listen()` → for side effects (navigation, snackbars) triggered by state changes

---

## 4. HookConsumerWidget — The Standard Widget Base

All widgets that need either Riverpod state OR hooks use `HookConsumerWidget`:

```dart
class MyWidget extends HookConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks — called at top of build, in consistent order
    final controller = useTextEditingController();
    final debounce  = useDebounce(const Duration(milliseconds: 300));
    final isLoading = useState(false);

    // Riverpod — watch for reactive updates
    final theme     = ref.watch(themeStateNotifierProvider);
    final isPremium = ref.watch(isPremiumCustomerProvider);

    return ...;
  }
}
```

**Hook rules (critical):**
1. Always call hooks at the **top level** of `build()` — never inside conditionals, loops, or callbacks.
2. All hooks must be called on every build in the **same order**.
3. Never call `useState`, `useEffect`, etc. inside `.then()` callbacks.

---

## 5. State Consumption Pattern

The `State<F, S>` sealed class is matched with pattern matching in UI:

```dart
final state = ref.watch(getDownloadUrlStateNotifierProvider(args));

return switch (state) {
  StartedState()                              => const SizedBox.shrink(),
  LoadInProgressState()                       => const CupertinoActivityIndicator(),
  LoadSuccessState(value: final String url)   => Image.network(url),
  LoadFailureState(value: final StorageFailure f) => ErrorIndicatorWidget(
      retryCallback: () => ref
          .read(getDownloadUrlStateNotifierProvider(args).notifier)
          .get(),
      label: 'Failed to load image',
      retryLabel: 'Retry',
      axis: Axis.vertical,
      iconWidget: null,
    ),
};
```

---

## 6. Family Provider Pattern

For parameterized state (e.g., different download URLs per path), use `.family` with a dedicated args class:

```dart
// Args class (must implement == and hashCode for family to work correctly)
class GetDownloadUrlFamilyArgs {
  final String path;
  final DateTime? invalidateCacheBefore;
  final Duration? invalidateCacheDuration;

  const GetDownloadUrlFamilyArgs({
    required this.path,
    this.invalidateCacheBefore,
    this.invalidateCacheDuration,
  });
  // Note: This codebase does NOT override == / hashCode on args classes.
  // Two different args with the same values create separate provider instances.
  // This is acceptable because useMemoized stabilizes the args reference.
}

// Provider
final getDownloadUrlStateNotifierProvider =
    StateNotifierProvider.autoDispose.family<..., GetDownloadUrlFamilyArgs>(
      (ref, args) {
        final notifier = GetDownloadUrlStateNotifier(
          path: args.path,
          ...
          getDownloadURLUsecase: ref.read(getDownloadUrlUsecaseProvider),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => notifier.lazyGet());
        return notifier;
      },
    );
```

**In widgets**, stabilize family args with `useMemoized`:
```dart
final familyArgs = useMemoized(
  () => GetDownloadUrlFamilyArgs(
    path: path,
    invalidateCacheBefore: invalidateCacheBefore,
    invalidateCacheDuration: invalidateCacheDuration,
  ),
  [path, invalidateCacheBefore, invalidateCacheDuration],
);

final state = ref.watch(getDownloadUrlStateNotifierProvider(familyArgs));
```

---

## 7. useSafeEffect — Post-Frame Effect

The standard pattern for triggering state notifier actions from a widget:

```dart
useSafeEffect(() {
  ref
      .read(getDownloadUrlStateNotifierProvider(familyArgs).notifier)
      .lazyGet();
  return () {}; // no cleanup needed
}, [familyArgs]);
```

`useSafeEffect` runs after the first frame (via `addPostFrameCallback`), preventing `setState during build` errors.

**When to use:**
- Triggering initial data fetch in a widget
- Running side effects after mount
- Starting listeners that need the widget tree to be ready

---

## 8. useDebounce — Input Debouncing

```dart
final debounce = useDebounce(const Duration(milliseconds: 500));

TextField(
  onChanged: (value) => debounce(() {
    ref.read(searchNotifierProvider.notifier).search(query: value);
  }),
)
```

The `useDebounce` hook returns a `ValueChanged<VoidCallback>`. Call it with a closure to run after the debounce duration. Previous pending callbacks are automatically cancelled.

---

## 9. useInterval / useSafeInterval

```dart
// Runs immediately, every second:
useInterval(() {
  ref.read(clockNotifierProvider.notifier).tick();
}, const Duration(seconds: 1));

// Runs after first frame, every second:
useSafeInterval(() {
  ref.read(clockNotifierProvider.notifier).tick();
}, const Duration(seconds: 1));
```

Both automatically cancel on dispose.

---

## 10. ProviderScope.containerOf — Direct Provider Access Without ref

In static/non-widget contexts (like `EventEntity.track()` or `LabelRowWidget.copyToClipboard()`), access the Riverpod container via:

```dart
final providerContainer = ProviderScope.containerOf(context);
final hapticState = providerContainer.read(hapticFeedbackStateNotifierProvider);
```

Use this pattern when:
- In static methods that receive `BuildContext`
- In factory/static widget methods (`LabelRowWidget.copyToClipboard`)
- In `EventEntity.track(context)` to fan out to the analytics repository

---

## 11. Consumer — Scoped Rebuilds

When only part of a widget needs to rebuild on state change, use `Consumer` or `HookConsumer` (not `ConsumerWidget`):

```dart
// From CacheBoolRowWidget — only the switch rebuilds when state changes:
Consumer(
  child: SwitchRowWidget(...), // built once, never rebuilds
  builder: (context, ref, child) {
    ref.watch(stateNotifierProvider); // rebuilds this Consumer
    return child ?? const SizedBox.shrink();
  },
);
```

This is the "child optimization" pattern — expensive sub-trees passed as `child` are not rebuilt.

---

## 12. Legacy StateNotifier Import

All `StateNotifier`, `StateNotifierProvider`, `StateNotifierProviderFamily` usages require:

```dart
import 'package:hooks_riverpod/legacy.dart';
```

The main `hooks_riverpod.dart` import does NOT export legacy `StateNotifier` APIs in v3.x. This is consistently used throughout the codebase.

```dart
// WRONG — will not compile in hooks_riverpod 3.x:
import 'package:hooks_riverpod/hooks_riverpod.dart';
class MyNotifier extends StateNotifier<bool> { ... }

// CORRECT:
import 'package:hooks_riverpod/legacy.dart';
class MyNotifier extends StateNotifier<bool> { ... }
```

For `Provider` (not StateNotifier), use the standard import:
```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
final myProvider = Provider<Foo>(...);
```

---

## 13. Common Mistakes to Avoid

### ❌ Calling ref.read() in build()
```dart
// WRONG — won't rebuild when state changes
Widget build(BuildContext context, WidgetRef ref) {
  final isPremium = ref.read(isPremiumCustomerProvider);
  return Text(isPremium ? 'Premium' : 'Free');
}
```
```dart
// CORRECT
final isPremium = ref.watch(isPremiumCustomerProvider);
```

### ❌ Calling ref.watch() in callbacks
```dart
// WRONG — throws if called after dispose, causes infinite rebuilds
onPressed: () {
  final notifier = ref.watch(myNotifierProvider.notifier);
  notifier.doSomething();
}
```
```dart
// CORRECT
onPressed: () {
  ref.read(myNotifierProvider.notifier).doSomething();
}
```

### ❌ Setting state after dispose (without SafeStateNotifier)
Already handled by `SafeStateNotifier` — always extend it, never raw `StateNotifier`.

### ❌ Using hooks inside conditions
```dart
// WRONG — hooks must always be called in the same order
if (someCondition) {
  final state = useState(false);
}
```
```dart
// CORRECT — always call, conditionally use
final state = useState(false);
if (someCondition) {
  // use state.value
}
```

### ❌ Creating family args without useMemoized
```dart
// WRONG — creates new args on every rebuild, causing unnecessary provider recreation
final state = ref.watch(myProvider(MyArgs(path: widget.path)));
```
```dart
// CORRECT — stable reference across rebuilds
final args = useMemoized(() => MyArgs(path: widget.path), [widget.path]);
final state = ref.watch(myProvider(args));
```

### ❌ Forgetting autoDispose on use cases
```dart
// WRONG — use case instances accumulate in memory
final myUsecaseProvider = Provider<MyUsecase>(...);
```
```dart
// CORRECT
final myUsecaseProvider = Provider.autoDispose<MyUsecase>(...);
```

### ❌ Not using legacy import for StateNotifier
```dart
// WRONG — compile error in hooks_riverpod 3.x
import 'package:hooks_riverpod/hooks_riverpod.dart';
class MyNotifier extends StateNotifier<int> {}
```
```dart
// CORRECT
import 'package:hooks_riverpod/legacy.dart';
class MyNotifier extends StateNotifier<int> {}
```

---

## 14. ValueNotifier + ValueListenableBuilder Pattern

For UI state that should not trigger Riverpod provider rebuilds (e.g., toggle switch animation), use `ValueNotifier` with `useValueNotifier`:

```dart
// From SwitchRowWidget:
final internalState = state ?? useValueNotifier(initialData);

// Update after frame to avoid "setState during build":
onPressed: () {
  final newState = !internalState.value;
  onPressed?.call(newState);
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => internalState.value = newState,
  );
},

rightWidget: ValueListenableBuilder<bool>(
  valueListenable: internalState,
  builder: (context, value, child) => SwitchWidget.stocks(
    value: value,
    onChanged: (v) {
      WidgetsBinding.instance.addPostFrameCallback((_) => internalState.value = v);
    },
  ),
),
```

This pattern keeps the switch animation local without involving Riverpod, while the `onPressed`/`onChanged` callbacks propagate changes to the actual `StateNotifier` separately.
