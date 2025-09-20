import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../domain/repositories/revenue_repository.dart';

final revenueRepositoryProvider = Provider.autoDispose<RevenueRepository>(
  (ref) => const RevenueRepositoryImpl(),
);

class RevenueRepositoryImpl extends RevenueRepository {
  const RevenueRepositoryImpl();

  @override
  Future<void> addCustomerInfoUpdateListener(
    void Function(CustomerInfo) listener,
  ) async {
    if (!await Purchases.isConfigured) {
      return;
    }
    return Purchases.addCustomerInfoUpdateListener(listener);
  }

  @override
  Future<void> removeCustomerInfoUpdateListener(
    void Function(CustomerInfo) listener,
  ) async {
    if (!await Purchases.isConfigured) {
      return;
    }
    return Purchases.removeCustomerInfoUpdateListener(listener);
  }

  @override
  Future<String?> getAppUserID() async {
    if (!await Purchases.isConfigured) {
      return null;
    }
    return Purchases.appUserID;
  }

  @override
  Future<bool?> getIsAnonymous() async {
    if (!await Purchases.isConfigured) {
      return null;
    }
    return Purchases.isAnonymous;
  }

  @override
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      if (!await Purchases.isConfigured) {
        return null;
      }
      return Purchases.getCustomerInfo();
    } catch (err) {
      return null;
    }
  }

  @override
  Future<void> syncPurchases() async {
    if (!await Purchases.isConfigured) {
      return null;
    }
    return Purchases.syncPurchases();
  }

  @override
  Future<void> invalidateCustomerInfoCache() async {
    if (!await Purchases.isConfigured) {
      return null;
    }
    return Purchases.invalidateCustomerInfoCache();
  }
}
