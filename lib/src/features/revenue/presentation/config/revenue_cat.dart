import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/presentation/setup/dot_env/dot_env.dart';

Future<void> initPlatformState() async {
  if (await Purchases.isConfigured) {
    return;
  }
  final revenueCatProjectAppleApiKey = DotEnv.getRevenueCatProjectAppleApiKey();
  final revenueCatProjectGoogleApiKey =
      DotEnv.getRevenueCatProjectGoogleApiKey();
  await Purchases.setLogLevel(
    switch (kDebugMode) {
      true => LogLevel.error,
      false => LogLevel.info,
    },
  );
  final configuration = switch ((
    Platform.isAndroid,
    revenueCatProjectGoogleApiKey,
    Platform.isIOS,
    revenueCatProjectAppleApiKey,
  )) {
    (true, final String revenueCatProjectGoogleApiKey, _, _) =>
      PurchasesConfiguration(
        revenueCatProjectGoogleApiKey,
      )
        ..appUserID = null
        ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat(),
    (_, _, true, final String revenueCatProjectAppleApiKey) =>
      PurchasesConfiguration(
        revenueCatProjectAppleApiKey,
      )
        ..appUserID = null
        ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat(),
    _ => null,
  };
  if (configuration != null) {
    configuration.entitlementVerificationMode =
        EntitlementVerificationMode.informational;
    configuration.pendingTransactionsForPrepaidPlansEnabled = true;
    await Purchases.configure(configuration);
    await Purchases.enableAdServicesAttributionTokenCollection();
  }
}

final revenueCatProvider = Provider((ref) => Purchases());
