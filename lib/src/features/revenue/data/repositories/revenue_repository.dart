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
  ) async =>
      Purchases.addCustomerInfoUpdateListener(listener);

  @override
  Future<void> removeCustomerInfoUpdateListener(
    void Function(CustomerInfo) listener,
  ) async =>
      Purchases.removeCustomerInfoUpdateListener(listener);

  @override
  Future<String> getAppUserID() => Purchases.appUserID;

  @override
  Future<bool> getIsAnonymous() => Purchases.isAnonymous;

  @override
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return Purchases.getCustomerInfo();
    } catch (err) {
      return null;
    }
  }

  @override
  Future<void> syncPurchases() => Purchases.syncPurchases();

  @override
  Future<void> invalidateCustomerInfoCache() =>
      Purchases.invalidateCustomerInfoCache();
}
