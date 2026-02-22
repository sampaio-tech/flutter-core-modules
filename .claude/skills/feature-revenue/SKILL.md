---
name: feature-revenue
description: Everything about the revenue feature in flutter_core_modules — RevenueCat integration, CustomerInfoStateNotifier, paywall presentation, subscription status, isPremiumCustomerProvider, presentPaywallForwarded, and app initialization. Use when working with in-app purchases, paywalls, subscription gating, or asking whether RevenueCat is already wired up.
---

# Feature: Revenue

**Purpose:** Wraps RevenueCat (`purchases_flutter` + `purchases_ui_flutter`) to manage subscriptions, present paywalls, and provide a reactive premium status provider. All SDK calls guard against unconfigured state.

---

## Layer Map

```
lib/src/features/revenue/
├── domain/
│   ├── repositories/revenue_repository.dart          # abstract RevenueRepository
│   └── usecases/
│       ├── get_customer_info_usecase.dart             # GetCustomerInfoUsecase
│       ├── get_app_user_id_usecase.dart               # GetAppUserIdUsecase
│       ├── get_is_anonymous_usecase.dart              # GetIsAnonymousUsecase
│       ├── sync_purchases_usecase.dart                # SyncPurchasesUsecase
│       ├── invalidate_customer_info_cache_usecase.dart # InvalidateCustomerInfoCacheUsecase
│       ├── add_customer_info_update_listener_usecase.dart
│       └── remove_customer_info_update_listener_usecase.dart
├── data/
│   └── repositories/revenue_repository.dart          # RevenueRepositoryImpl + provider
└── presentation/
    ├── config/
    │   ├── revenue_cat.dart                           # initPlatformState() + revenueCatProvider
    │   └── functions.dart                             # presentPaywallForwarded()
    └── notifiers/customer_info/
        └── customer_info_state_notifier.dart          # CustomerInfoStateNotifier + providers
```

---

## Domain

### Repository Interface
```dart
abstract class RevenueRepository {
  Future<void> addCustomerInfoUpdateListener(void Function(CustomerInfo) listener);
  Future<void> removeCustomerInfoUpdateListener(void Function(CustomerInfo) listener);
  Future<String?> getAppUserID();
  Future<bool?> getIsAnonymous();
  Future<CustomerInfo?> getCustomerInfo();
  Future<void> syncPurchases();
  Future<void> invalidateCustomerInfoCache();
}
```

### Use Cases — Complete Reference

| Class | Provider | Return | Description |
|---|---|---|---|
| `GetCustomerInfoUsecase` | `getCustomerInfoUsecaseProvider` | `Future<CustomerInfo?>` | Fetches current customer info |
| `GetAppUserIdUsecase` | `getAppUserIdUsecaseProvider` | `Future<String?>` | RevenueCat anonymous user ID |
| `GetIsAnonymousUsecase` | `getIsAnonymousUsecaseProvider` | `Future<bool?>` | Whether user is anonymous |
| `SyncPurchasesUsecase` | `syncPurchasesUsecaseProvider` | `Future<void>` | Forces purchase sync with store |
| `InvalidateCustomerInfoCacheUsecase` | `invalidateCustomerInfoCacheUsecaseProvider` | `Future<void>` | Clears RevenueCat's local cache |
| `AddCustomerInfoUpdateListenerUsecase` | `addCustomerInfoUpdateListenerUsecaseProvider` | `Future<void>` | Registers a subscription change listener |
| `RemoveCustomerInfoUpdateListenerUsecase` | `removeCustomerInfoUpdateListenerUsecaseProvider` | `Future<void>` | Unregisters a subscription change listener |

All providers are `Provider.autoDispose`.

---

## Data

### `RevenueRepositoryImpl`
**File:** `lib/src/features/revenue/data/repositories/revenue_repository.dart`

Wraps the `Purchases` static SDK. **Every method guards against unconfigured state:**

```dart
Future<CustomerInfo?> getCustomerInfo() async {
  if (!await Purchases.isConfigured) return null;
  try {
    return Purchases.getCustomerInfo();
  } catch (err) {
    return null; // swallows errors safely
  }
}
```

Provider: `revenueRepositoryProvider` (autoDispose, no external dependencies).

---

## Presentation

### `initPlatformState()` — SDK Initialization
**File:** `lib/src/features/revenue/presentation/config/revenue_cat.dart`

Called by `DotEnv.init()` during app startup. Configures RevenueCat for iOS/Android using keys from `.env`:

```dart
// In main():
await DotEnv.init(remoteConfig); // calls initPlatformState() internally

// Or directly:
await initPlatformState();
```

**Required `.env` keys:**
- `REVENUECAT_PROJECT_APPLE_API_KEY`  → iOS
- `REVENUECAT_PROJECT_GOOGLE_API_KEY` → Android

Configuration sets:
- `entitlementVerificationMode: EntitlementVerificationMode.informational`
- `pendingTransactionsForPrepaidPlansEnabled: true`
- Calls `Purchases.enableAdServicesAttributionTokenCollection()` on iOS

### `CustomerInfoStateNotifier`
**File:** `lib/src/features/revenue/presentation/notifiers/customer_info/customer_info_state_notifier.dart`

State: `CustomerInfo?` (null = not yet fetched or unconfigured)

| Method | Description |
|---|---|
| `get({bool invalidateCache = true})` | Invalidates cache (optional), fetches, updates state |
| `syncPurchases({bool invalidateCache = true})` | Syncs store purchases, then calls `get()` |
| `listen()` | Registers SDK listener for real-time subscription updates |
| `presentPaywall({...callbacks...})` | Checks active subscriptions → if none, shows RevenueCat paywall UI |
| `dispose()` | Automatically removes SDK listener |

```dart
// Provider — NOT autoDispose (global subscription state):
final customerInfoStateNotifierProvider =
    StateNotifierProvider<CustomerInfoStateNotifier, CustomerInfo?>(...);

// Derived convenience provider:
final isPremiumCustomerProvider = Provider<bool>(
  (ref) => ref.watch(
    customerInfoStateNotifierProvider.select(
      (info) => info?.activeSubscriptions.isNotEmpty ?? false,
    ),
  ),
);
```

### `presentPaywallForwarded()` — Full Paywall Flow With Analytics
**File:** `lib/src/features/revenue/presentation/config/functions.dart`

```dart
Future<PaywallResult?> presentPaywallForwarded({
  required BuildContext context,
  required EventEntity? event,    // analytics event tied to the CTA
  required bool enable,           // false = skip paywall, call onTap directly
  required bool featureLocked,    // true = feature requires premium
  required void Function()? onTap,
  void Function()? onHasActiveSubscriptionCallback,
  void Function()? onPresentedPaywallCallback,
  void Function(PaywallResult)? onSyncPurchasesCallback,
  void Function(PaywallResult)? onPresentPaywallResultCallback,
})
```

This function:
1. Guards `Purchases.isConfigured` — returns null if SDK not ready
2. If `!enable` → calls `onTap()` directly (feature not locked)
3. If user already has active subscription → fires `OnHasActiveSubscriptionCallback` analytics, calls `onTap()`
4. Otherwise → presents paywall via `RevenueCatUI.presentPaywall()`
5. On purchase/restore → syncs purchases, fires `OnSyncPurchasesCallback` analytics
6. Always fires `OnPresentPaywallResultCallback` analytics with the result

---

## How to Use From an External App

### 1. Initialize on app start (already done by `DotEnv.init`)

```dart
// main():
await DotEnv.init(remoteConfig); // includes initPlatformState()
```

### 2. Fetch and listen to subscription changes

```dart
// On root widget mount (e.g., in useSafeEffect or initState):
final notifier = ref.read(customerInfoStateNotifierProvider.notifier);
await notifier.get();     // initial fetch
await notifier.listen();  // register real-time listener
```

### 3. Check premium status reactively

```dart
final isPremium = ref.watch(isPremiumCustomerProvider);

if (isPremium) {
  // show premium content
} else {
  // show upgrade CTA
}
```

### 4. Gate a feature behind a paywall

```dart
await presentPaywallForwarded(
  context: context,
  event: TapOnGetPremiumButton(),
  enable: true,          // always gate this feature
  featureLocked: true,   // feature requires premium
  onTap: () {
    // execute feature action after purchase or if already premium
    Navigator.of(context).push(...);
  },
);
```

### 5. Show paywall from a button (non-gating)

```dart
LabelRowWidget.blueButton(
  displayDivider: false,
  title: 'Get Premium',
  description: null,
  label: null,
  onPressed: ({required context, ...}) async {
    TapOnGetPremiumButton().track(context: context);
    await presentPaywallForwarded(
      context: context,
      event: TapOnGetPremiumButton(),
      enable: true,
      featureLocked: false,
      onTap: null,
    );
  },
  onLongPress: null,
)
```

### 6. Access raw customer info

```dart
final customerInfo = ref.watch(customerInfoStateNotifierProvider);
final activeSubscriptions = customerInfo?.activeSubscriptions ?? [];
final entitlements = customerInfo?.entitlements.active ?? {};
```

---

## What Is Already Implemented

| Capability | Status |
|---|---|
| RevenueCat SDK init (iOS + Android) | ✅ `initPlatformState()` |
| Fetch customer info | ✅ `GetCustomerInfoUsecase` / `notifier.get()` |
| Reactive premium status | ✅ `isPremiumCustomerProvider` |
| Real-time subscription listener | ✅ `notifier.listen()` / `dispose()` |
| Present paywall UI | ✅ `notifier.presentPaywall()` |
| Full paywall flow with analytics | ✅ `presentPaywallForwarded()` |
| Sync purchases | ✅ `SyncPurchasesUsecase` |
| Invalidate cache | ✅ `InvalidateCustomerInfoCacheUsecase` |
| Get RevenueCat user ID | ✅ `GetAppUserIdUsecase` |
| Check anonymous status | ✅ `GetIsAnonymousUsecase` |
| Custom paywall UI | ❌ Not in package — uses RevenueCat's built-in UI |
| Entitlement-specific checks | ❌ Not in package — use `customerInfo.entitlements.active` directly |

---

## Exported Symbols

```dart
export 'src/features/revenue/domain/repositories/revenue_repository.dart';
export 'src/features/revenue/domain/usecases/add_customer_info_update_listener_usecase.dart';
export 'src/features/revenue/domain/usecases/get_app_user_id_usecase.dart';
export 'src/features/revenue/domain/usecases/get_customer_info_usecase.dart';
export 'src/features/revenue/domain/usecases/get_is_anonymous_usecase.dart';
export 'src/features/revenue/domain/usecases/invalidate_customer_info_cache_usecase.dart';
export 'src/features/revenue/domain/usecases/remove_customer_info_update_listener_usecase.dart';
export 'src/features/revenue/domain/usecases/sync_purchases_usecase.dart';
export 'src/features/revenue/data/repositories/revenue_repository.dart';
export 'src/features/revenue/presentation/config/functions.dart';
export 'src/features/revenue/presentation/config/revenue_cat.dart';
export 'src/features/revenue/presentation/notifiers/customer_info/customer_info_state_notifier.dart';
```
