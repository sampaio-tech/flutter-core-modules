import 'package:purchases_flutter/purchases_flutter.dart';

abstract class RevenueRepository {
  const RevenueRepository();

  Future<void> addCustomerInfoUpdateListener(
    void Function(CustomerInfo) listener,
  );

  Future<void> removeCustomerInfoUpdateListener(
    void Function(CustomerInfo) listener,
  );

  Future<String> getAppUserID();

  Future<bool> getIsAnonymous();

  Future<CustomerInfo?> getCustomerInfo();

  Future<void> syncPurchases();

  Future<void> invalidateCustomerInfoCache();
}
