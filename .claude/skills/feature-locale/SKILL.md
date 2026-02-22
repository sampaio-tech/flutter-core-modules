---
name: feature-locale
description: Everything about the locale feature in flutter_core_modules — what it does, all files, providers, use cases, and how to use it from an external app to persist and restore the user's chosen language. Use when working with locale/language persistence, asking whether locale is already implemented, or wiring locale into a consuming app.
---

# Feature: Locale

**Purpose:** Persist and restore the user's chosen `Locale` across app sessions using `SharedPreferences`. The feature has no UI — it is a pure data/domain module.

---

## Layer Map

```
lib/src/features/locale/
├── domain/
│   ├── repositories/locale_repository.dart      # abstract LocaleRepository
│   └── usecases/
│       ├── get_locale_usecase.dart               # GetLocaleUsecase + provider
│       ├── set_locale_usecase.dart               # SetLocaleUsecase + provider
│       └── remove_locale_usecase.dart            # RemoveLocaleUsecase + provider
└── data/
    └── repositories/locale_repository.dart      # LocaleRepositoryImpl + provider
```

No `presentation/` layer — locale is consumed directly via use cases.

---

## Domain

### Repository Interface
```dart
// lib/src/features/locale/domain/repositories/locale_repository.dart
abstract class LocaleRepository {
  Locale? getLocale();                               // sync, nullable
  Future<bool> setLocale({required Locale locale});  // returns success bool
  Future<bool> removeLocale();                       // returns success bool
}
```

### Use Cases

| Class | Provider | Signature |
|---|---|---|
| `GetLocaleUsecase` | `getLocaleUsecaseProvider` | `Locale? call()` |
| `SetLocaleUsecase` | `setLocaleUsecaseProvider` | `Future<bool> call({required Locale locale})` |
| `RemoveLocaleUsecase` | `removeLocaleUsecaseProvider` | `Future<bool> call()` |

All providers are `Provider.autoDispose`.

---

## Data

### `LocaleRepositoryImpl`
**File:** `lib/src/features/locale/data/repositories/locale_repository.dart`

Persists locale as a `List<String>` in `SharedPreferences`:
- Key: `DatabaseKeys.locale.key` → `'locale'` (prod) / `'localeDebug'` (debug)
- Stored value: `['en']` or `['en', 'US']` (languageCode + optional countryCode)
- Reads back: pattern matches on the list length to reconstruct `Locale`

```dart
// Storage format:
// Locale('en')       → ['en']
// Locale('pt', 'BR') → ['pt', 'BR']

final localeRepositoryProvider = Provider.autoDispose<LocaleRepository>(
  (ref) => LocaleRepositoryImpl(
    sharedPreferences: ref.read(sharedPreferencesProvider),
  ),
);
```

---

## How to Use From an External App

### 1. Read persisted locale (sync, on app start)

```dart
final getLocale = ref.read(getLocaleUsecaseProvider);
final savedLocale = getLocale(); // Locale? — null if never set
```

### 2. Wire into MaterialApp / CupertinoApp

```dart
// In your root widget:
final savedLocale = ref.read(getLocaleUsecaseProvider)();

CupertinoApp(
  locale: savedLocale,         // null = system locale
  supportedLocales: const [Locale('en'), Locale('pt', 'BR')],
  localizationsDelegates: const [...],
)
```

For reactive locale (re-renders app on change), store locale in your own `StateNotifier<Locale?>` and call `SetLocaleUsecase` inside it. There is no built-in locale notifier in this package — add one in your consuming app following the `ThemeStateNotifier` pattern.

### 3. Persist a locale change

```dart
final setLocale = ref.read(setLocaleUsecaseProvider);
await setLocale(locale: const Locale('pt', 'BR'));

// Track analytics:
ChangeLanguageTo(locale: const Locale('pt', 'BR')).track(context: context);
```

### 4. Reset to system locale

```dart
await ref.read(removeLocaleUsecaseProvider)();
```

---

## What Is Already Implemented

| Capability | Status |
|---|---|
| Persist locale to SharedPreferences | ✅ `SetLocaleUsecase` |
| Read persisted locale | ✅ `GetLocaleUsecase` |
| Remove persisted locale (reset to system) | ✅ `RemoveLocaleUsecase` |
| Debug/prod key separation | ✅ `DatabaseKeys.locale` |
| Analytics event on language change | ✅ `ChangeLanguageTo` in `events.dart` |
| Reactive locale `StateNotifier` | ❌ Not in package — implement in consuming app |
| Locale picker UI | ❌ Not in package — implement in consuming app |

---

## Exported Symbols

```dart
// From lib/flutter_core_modules.dart:
export 'src/features/locale/domain/repositories/locale_repository.dart';
export 'src/features/locale/domain/usecases/get_locale_usecase.dart';
export 'src/features/locale/domain/usecases/set_locale_usecase.dart';
export 'src/features/locale/domain/usecases/remove_locale_usecase.dart';
export 'src/features/locale/data/repositories/locale_repository.dart';
```
