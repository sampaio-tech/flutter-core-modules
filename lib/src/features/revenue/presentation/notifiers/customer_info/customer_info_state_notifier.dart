import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../../../core/presentation/notifiers/safe_state_notifier.dart';
import '../../../domain/usecases/add_customer_info_update_listener_usecase.dart';
import '../../../domain/usecases/get_customer_info_usecase.dart';
import '../../../domain/usecases/invalidate_customer_info_cache_usecase.dart';
import '../../../domain/usecases/remove_customer_info_update_listener_usecase.dart';
import '../../../domain/usecases/sync_purchases_usecase.dart';

class CustomerInfoStateNotifier extends SafeStateNotifier<CustomerInfo?> {
  final GetCustomerInfoUsecase _getCustomerInfoUsecase;
  final RemoveCustomerInfoUpdateListenerUsecase
  _removeCustomerInfoUpdateListenerUsecase;
  final AddCustomerInfoUpdateListenerUsecase
  _addCustomerInfoUpdateListenerUsecase;
  final InvalidateCustomerInfoCacheUsecase _invalidateCustomerInfoCacheUsecase;
  final SyncPurchasesUsecase _syncPurchasesUsecase;

  CustomerInfoStateNotifier({
    required GetCustomerInfoUsecase getCustomerInfoUsecase,
    required RemoveCustomerInfoUpdateListenerUsecase
    removeCustomerInfoUpdateListenerUsecase,
    required AddCustomerInfoUpdateListenerUsecase
    addCustomerInfoUpdateListenerUsecase,
    required InvalidateCustomerInfoCacheUsecase
    invalidateCustomerInfoCacheUsecase,
    required SyncPurchasesUsecase syncPurchasesUsecase,
  }) : _getCustomerInfoUsecase = getCustomerInfoUsecase,
       _removeCustomerInfoUpdateListenerUsecase =
           removeCustomerInfoUpdateListenerUsecase,
       _addCustomerInfoUpdateListenerUsecase =
           addCustomerInfoUpdateListenerUsecase,
       _invalidateCustomerInfoCacheUsecase = invalidateCustomerInfoCacheUsecase,
       _syncPurchasesUsecase = syncPurchasesUsecase,
       super(null);

  Future<PaywallResult?> presentPaywall({
    void Function()? onHasActiveSubscriptionCallback,
    void Function()? onPresentedPaywallCallback,
    void Function(PaywallResult value)? onSyncPurchasesCallback,
    void Function(PaywallResult value)? onPresentPaywallResultCallback,
  }) async {
    final hasActiveSubscription =
        state?.activeSubscriptions.isNotEmpty ?? false;
    if (hasActiveSubscription) {
      onHasActiveSubscriptionCallback?.call();
      return null;
    }
    onPresentedPaywallCallback?.call();
    return RevenueCatUI.presentPaywall().then((value) async {
      if (value == PaywallResult.purchased || value == PaywallResult.restored) {
        onSyncPurchasesCallback?.call(value);
        await syncPurchases();
      }
      onPresentPaywallResultCallback?.call(value);
      return value;
    });
  }

  Future<CustomerInfo?> get({bool invalidateCache = true}) async {
    if (invalidateCache) {
      await _invalidateCustomerInfoCacheUsecase();
    }
    final customerInfo = await _getCustomerInfoUsecase();
    state = customerInfo;
    return customerInfo;
  }

  Future<CustomerInfo?> syncPurchases({bool invalidateCache = true}) async {
    await _syncPurchasesUsecase();
    return get(invalidateCache: invalidateCache);
  }

  void _listener(CustomerInfo customerInfo) async {
    state = customerInfo;
  }

  Future<void> listen() async {
    await _addCustomerInfoUpdateListenerUsecase(_listener);
  }

  @override
  void dispose() {
    _removeCustomerInfoUpdateListenerUsecase(_listener);
    super.dispose();
  }
}

final customerInfoStateNotifierProvider =
    StateNotifierProvider<CustomerInfoStateNotifier, CustomerInfo?>(
      (ref) => CustomerInfoStateNotifier(
        syncPurchasesUsecase: ref.read(syncPurchasesUsecaseProvider),
        getCustomerInfoUsecase: ref.read(getCustomerInfoUsecaseProvider),
        removeCustomerInfoUpdateListenerUsecase: ref.read(
          removeCustomerInfoUpdateListenerUsecaseProvider,
        ),
        addCustomerInfoUpdateListenerUsecase: ref.read(
          addCustomerInfoUpdateListenerUsecaseProvider,
        ),
        invalidateCustomerInfoCacheUsecase: ref.read(
          invalidateCustomerInfoCacheUsecaseProvider,
        ),
      ),
    );

final isPremiumCustomerProvider = Provider<bool>(
  (ref) => ref.watch(
    customerInfoStateNotifierProvider.select(
      (customerInfo) => customerInfo?.activeSubscriptions.isNotEmpty ?? false,
    ),
  ),
);
